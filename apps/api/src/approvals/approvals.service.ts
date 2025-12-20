import { Injectable } from '@nestjs/common';
import { ApprovalStatus } from '@prisma/client';
import { NotificationsService } from '../notifications/notifications.service';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class ApprovalsService {
    constructor(
        private prisma: PrismaService,
        private notificationsService: NotificationsService
    ) { }

    async createRequest(data: {
        requesterId: string;
        sourceApp: string;
        actionType: string;
        entityId: string;
        reason?: string;
        changes?: any;
    }) {
        // Create Request
        const request = await this.prisma.approvalRequest.create({
            data: {
                ...data,
                changes: data.changes || {},
            },
            include: { requester: true }
        });

        // Notify Admins/Approvers (Placeholder Logic: Notify all admins)
        // In real app, look up NotificationSettings
        // For now, let's just create a dummy notification or nothing

        return request;
    }

    async findAll() {
        return this.prisma.approvalRequest.findMany({
            include: { requester: true, approver: true },
            orderBy: { submittedAt: 'desc' },
        });
    }

    async findMyRequests(userId: string) {
        return this.prisma.approvalRequest.findMany({
            where: { requesterId: userId },
            orderBy: { submittedAt: 'desc' },
        });
    }

    async approve(id: string, approverId: string, comment?: string) {
        const request = await this.prisma.approvalRequest.update({
            where: { id },
            data: {
                status: ApprovalStatus.APPROVED,
                approverId,
                actedAt: new Date(),
                comment,
            },
            include: { requester: true }
        });

        // Apply Changes based on Logic (Complex part: needs mapping)
        // For MVP, we just mark Approved. Usage logic listens to this or we call a handler.

        // Notify Requester
        await this.notificationsService.create({
            userId: request.requesterId,
            title: 'Request Approved',
            message: `Your request to ${request.actionType} ${request.sourceApp} was approved.`,
            type: 'SUCCESS',
            sourceApp: 'APPROVALS',
            actionType: 'APPROVED',
            entityId: request.id,
        });

        return request;
    }

    async reject(id: string, approverId: string, comment?: string) {
        const request = await this.prisma.approvalRequest.update({
            where: { id },
            data: {
                status: ApprovalStatus.REJECTED,
                approverId,
                actedAt: new Date(),
                comment,
            },
        });

        // Notify Requester
        await this.notificationsService.create({
            userId: request.requesterId,
            title: 'Request Rejected',
            message: `Your request was rejected. Reason: ${comment || 'No reason provided'}`,
            type: 'ERROR',
            sourceApp: 'APPROVALS',
            actionType: 'REJECTED',
            entityId: request.id,
        });

        return request;
    }
}
