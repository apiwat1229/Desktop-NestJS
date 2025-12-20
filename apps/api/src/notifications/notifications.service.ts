import { Injectable } from '@nestjs/common';
import { NotificationType } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class NotificationsService {
    constructor(private prisma: PrismaService) { }

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
        return this.prisma.notification.create({
            data: {
                ...data,
                metadata: data.metadata || {},
            },
        });
    }

    async findAll(userId: string) {
        return this.prisma.notification.findMany({
            where: { userId },
            orderBy: { createdAt: 'desc' },
        });
    }

    async findUnread(userId: string) {
        return this.prisma.notification.findMany({
            where: { userId, status: 'UNREAD' },
            orderBy: { createdAt: 'desc' },
        });
    }

    async markAsRead(id: string, userId: string) {
        return this.prisma.notification.update({
            where: { id, userId },
            data: { status: 'READ' },
        });
    }

    async markAllAsRead(userId: string) {
        return this.prisma.notification.updateMany({
            where: { userId, status: 'UNREAD' },
            data: { status: 'READ' },
        });
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
}
