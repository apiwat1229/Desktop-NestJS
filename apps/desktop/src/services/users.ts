import api from './api';

export type UserRole =
    | 'admin'
    | 'md'
    | 'gm'
    | 'manager'
    | 'asst_mgr'
    | 'senior_sup'
    | 'supervisor'
    | 'senior_staff_2'
    | 'senior_staff_1'
    | 'staff_2'
    | 'staff_1'
    | 'op_leader'
    | 'USER'
    | 'ADMIN';

export interface User {
    id: string;
    email: string;
    username?: string;
    firstName?: string;
    lastName?: string;
    displayName?: string;
    role: UserRole;
    department?: string;
    position?: string;
    status: 'ACTIVE' | 'INACTIVE' | 'SUSPENDED';
    avatar?: string;
    createdAt?: string;
    updatedAt?: string;
    employeeId?: string;
    forceChangePassword?: boolean;
    password?: string;
    pinCode?: string;
    hodId?: string;
}

export const usersApi = {
    getAll: async () => {
        const response = await api.get<User[]>('/users');
        return response.data;
    },

    getById: async (id: string) => {
        const response = await api.get<User>(`/users/${id}`);
        return response.data;
    },

    create: async (data: Partial<User>) => {
        const response = await api.post<User>('/users', data);
        return response.data;
    },

    update: async (id: string, data: Partial<User>) => {
        const response = await api.patch<User>(`/users/${id}`, data);
        return response.data;
    },

    delete: async (id: string) => {
        const response = await api.delete(`/users/${id}`);
        return response.data;
    },

    unlock: async (id: string) => {
        const response = await api.patch<User>(`/users/${id}/unlock`);
        return response.data;
    }
};
