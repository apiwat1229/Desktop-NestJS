import { Injectable } from '@nestjs/common';
import { NotificationType } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { NotificationsGateway } from './notifications.gateway';

@Injectable()
export class NotificationsService {
    constructor(
        private prisma: PrismaService,
        private notificationsGateway: NotificationsGateway
    ) { }

    // ... (existing code, ensure create method also emits if used elsewhere)

    async create(data: {
        userId: string;
        title: string;
        message: string;
        type?: NotificationType;
        sourceApp: string;
        actionType: string;
        entityId?: string;
        actionUrl?: string;
        metadata?: any;
    }) {
        const notification = await this.prisma.notification.create({
            data: {
                ...data,
                metadata: data.metadata || {},
            },
        });

        const dto = this.mapToDto(notification);

        // Emit real-time event
        this.notificationsGateway.sendNotificationToUser(data.userId, dto);

        return dto;
    }

    // ...

    async broadcast(data: {
        title: string;
        message: string;
        type?: NotificationType;
        recipientRoles?: string[];
        recipientUsers?: string[];
        recipientGroups?: string[];
        senderId?: string;
        actionUrl?: string;
    }) {
        console.log('>>>>>>>> BROADCAST CALLED <<<<<<<<');
        console.log('Data:', JSON.stringify(data, null, 2));

        // 1. Find target users
        const whereConditions: any[] = [];

        if (data.recipientUsers && data.recipientUsers.length > 0) {
            console.log(`Explicit Users Targeted: ${data.recipientUsers.length}`);
            whereConditions.push({ id: { in: data.recipientUsers } });
        }

        if (data.recipientRoles && data.recipientRoles.length > 0) {
            console.log(`Roles Targeted: ${data.recipientRoles.join(', ')}`);
            whereConditions.push({ role: { in: data.recipientRoles } });
        }

        if (data.recipientGroups && data.recipientGroups.length > 0) {
            console.log(`Groups Targeted: ${data.recipientGroups.join(', ')}`);
            const groups = await this.prisma.notificationGroup.findMany({
                where: { id: { in: data.recipientGroups } },
                include: { members: { select: { id: true } } }
            });

            const groupUserIds = groups.flatMap(g => g.members.map(m => m.id));
            if (groupUserIds.length > 0) {
                console.log(`Found ${groupUserIds.length} users in groups`);
                whereConditions.push({ id: { in: groupUserIds } });
            }
        }

        // Strict: If explicit targets are requested but none found in DB, return 0.
        // Prevent accidental "broadcast to all" if logic was flawed (though current logic requires non-empty array to push to whereConditions).
        // If data.recipientUsers was passed but came back empty, whereConditions stays empty.

        // If NO recipients specified at all, return error/empty.
        const hasTargets =
            (data.recipientUsers?.length || 0) > 0 ||
            (data.recipientRoles?.length || 0) > 0 ||
            (data.recipientGroups?.length || 0) > 0;

        if (!hasTargets) {
            console.log('No recipients specified in request.');
            return { count: 0, message: 'No recipients specified.' };
        }

        if (whereConditions.length === 0) {
            console.log('Target criteria provided but no matching users found.');
            return { count: 0, message: 'No matching users found.' };
        }

        const users = await this.prisma.user.findMany({
            where: { OR: whereConditions },
            select: { id: true, username: true, email: true }
        });

        console.log(`Final Target List (${users.length}):`);
        users.forEach(u => console.log(` - [${u.id}] ${u.username} (${u.email})`));

        // Deduplicate user IDs
        const uniqueUserIds = [...new Set(users.map(u => u.id))];

        if (uniqueUserIds.length === 0) {
            return { count: 0, message: 'No matching users found.' };
        }

        if (uniqueUserIds.length === 0) {
            return { count: 0, message: 'No matching users found.' };
        }

        // 2. Create notifications individually to get IDs for real-time emission

        // REFACTOR: Create one-by-one to get IDs for real-time compliance.
        let createdCount = 0;
        for (const userId of uniqueUserIds) {
            const notif = await this.prisma.notification.create({
                data: {
                    title: data.title,
                    message: data.message,
                    type: data.type || NotificationType.INFO,
                    userId: userId,
                    sourceApp: 'ADMIN_BROADCAST',
                    actionType: 'MANUAL_BROADCAST',
                    actionUrl: data.actionUrl,
                    metadata: { senderId: data.senderId }
                }
            });
            console.log(`[Broadcast] Creating notification for User: ${userId}`);
            this.notificationsGateway.sendNotificationToUser(userId, notif);
            createdCount++;
        }

        console.log(`[Broadcast] Completed. Sent to ${createdCount} users.`);
        return { count: createdCount, message: `Broadcasted to ${createdCount} users.` };
    }

