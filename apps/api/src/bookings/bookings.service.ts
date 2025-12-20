import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

const SLOT_QUEUE_CONFIG: Record<string, { start: number; limit: number | null }> = {
    '08:00-09:00': { start: 1, limit: 4 },
    '09:00-10:00': { start: 5, limit: 4 },
    '10:00-11:00': { start: 9, limit: 4 },
    '11:00-12:00': { start: 13, limit: 4 },
    '13:00-14:00': { start: 17, limit: null }, // Unlimited
};

function getSlotConfig(slot: string, date: Date) {
    const dayOfWeek = new Date(date).getDay();
    // Saturday special rule: 10:00-11:00 becomes unlimited
    if (dayOfWeek === 6 && slot === '10:00-11:00') {
        return { start: 9, limit: null };
    }
    return SLOT_QUEUE_CONFIG[slot] ?? { start: 1, limit: null };
}

function genBookingCode(date: Date, queueNo: number): string {
    const d = new Date(date);
    const yy = String(d.getUTCFullYear()).slice(-2);
    const mm = String(d.getUTCMonth() + 1).padStart(2, '0');
    const dd = String(d.getUTCDate()).padStart(2, '0');
    const q = String(queueNo).padStart(2, '0');
    return `${yy}${mm}${dd}${q}`;
}

import { NotificationsService } from '../notifications/notifications.service';

@Injectable()
export class BookingsService {
    constructor(
        private prisma: PrismaService,
        private notificationsService: NotificationsService
    ) { }

    async create(data: any) {
        const { date, startTime, endTime, supplierId, supplierCode, supplierName, truckType, truckRegister, rubberType, recorder } = data;

        const slot = `${startTime}-${endTime}`;
        const slotConfig = getSlotConfig(slot, new Date(date));

        // Generate the date prefix (YYMMDD) using UTC to match genBookingCode
        const d = new Date(date);
        const yy = String(d.getUTCFullYear()).slice(-2);
        const mm = String(d.getUTCMonth() + 1).padStart(2, '0');
        const dd = String(d.getUTCDate()).padStart(2, '0');
        const codePrefix = `${yy}${mm}${dd}`;

        console.log('--- DEBUG BOOKING CREATION ---');
        console.log('Incoming Date:', date);
        console.log('Code Prefix:', codePrefix);
        console.log('Target Slot:', slot);

        // Get ALL bookings for this "Code Date" (prefix) to ensure we have the full picture
        const dayBookings = await this.prisma.booking.findMany({
            where: {
                bookingCode: {
                    startsWith: codePrefix,
                },
            },
        });

        // Filter for the specific slot we are trying to book
        const existingBookings = dayBookings.filter(b => b.slot === slot);

        console.log('Found Existing Bookings for Slot:', existingBookings.length);
        console.log('Existing Queue Numbers:', existingBookings.map(b => b.bookingCode));

        // Check if slot is full
        if (slotConfig.limit && existingBookings.length >= slotConfig.limit) {
            throw new BadRequestException('This time slot is full');
        }

        // Calculate next queue number
        let queueNo: number;
        if (!slotConfig.limit) {
            // Unlimited slot: increment from start or max existing
            const usedNumbers = existingBookings.map((b) => b.queueNo).sort((a, b) => a - b);
            if (usedNumbers.length === 0) {
                queueNo = slotConfig.start;
            } else {
                // Find gap or append
                queueNo = slotConfig.start;
                // Simple strategy for unlimited: just take (max + 1) or fill gaps?
                // Using fill-gaps strategy to be consistent with limited logic
                for (const num of usedNumbers) {
                    if (num === queueNo) {
                        queueNo++;
                    } else {
                        // Found a gap
                        break;
                    }
                }
            }
        } else {
            const usedNumbers = existingBookings.map((b) => b.queueNo).sort((a, b) => a - b);
            queueNo = slotConfig.start;
            for (const num of usedNumbers) {
                if (num === queueNo) {
                    queueNo++;
                } else {
                    break;
                }
            }
        }

        const bookingCode = genBookingCode(new Date(date), queueNo);

        try {
            return await this.prisma.booking.create({
                data: {
                    queueNo,
                    bookingCode,
                    date: new Date(date),
                    startTime,
                    endTime,
                    slot,
                    supplierId,
                    supplierCode,
                    supplierName,
                    truckType,
                    truckRegister,
                    rubberType,
                    recorder,
                },
            });
        } catch (error) {
            console.error('Error creating booking:', error);
            throw new BadRequestException('Failed to create booking. Please check the data and try again.');
        }

        // Trigger Notification
        await this.triggerNotification('Booking', 'CREATE', {
            title: 'New Booking Created',
            message: `Booking ${bookingCode} created for ${supplierName} at ${slot}`,
            actionUrl: `/bookings/${bookingCode}`,
        });

        return { queueNo, bookingCode };
    }

