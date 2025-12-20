import type { AuthResponse, LoginDto, RegisterDto } from '@my-app/types';
import axios from 'axios';
import { useAuthStore } from '../stores/authStore';

const BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:2530/api';

export const api = axios.create({
    baseURL: BASE_URL,
});

// Request interceptor to add auth token
api.interceptors.request.use((config) => {
    if (typeof window !== 'undefined') {
        const token = useAuthStore.getState().accessToken;
        if (token) {
            config.headers.Authorization = `Bearer ${token}`;
        }
    }
    return config;
});

// Response interceptor for error handling
api.interceptors.response.use(
    (response) => response,
    (error) => {
        if (error.response?.status === 401) {
            localStorage.removeItem('accessToken');
            window.location.href = '/login';
        }
        return Promise.reject(error);
    }
);

// Auth API
export const authApi = {
    login: async (data: LoginDto): Promise<AuthResponse> => {
        const response = await api.post<AuthResponse>('/auth/login', data);
        return response.data;
    },
    register: async (data: RegisterDto): Promise<AuthResponse> => {
        const response = await api.post<AuthResponse>('/auth/register', data);
        return response.data;
    },
};

// Users API
export const usersApi = {
    getAll: async () => {
        const response = await api.get('/users');
        return response.data;
    },
    getOne: async (id: string) => {
        const response = await api.get(`/users/${id}`);
        return response.data;
    },
    create: async (data: any) => {
        const response = await api.post('/users', data);
        return response.data;
    },
    update: async (id: string, data: any) => {
        const response = await api.patch(`/users/${id}`, data);
        return response.data;
    },
    delete: async (id: string) => {
        const response = await api.delete(`/users/${id}`);
        return response.data;
    },
};

// Posts API
export const postsApi = {
    getAll: async (published?: boolean) => {
        const response = await api.get('/posts', {
            params: published !== undefined ? { published } : {},
        });
        return response.data;
    },
    getOne: async (id: string) => {
        const response = await api.get(`/posts/${id}`);
        return response.data;
    },
    create: async (data: any) => {
        const response = await api.post('/posts', data);
        return response.data;
    },
    update: async (id: string, data: any) => {
        const response = await api.patch(`/posts/${id}`, data);
        return response.data;
    },
    delete: async (id: string) => {
        const response = await api.delete(`/posts/${id}`);
        return response.data;
    },
};

// Rubber Types API
export const rubberTypesApi = {
    getAll: async () => {
        const response = await api.get('/rubber-types');
        return response.data;
    },
    getOne: async (id: string) => {
        const response = await api.get(`/rubber-types/${id}`);
        return response.data;
    },
    create: async (data: any) => {
        const response = await api.post('/rubber-types', data);
        return response.data;
    },
    update: async (id: string, data: any) => {
        const response = await api.patch(`/rubber-types/${id}`, data);
        return response.data;
    },
    delete: async (id: string) => {
        const response = await api.delete(`/rubber-types/${id}`);
        return response.data;
    },
};

// Roles API
export const rolesApi = {
    getAll: async () => {
        const response = await api.get('/roles');
        return response.data;
    },
    getOne: async (id: string) => {
        const response = await api.get(`/roles/${id}`);
        return response.data;
    },
    create: async (data: any) => {
        const response = await api.post('/roles', data);
        return response.data;
    },
    update: async (id: string, data: any) => {
        const response = await api.patch(`/roles/${id}`, data);
        return response.data;
    },
    delete: async (id: string) => {
        const response = await api.delete(`/roles/${id}`);
        return response.data;
    },
};

// Analytics API
export const analyticsApi = {
    getStats: async () => {
        const response = await api.get('/analytics/stats');
        return response.data;
    },
};

// Bookings API
export const bookingsApi = {
    getAll: async (params?: { date?: string; slot?: string }) => {
        const response = await api.get('/bookings', { params });
        return response.data;
    },
    getOne: async (id: string) => {
        const response = await api.get(`/bookings/${id}`);
        return response.data;
    },
    create: async (data: any) => {
        const response = await api.post('/bookings', data);
        return response.data;
    },
    update: async (id: string, data: any) => {
        const response = await api.put(`/bookings/${id}`, data);
        return response.data;
    },
    delete: async (id: string) => {
        const response = await api.delete(`/bookings/${id}`);
        return response.data;
    },
    getStats: async (date: string) => {
        const response = await api.get(`/bookings/stats/${date}`);
        return response.data;
    },
};

// Access Control API
export const accessControlApi = {
    getApps: async () => {
        const response = await api.get('/access-control/apps');
        return response.data;
    },
    getAppUsers: async (appName: string) => {
        const response = await api.get(`/access-control/apps/${appName}/users`);
        return response.data;
    },
    assignPermission: async (appName: string, userId: string, actions: string[]) => {
        const response = await api.post(`/access-control/apps/${appName}/users`, { userId, actions });
        return response.data;
    },
    removePermission: async (appName: string, userId: string) => {
        const response = await api.delete(`/access-control/apps/${appName}/users/${userId}`);
        return response.data;
    },
};

