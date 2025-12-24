import api from './api';

export interface ApprovalRequest {
    id: string;
    requestType: string;
    entityType: string;
    entityId: string;
    sourceApp: string;
    actionType: string;
    currentData?: any;
    proposedData?: any;
    reason?: string;
    priority: string;
    status: string;
    requesterId: string;
    approverId?: string;
    submittedAt: string;
    actedAt?: string;
    expiresAt?: string;
    remark?: string;
    deletedAt?: string;
    deletedBy?: string;
    requester?: any;
    approver?: any;
}

export interface ApprovalLog {
    id: string;
    approvalRequestId: string;
    action: string;
    oldValue?: any;
    newValue?: any;
    actorId: string;
    actorName: string;
    actorRole: string;
    remark?: string;
    ipAddress?: string;
    userAgent?: string;
    createdAt: string;
}

export interface CreateApprovalRequestDto {
    requestType: string;
    entityType: string;
    entityId: string;
    sourceApp: string;
    actionType: string;
    currentData?: any;
    proposedData?: any;
    reason?: string;
    priority?: string;
    expiresAt?: string;
}

const approvalsApi = {
    // Get all approval requests
    getAll: (params?: {
        status?: string;
        entityType?: string;
        includeDeleted?: boolean;
    }) => {
        return api.get<ApprovalRequest[]>('/approvals', { params });
    },

    // Get single approval request
    getOne: (id: string) => {
        return api.get<ApprovalRequest>(`/approvals/${id}`);
    },

    // Get user's own requests
    getMyRequests: () => {
        return api.get<ApprovalRequest[]>('/approvals/my');
    },

    // Get approval history
    getHistory: (id: string) => {
        return api.get<ApprovalLog[]>(`/approvals/${id}/history`);
    },

    // Create new approval request
    create: (data: CreateApprovalRequestDto) => {
        return api.post<ApprovalRequest>('/approvals', data);
    },

    // Approve request
    approve: (id: string, data: { remark?: string }) => {
        return api.put<ApprovalRequest>(`/approvals/${id}/approve`, data);
    },

    // Reject request
    reject: (id: string, data: { remark: string }) => {
        return api.put<ApprovalRequest>(`/approvals/${id}/reject`, data);
    },

    // Return for modification
    return: (id: string, data: { remark: string }) => {
        return api.put<ApprovalRequest>(`/approvals/${id}/return`, data);
    },

    // Cancel request
    cancel: (id: string, data: { reason?: string }) => {
        return api.put<ApprovalRequest>(`/approvals/${id}/cancel`, data);
    },

    // Void approved request
    void: (id: string, data: { reason: string }) => {
        return api.put<ApprovalRequest>(`/approvals/${id}/void`, data);
    },

    // Soft delete
    softDelete: (id: string) => {
        return api.delete<ApprovalRequest>(`/approvals/${id}`);
    },
};

export default approvalsApi;
