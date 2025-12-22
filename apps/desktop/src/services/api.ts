import axios from 'axios';
import router from '../router';
import { storage } from '../services/storage';

const api = axios.create({
    baseURL: 'http://localhost:2530/api', // Point to NestJS backend
    headers: {
        'Content-Type': 'application/json',
    },
});

api.interceptors.request.use(
    (config) => {
        const token = storage.get('accessToken');
        if (token) {
            config.headers.Authorization = `Bearer ${token}`;
        }
        return config;
    },
    (error) => Promise.reject(error)
);

api.interceptors.response.use(
    (response) => response,
    (error) => {
        if (error.response?.status === 401) {
            storage.delete('accessToken');
            storage.delete('user');
            router.push('/login');
        }
        return Promise.reject(error);
    }
);

export default api;
