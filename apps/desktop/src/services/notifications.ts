import type {
    BroadcastDto,
    CreateBroadcastDto,
    CreateNotificationGroupDto,
    NotificationDto,
    NotificationGroupDto,
    NotificationSettingDto,
} from '@my-app/types';
import api from './api';

export const notificationsApi = {
    // User Notifications
    getAll: () => api.get<NotificationDto[]>('/notifications'),

    getUnread: () => api.get<NotificationDto[]>('/notifications/unread'),

    markAsRead: (id: string) => api.put(`/notifications/${id}/read`),

    delete: (id: string) => api.delete(`/notifications/${id}`),

    markAllAsRead: () => api.put('/notifications/read-all'),

    // Broadcast
    broadcast: (data: CreateBroadcastDto) =>
        api.post<BroadcastDto>('/notifications/broadcast', data),

    getBroadcastHistory: () => api.get<BroadcastDto[]>('/notifications/history'),

    deleteBroadcast: (id: string) => api.delete(`/notifications/broadcast/${id}`),

    deleteBroadcasts: (ids: string[]) =>
        api.delete('/notifications/broadcast', { data: { ids } }),

    // Groups
    getGroups: () => api.get<NotificationGroupDto[]>('/notifications/groups'),

    createGroup: (data: CreateNotificationGroupDto) =>
        api.post<NotificationGroupDto>('/notifications/groups', data),

    updateGroup: (id: string, data: Partial<CreateNotificationGroupDto>) =>
        api.put<NotificationGroupDto>(`/notifications/groups/${id}`, data),

    deleteGroup: (id: string) => api.delete(`/notifications/groups/${id}`),

    // Settings
    getSettings: () => api.get<NotificationSettingDto[]>('/notifications/settings'),

    updateSetting: (data: {
        sourceApp: string;
        actionType: string;
        isActive?: boolean;
        recipientRoles?: string[];
        recipientGroups?: string[];
        recipientUsers?: string[];
        channels?: string[];
    }) => api.put('/notifications/settings', data),
};
