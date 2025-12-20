import { create } from 'zustand';
import { persist } from 'zustand/middleware';

export type NotificationType = 'info' | 'success' | 'warning' | 'error';

export interface Notification {
    id: string;
    title: string;
    message: string;
    type: NotificationType;
    timestamp: string; // ISO string for easier serialization
    read: boolean;
}

interface NotificationState {
    notifications: Notification[];
    unreadCount: number;

    // Actions
    addNotification: (notification: Omit<Notification, 'id' | 'timestamp' | 'read'>) => void;
    markAsRead: (id: string) => void;
    markAllAsRead: () => void;
    clearAll: () => void;
    removeNotification: (id: string) => void;
}

export const useNotificationStore = create<NotificationState>()(
    persist(
        (set) => ({
            notifications: [],
            unreadCount: 0,

            addNotification: (notification) => {
                const newNotification: Notification = {
                    ...notification,
                    id: crypto.randomUUID(),
                    timestamp: new Date().toISOString(),
                    read: false,
                };

                set((state) => ({
                    notifications: [newNotification, ...state.notifications],
                    unreadCount: state.unreadCount + 1,
                }));
            },

            markAsRead: (id) => {
                set((state) => {
                    const notification = state.notifications.find((n) => n.id === id);
                    if (notification && !notification.read) {
                        return {
                            notifications: state.notifications.map((n) =>
                                n.id === id ? { ...n, read: true } : n
                            ),
                            unreadCount: Math.max(0, state.unreadCount - 1),
                        };
                    }
                    return state;
                });
            },

            markAllAsRead: () => {
                set((state) => ({
                    notifications: state.notifications.map((n) => ({ ...n, read: true })),
                    unreadCount: 0,
                }));
            },

            clearAll: () => {
                set({ notifications: [], unreadCount: 0 });
            },

            removeNotification: (id) => {
                set((state) => {
                    const notification = state.notifications.find((n) => n.id === id);
                    return {
                        notifications: state.notifications.filter((n) => n.id !== id),
                        unreadCount:
                            notification && !notification.read
                                ? Math.max(0, state.unreadCount - 1)
                                : state.unreadCount,
                    };
                });
            },
        }),
        {
            name: 'notification-storage',
        }
    )
);
