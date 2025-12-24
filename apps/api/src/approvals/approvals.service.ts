import { BadRequestException, ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { ApprovalStatus } from '@prisma/client';
import { NotificationsService } from '../notifications/notifications.service';
import { PrismaService } from '../prisma/prisma.service';
import { ApproveDto, CancelDto, CreateApprovalRequestDto, RejectDto, ReturnDto, VoidDto } from './dto/approval.dto';

@Injectable()
export class ApprovalsService {
    constructor(
        private prisma: PrismaService,
        private notificationsService: NotificationsService
    ) { }

    /**
     * Create a new approval request
     */
    async createRequest(requesterId: string, dto: CreateApprovalRequestDto) {
        // Create the approval request
        const request = await this.prisma.approvalRequest.create({
            data: {
                requestType: dto.requestType,
                entityType: dto.entityType,
                entityId: dto.entityId,
                sourceApp: dto.sourceApp,
                actionType: dto.actionType,
                currentData: dto.currentData || {},
                proposedData: dto.proposedData || {},
                reason: dto.reason,
                priority: dto.priority || 'NORMAL',
                expiresAt: dto.expiresAt ? new Date(dto.expiresAt) : null,
                requesterId,
                status: ApprovalStatus.PENDING,
            },
            include: {
                requester: {
                    select: {
                        id: true,
                        displayName: true,
                        email: true,
                        role: true,
                    }
                }
            }
        });

        // Create audit log
        await this.createAuditLog({
            approvalRequestId: request.id,
            action: 'CREATED',
            actorId: requesterId,
            actorName: request.requester.displayName || request.requester.email,
            actorRole: request.requester.role,
            newValue: { status: 'PENDING' },
            remark: dto.reason,
        });

        // Notify admins/approvers
        await this.notifyApprovers(request);

        return request;
    }

    /**
     * Get all approval requests (with filters)
     */
    async findAll(filters?: {
        status?: ApprovalStatus;
        entityType?: string;
        includeDeleted?: boolean;
    }) {
        const where: any = {};

        if (filters?.status) {
            where.status = filters.status;
        }

        if (filters?.entityType) {
            where.entityType = filters.entityType;
        }

        if (!filters?.includeDeleted) {
            where.deletedAt = null;
        }

        return this.prisma.approvalRequest.findMany({
            where,
            include: {
                requester: {
                    select: {
                        id: true,
                        displayName: true,
                        email: true,
                        role: true,
                    }
                },
                approver: {
                    select: {
                        id: true,
                        displayName: true,
                        email: true,
                        role: true,
                    }
                }
            },
            orderBy: { submittedAt: 'desc' },
        });
    }

    /**
     * Get single approval request by ID
     */
    async findOne(id: string) {
        const request = await this.prisma.approvalRequest.findUnique({
            where: { id },
            include: {
                requester: {
                    select: {
                        id: true,
                        displayName: true,
                        email: true,
                        role: true,
                    }
                },
                approver: {
                    select: {
                        id: true,
                        displayName: true,
                        email: true,
                        role: true,
                    }
                }
            }
        });

        if (!request) {
            throw new NotFoundException('Approval request not found');
        }

        return request;
    }

    /**
     * Get user's own requests
     */
    async findMyRequests(userId: string) {
        return this.prisma.approvalRequest.findMany({
            where: {
                requesterId: userId,
                deletedAt: null,
            },
            include: {
                approver: {
                    select: {
                        id: true,
                        displayName: true,
                        email: true,
                    }
                }
            },
            orderBy: { submittedAt: 'desc' },
        });
    }

    /**
     * Approve a request
     */
    async approve(id: string, approverId: string, dto: ApproveDto) {
        const request = await this.findOne(id);

        // Validate state
        if (request.status !== ApprovalStatus.PENDING) {
            throw new BadRequestException('Only pending requests can be approved');
        }

        // Get approver info
        const approver = await this.prisma.user.findUnique({
            where: { id: approverId },
            select: { displayName: true, email: true, role: true }
        });

        // Update request
        const updated = await this.prisma.approvalRequest.update({
            where: { id },
            data: {
                status: ApprovalStatus.APPROVED,
                approverId,
                actedAt: new Date(),
                remark: dto.remark,
            },
            include: {
                requester: true,
                approver: true,
            }
        });

        // Create audit log
        await this.createAuditLog({
            approvalRequestId: id,
            action: 'APPROVED',
            actorId: approverId,
            actorName: approver.displayName || approver.email,
            actorRole: approver.role,
            oldValue: { status: 'PENDING' },
            newValue: { status: 'APPROVED' },
            remark: dto.remark,
        });

        // Notify requester
        await this.notificationsService.create({
            userId: request.requesterId,
            title: 'คำขออนุมัติได้รับการอนุมัติ',
            message: `คำขอ ${request.requestType} ของคุณได้รับการอนุมัติแล้ว`,
            type: 'APPROVE',
            sourceApp: 'APPROVALS',
            actionType: 'APPROVED',
            entityId: request.id,
            actionUrl: `/approvals/${request.id}`,
        });

        // Apply the approved changes
        await this.applyApprovedChanges(updated);

        return updated;
    }

    /**
     * Apply approved changes to the actual resource
     */
    private async applyApprovedChanges(request: any) {
        try {
            const { entityType, entityId, actionType, proposedData } = request;

            if (actionType === 'UPDATE') {
                // Apply update based on entity type
                if (entityType === 'Supplier') {
                    await this.prisma.supplier.update({
                        where: { id: entityId },
                        data: proposedData,
                    });
                } else if (entityType === 'RubberType') {
                    await this.prisma.rubberType.update({
                        where: { id: entityId },
                        data: proposedData,
                    });
                }
            } else if (actionType === 'DELETE') {
                // Apply soft delete based on entity type
                if (entityType === 'Supplier') {
                    await this.prisma.supplier.update({
                        where: { id: entityId },
                        data: {
                            deletedAt: new Date(),
                            deletedBy: request.approverId,
                        } as any, // Type assertion until Prisma regenerates
                    });
                } else if (entityType === 'RubberType') {
                    await this.prisma.rubberType.update({
                        where: { id: entityId },
                        data: {
                            deletedAt: new Date(),
                            deletedBy: request.approverId,
                        } as any, // Type assertion until Prisma regenerates
                    });
                }
            }
        } catch (error) {
            console.error('[ApprovalsService] Failed to apply approved changes:', error);
            // Log error but don't throw - approval is already recorded
        }
    }

    /**
     * Reject a request
     */
    async reject(id: string, approverId: string, dto: RejectDto) {
        const request = await this.findOne(id);

        if (request.status !== ApprovalStatus.PENDING) {
            throw new BadRequestException('Only pending requests can be rejected');
        }

        const approver = await this.prisma.user.findUnique({
            where: { id: approverId },
            select: { displayName: true, email: true, role: true }
        });

        const updated = await this.prisma.approvalRequest.update({
            where: { id },
            data: {
                status: ApprovalStatus.REJECTED,
                approverId,
                actedAt: new Date(),
                remark: dto.remark,
            },
            include: {
                requester: true,
                approver: true,
            }
        });

        await this.createAuditLog({
            approvalRequestId: id,
            action: 'REJECTED',
            actorId: approverId,
            actorName: approver.displayName || approver.email,
            actorRole: approver.role,
            oldValue: { status: 'PENDING' },
            newValue: { status: 'REJECTED' },
            remark: dto.remark,
        });

        await this.notificationsService.create({
            userId: request.requesterId,
            title: 'คำขออนุมัติถูกปฏิเสธ',
            message: `คำขอ ${request.requestType} ถูกปฏิเสธ: ${dto.remark}`,
            type: 'ERROR',
            sourceApp: 'APPROVALS',
            actionType: 'REJECTED',
            entityId: request.id,
            actionUrl: `/approvals/${request.id}`,
        });

        return updated;
    }

    /**
     * Return request for modification
     */
    async return(id: string, approverId: string, dto: ReturnDto) {
        const request = await this.findOne(id);

        if (request.status !== ApprovalStatus.PENDING) {
            throw new BadRequestException('Only pending requests can be returned');
        }

        const approver = await this.prisma.user.findUnique({
            where: { id: approverId },
            select: { displayName: true, email: true, role: true }
        });

        const updated = await this.prisma.approvalRequest.update({
            where: { id },
            data: {
                status: ApprovalStatus.RETURNED,
                approverId,
                actedAt: new Date(),
                remark: dto.remark,
            },
            include: {
                requester: true,
                approver: true,
            }
        });

        await this.createAuditLog({
            approvalRequestId: id,
            action: 'RETURNED',
            actorId: approverId,
            actorName: approver.displayName || approver.email,
            actorRole: approver.role,
            oldValue: { status: 'PENDING' },
            newValue: { status: 'RETURNED' },
            remark: dto.remark,
        });

        await this.notificationsService.create({
            userId: request.requesterId,
            title: 'คำขอถูกส่งคืนเพื่อแก้ไข',
            message: `คำขอ ${request.requestType} ถูกส่งคืน: ${dto.remark}`,
            type: 'WARNING',
            sourceApp: 'APPROVALS',
            actionType: 'RETURNED',
            entityId: request.id,
            actionUrl: `/approvals/${request.id}`,
        });

        return updated;
    }

    /**
     * Cancel a request (by requester)
     */
    async cancel(id: string, userId: string, dto: CancelDto) {
        const request = await this.findOne(id);

        // Only requester can cancel
        if (request.requesterId !== userId) {
            throw new ForbiddenException('Only the requester can cancel this request');
        }

        if (request.status !== ApprovalStatus.PENDING) {
            throw new BadRequestException('Only pending requests can be cancelled');
        }

        const user = await this.prisma.user.findUnique({
            where: { id: userId },
            select: { displayName: true, email: true, role: true }
        });

        const updated = await this.prisma.approvalRequest.update({
            where: { id },
            data: {
                status: ApprovalStatus.CANCELLED,
                actedAt: new Date(),
                remark: dto.reason,
            },
            include: {
                requester: true,
            }
        });

        await this.createAuditLog({
            approvalRequestId: id,
            action: 'CANCELLED',
            actorId: userId,
            actorName: user.displayName || user.email,
            actorRole: user.role,
            oldValue: { status: 'PENDING' },
            newValue: { status: 'CANCELLED' },
            remark: dto.reason,
        });

        return updated;
    }

    /**
     * Void an approved request
     */
    async void(id: string, adminId: string, dto: VoidDto) {
        const request = await this.findOne(id);

        if (request.status !== ApprovalStatus.APPROVED) {
            throw new BadRequestException('Only approved requests can be voided');
        }

        const admin = await this.prisma.user.findUnique({
            where: { id: adminId },
            select: { displayName: true, email: true, role: true }
        });

        const updated = await this.prisma.approvalRequest.update({
            where: { id },
            data: {
                status: ApprovalStatus.VOID,
                actedAt: new Date(),
                remark: dto.reason,
            },
            include: {
                requester: true,
                approver: true,
            }
        });

        await this.createAuditLog({
            approvalRequestId: id,
            action: 'VOIDED',
            actorId: adminId,
            actorName: admin.displayName || admin.email,
            actorRole: admin.role,
            oldValue: { status: 'APPROVED' },
            newValue: { status: 'VOID' },
            remark: dto.reason,
        });

        // Notify requester and approver
        await this.notificationsService.create({
            userId: request.requesterId,
            title: 'คำขอถูกทำเป็นโมฆะ',
            message: `คำขอ ${request.requestType} ที่อนุมัติแล้วถูกทำเป็นโมฆะ: ${dto.reason}`,
            type: 'WARNING',
            sourceApp: 'APPROVALS',
            actionType: 'VOIDED',
            entityId: request.id,
            actionUrl: `/approvals/${request.id}`,
        });

        return updated;
    }

    /**
     * Soft delete a request
     */
    async softDelete(id: string, userId: string) {
        const request = await this.findOne(id);

        const updated = await this.prisma.approvalRequest.update({
            where: { id },
            data: {
                deletedAt: new Date(),
                deletedBy: userId,
            }
        });

        const user = await this.prisma.user.findUnique({
            where: { id: userId },
            select: { displayName: true, email: true, role: true }
        });

        await this.createAuditLog({
            approvalRequestId: id,
            action: 'DELETED',
            actorId: userId,
            actorName: user.displayName || user.email,
            actorRole: user.role,
            oldValue: { deletedAt: null },
            newValue: { deletedAt: new Date() },
        });

        return updated;
    }

    /**
     * Get approval history (audit logs)
     */
    async getHistory(id: string) {
        await this.findOne(id); // Verify request exists

        return this.prisma.approvalLog.findMany({
            where: { approvalRequestId: id },
            orderBy: { createdAt: 'asc' },
        });
    }

    /**
     * Create audit log entry
     */
    private async createAuditLog(data: {
        approvalRequestId: string;
        action: string;
        actorId: string;
        actorName: string;
        actorRole: string;
        oldValue?: any;
        newValue?: any;
        remark?: string;
        ipAddress?: string;
        userAgent?: string;
    }) {
        return this.prisma.approvalLog.create({
            data: {
                approvalRequestId: data.approvalRequestId,
                action: data.action,
                actorId: data.actorId,
                actorName: data.actorName,
                actorRole: data.actorRole,
                oldValue: data.oldValue || {},
                newValue: data.newValue || {},
                remark: data.remark,
                ipAddress: data.ipAddress,
                userAgent: data.userAgent,
            }
        });
    }

    /**
     * Notify approvers about new request
     */
    private async notifyApprovers(request: any) {
        // Get all admins (simplified - in production, use notification settings)
        const admins = await this.prisma.user.findMany({
            where: {
                role: { in: ['ADMIN', 'admin'] },
                status: 'ACTIVE',
            },
            select: { id: true }
        });

        // Create notifications for all admins
        for (const admin of admins) {
            await this.notificationsService.create({
                userId: admin.id,
                title: 'คำขออนุมัติใหม่',
                message: `${request.requester.displayName || request.requester.email} ส่งคำขอ ${request.requestType}`,
                type: 'REQUEST',
                sourceApp: 'APPROVALS',
                actionType: 'APPROVAL_REQUEST',
                entityId: request.id,
                actionUrl: `/approvals/${request.id}`,
            });
        }
    }

    /**
     * Cron job to auto-expire requests
     * Runs every hour
     */
    @Cron(CronExpression.EVERY_HOUR)
    async handleExpiredRequests() {
        const now = new Date();

        const expiredRequests = await this.prisma.approvalRequest.findMany({
            where: {
                status: ApprovalStatus.PENDING,
                expiresAt: {
                    lte: now,
                },
                deletedAt: null,
            },
            include: {
                requester: {
                    select: {
                        id: true,
                        displayName: true,
                        email: true,
                        role: true,
                    }
                }
            }
        });

        for (const request of expiredRequests) {
            await this.prisma.approvalRequest.update({
                where: { id: request.id },
                data: {
                    status: ApprovalStatus.EXPIRED,
                    actedAt: now,
                }
            });

            await this.createAuditLog({
                approvalRequestId: request.id,
                action: 'EXPIRED',
                actorId: 'SYSTEM',
                actorName: 'System',
                actorRole: 'SYSTEM',
                oldValue: { status: 'PENDING' },
                newValue: { status: 'EXPIRED' },
                remark: 'Request expired automatically',
            });

            await this.notificationsService.create({
                userId: request.requesterId,
                title: 'คำขอหมดอายุ',
                message: `คำขอ ${request.requestType} หมดอายุเนื่องจากไม่มีการพิจารณา`,
                type: 'WARNING',
                sourceApp: 'APPROVALS',
                actionType: 'EXPIRED',
                entityId: request.id,
                actionUrl: `/approvals/${request.id}`,
            });
        }

        if (expiredRequests.length > 0) {
            console.log(`[ApprovalsService] Expired ${expiredRequests.length} requests`);
        }
    }
}