    async findAll(date?: string, slot?: string) {
        const where: any = {};

        if (date) {
            where.date = new Date(date);
        }

        if (slot) {
            where.slot = slot;
        }

        return this.prisma.booking.findMany({
            where,
            orderBy: { queueNo: 'asc' },
        });
    }

    async findOne(id: string) {
        const booking = await this.prisma.booking.findUnique({
            where: { id },
        });

        if (!booking) {
            throw new NotFoundException(`Booking with ID ${id} not found`);
        }

        return booking;
    }

    async update(id: string, data: any) {
        await this.findOne(id); // Check if exists

        const result = await this.prisma.booking.update({
            where: { id },
            data: {
                supplierId: data.supplierId,
                supplierCode: data.supplierCode,
                supplierName: data.supplierName,
                truckType: data.truckType,
                truckRegister: data.truckRegister,
                rubberType: data.rubberType,
                recorder: data.recorder,
            },
        });

        // Trigger Notification
        await this.triggerNotification('Booking', 'UPDATE', {
            title: 'Booking Updated',
            message: `Booking with ID ${id} has been updated.`,
            actionUrl: `/bookings`, // TODO: use code
        });

        return result;
    }

    async remove(id: string) {
        await this.findOne(id); // Check if exists

        const result = await this.prisma.booking.delete({
            where: { id },
        });

        // Trigger Notification
        await this.triggerNotification('Booking', 'DELETE', {
            title: 'Booking Cancelled',
            message: `Booking with ID ${id} has been cancelled/deleted.`,
        });

        return result;
    }

    private async triggerNotification(sourceApp: string, actionType: string, payload: { title: string; message: string; actionUrl?: string }) {
        try {
            // 1. Get Settings for this event
            const settings = await this.prisma.notificationSetting.findUnique({
                where: {
                    sourceApp_actionType: { sourceApp, actionType }
                }
            });

            if (!settings || !settings.isActive) {
                console.log(`Notification skipped for ${sourceApp}:${actionType} (Disabled or Not Configured)`);
                return;
            }

            const recipientRoles = (settings.recipientRoles as unknown as string[]) || [];

            // 2. Find Users with these Roles
            if (recipientRoles.length > 0) {
                // Fetch role names first since User.role stores names/codes, not IDs (based on schema)
                // Or if User.role stores IDs? Schema default "staff_1" implies codes.
                // Let's try to map IDs to Names if possible, or assume IDs are matching if recently refactored.
                // SAFEST: Fetch Roles by IDs, get their names, then query Users.
                const roles = await this.prisma.role.findMany({
                    where: { id: { in: recipientRoles } },
                    select: { name: true }
                });
                const roleNames = roles.map(r => r.name);

                const users = await this.prisma.user.findMany({
                    where: {
                        role: { in: roleNames }
                    },
                    select: { id: true }
                });

                // 3. Send Notification to each user
                for (const user of users) {
                    await this.notificationsService.create({
                        userId: user.id,
                        title: payload.title,
                        message: payload.message,
                        type: 'INFO',
                        sourceApp,
                        actionType,
                        actionUrl: payload.actionUrl
                    });
                }
            }

            console.log(`Notification sent for ${sourceApp}:${actionType} to ${recipientRoles.length} roles.`);

        } catch (error) {
            console.error('Error triggering notification:', error);
            // Don't fail the main request just because notification failed
        }
    }

    async getStats(date: string) {
        const bookings = await this.findAll(date);

        const total = bookings.length;
        const checkedIn = bookings.filter((b) => b.checkinAt).length;
        const pending = total - checkedIn;

        const slotStats: Record<string, any> = {};
        Object.keys(SLOT_QUEUE_CONFIG).forEach((slot) => {
            const slotBookings = bookings.filter((b) => b.slot === slot);
            slotStats[slot] = {
                count: slotBookings.length,
                checkedIn: slotBookings.filter((b) => b.checkinAt).length,
                bookings: slotBookings,
            };
        });

        return {
            total,
            checkedIn,
            pending,
            slots: slotStats,
        };
    }
}