    async getSettings() {
        return this.prisma.notificationSetting.findMany({
            orderBy: { sourceApp: 'asc' },
        });
    }

    async updateSetting(sourceApp: string, actionType: string, data: {
        isActive?: boolean;
        recipientRoles?: string[];
        recipientUsers?: string[];
        channels?: string[];
    }) {
        return this.prisma.notificationSetting.upsert({
            where: {
                sourceApp_actionType: {
                    sourceApp,
                    actionType,
                },
            },
            update: {
                isActive: data.isActive,
                recipientRoles: data.recipientRoles ? (data.recipientRoles as any) : undefined,
                recipientUsers: data.recipientUsers ? (data.recipientUsers as any) : undefined,
                channels: data.channels ? (data.channels as any) : undefined,
            },
            create: {
                sourceApp,
                actionType,
                isActive: data.isActive ?? true,
                recipientRoles: (data.recipientRoles || []) as any,
                recipientUsers: (data.recipientUsers || []) as any,
                channels: (data.channels || ['IN_APP']) as any,
            },
        });
    }
    private mapToDto(notification: any) {
        return {
            ...notification,
            isRead: notification.status === 'READ',
        };
    }

    async findAll(userId: string) {
        console.log(`[findAll] Fetching notifications for userId: ${userId}`);
        const results = await this.prisma.notification.findMany({
            where: { userId },
            orderBy: { createdAt: 'desc' },
        });
        console.log(`[findAll] Found ${results.length} notifications for ${userId}`);
        if (results.length > 0) {
            console.log(`[findAll] Sample ID: ${results[0].id} | Title: ${results[0].title}`);
        }
        return results.map(n => this.mapToDto(n));
    }

    async findUnread(userId: string) {
        const results = await this.prisma.notification.findMany({
            where: { userId, status: 'UNREAD' },
            orderBy: { createdAt: 'desc' },
        });
        // Even for unread endpoint, returning the consistent DTO structure is good practice
        return results.map(n => this.mapToDto(n));
    }

    async markAsRead(id: string, userId: string) {
        const result = await this.prisma.notification.update({
            where: { id, userId },
            data: { status: 'READ' },
        });
        return this.mapToDto(result);
    }

    async delete(id: string, userId: string) {
        return this.prisma.notification.delete({
            where: { id, userId },
        });
    }

    async markAllAsRead(userId: string) {
        return this.prisma.notification.updateMany({
            where: { userId, status: 'UNREAD' },
            data: { status: 'READ' },
        });
    }

