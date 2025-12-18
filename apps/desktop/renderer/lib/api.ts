import type { AuthResponse, LoginDto, RegisterDto } from '@my-app/types';
import axios from 'axios';

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:2530/api';

export const api = axios.create({
    baseURL: API_URL,
    headers: {
        'Content-Type': 'application/json',
    },
});

// Request interceptor to add auth token
api.interceptors.request.use((config) => {
    const token = localStorage.getItem('accessToken');
    if (token) {
        config.headers.Authorization = `Bearer ${token}`;
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