    async getBroadcastHistory() {
        // Get unique broadcasts (group by title, message, type, createdAt)
        const broadcasts = await this.prisma.notification.findMany({
            where: {
                sourceApp: 'ADMIN_BROADCAST',
                actionType: 'MANUAL_BROADCAST'
            },
            include: {
                user: {
                    select: {
                        id: true,
                        username: true,
                        firstName: true,
                        lastName: true,
                        role: true,
                    }
                }
            },
            orderBy: { createdAt: 'desc' },
            take: 100, // Limit to last 100 broadcasts
        });

        // Group by metadata.senderId + createdAt to find unique broadcasts
        const grouped = broadcasts.reduce((acc: any, notif: any) => {
            const key = `${notif.title} -${notif.message} -${notif.type} -${new Date(notif.createdAt).toISOString().slice(0, 16)} `;
            if (!acc[key]) {
                acc[key] = {
                    id: notif.id,
                    title: notif.title,
                    message: notif.message,
                    type: notif.type,
                    createdAt: notif.createdAt,
                    recipientCount: 1,
                    recipientDetails: [notif.user],
                };
            } else {
                acc[key].recipientCount += 1;
                // Add user if not already in the list (deduplicate)
                const userExists = acc[key].recipientDetails.some((u: any) => u.id === notif.user.id);
                if (!userExists) {
                    acc[key].recipientDetails.push(notif.user);
                }
            }
            return acc;
        }, {});

        return Object.values(grouped);
    }

    async deleteBroadcast(id: string) {
        // 1. Find the target notification to get metadata
        const target = await this.prisma.notification.findUnique({
            where: { id },
            select: { title: true, message: true, type: true, createdAt: true, sourceApp: true, actionType: true }
        });

        if (!target) {
            throw new Error('Notification not found');
        }

        // 2. Define a small time window (e.g., 5 seconds) to catch the batch
        const timeWindow = 5000; // 5 seconds
        const createdTime = new Date(target.createdAt).getTime();
        const minTime = new Date(createdTime - timeWindow);
        const maxTime = new Date(createdTime + timeWindow);

        // 3. Delete all matching notifications in the batch
        const result = await this.prisma.notification.deleteMany({
            where: {
                title: target.title,
                message: target.message,
                type: target.type,
                sourceApp: target.sourceApp,
                actionType: target.actionType,
                createdAt: {
                    gte: minTime,
                    lte: maxTime,
                }
            }
        });

        return { count: result.count, message: `Deleted ${result.count} notifications from history.` };
    }

    async deleteBroadcasts(ids: string[]) {
        let totalCount = 0;
        for (const id of ids) {
            try {
                // Reuse the clean-up logic per broadcast ID
                // Note: Ideally we refactor deleteBroadcast to take metadata directly to avoid multiple DB calls, 
                // but this is safer to ensure consistent logic.
                const result = await this.deleteBroadcast(id);
                totalCount += (result.count || 0);
            } catch (error) {
                console.warn(`Failed to delete broadcast ${id}: `, error);
                // Continue with others
            }
        }
        return { count: totalCount, message: `Deleted ${totalCount} notifications from history.` };
    }

    // --- Usage: Group Management ---
    async findAllGroups() {
        return this.prisma.notificationGroup.findMany({
            include: {
                members: {
                    select: { id: true, firstName: true, lastName: true, role: true }
                }
            },
            orderBy: { name: 'asc' }
        });
    }

    async createGroup(data: { name: string; description?: string; memberIds?: string[] }) {
        return this.prisma.notificationGroup.create({
            data: {
                name: data.name,
                description: data.description,
                members: {
                    connect: data.memberIds?.map(id => ({ id })) || []
                }
            },
            include: { members: true }
        });
    }

    async updateGroup(id: string, data: { name?: string; description?: string; memberIds?: string[] }) {
        return this.prisma.notificationGroup.update({
            where: { id },
            data: {
                name: data.name,
                description: data.description,
                members: data.memberIds ? {
                    set: data.memberIds.map(userId => ({ id: userId }))
                } : undefined
            },
            include: { members: true }
        });
    }

    async deleteGroup(id: string) {
        return this.prisma.notificationGroup.delete({
            where: { id }
        });
    }

    /**
     * Get members of a notification group by name
     */
    async getGroupMembers(groupName: string) {
        const group = await this.prisma.notificationGroup.findFirst({
            where: { name: groupName },
            include: {
                members: {
                    select: {
                        id: true,
                        email: true,
                        displayName: true,
                        role: true
                    }
                }
            }
        });

        return group?.members || [];
    }
}
