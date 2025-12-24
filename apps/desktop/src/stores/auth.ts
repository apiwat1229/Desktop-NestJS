import { defineStore } from 'pinia';
import api from '../services/api';
import { storage } from '../services/storage';

export const useAuthStore = defineStore('auth', {
    state: () => ({
        user: storage.get('user') || null,
        accessToken: storage.get('accessToken') || null,
        tempToken: null as string | null,
    }),
    getters: {
        isAuthenticated: (state) => !!state.accessToken,
        userAvatarUrl: (state) => {
            if (!state.user?.avatar) return '';
            if (state.user.avatar.startsWith('http')) return state.user.avatar;
            const apiUrl = import.meta.env.VITE_API_URL || 'http://localhost:2530';
            return `${apiUrl}${state.user.avatar}`;
        },
    },
    actions: {
        setTempToken(token: string) {
            this.tempToken = token;
        },
        clearTempToken() {
            this.tempToken = null;
        },
        async login(credentials: any, remember: boolean) {
            try {
                const response = await api.post('/auth/login', {
                    email: credentials.email,
                    password: credentials.password
                });

                this.accessToken = response.data.accessToken;
                this.user = response.data.user;

                // Always set axios header
                // api.defaults.headers.common['Authorization'] = `Bearer ${this.accessToken}`;

                console.log(`[Auth] Login success. Remember me: ${remember}`);
                if (remember) {
                    console.log(`[Auth] Saving email: ${credentials.email}`);
                    storage.set('accessToken', this.accessToken);
                    storage.set('user', this.user);
                    storage.set('saved_email', credentials.email);
                } else {
                    // Session only (cleared on app restart if we used sessionStorage, 
                    // but for Electron 'session' usually just means memory or not persisting to diskStore)
                    // For now, let's just NOT save to electron-store.
                    // If we wanted session-only, we could use sessionStorage.
                    storage.delete('accessToken');
                    storage.delete('user');
                    storage.delete('saved_email');
                    // But we keep in state (memory)
                }
            } catch (error: any) {
                if (error.response && error.response.data && error.response.data.code === 'MUST_CHANGE_PASSWORD') {
                    console.log('Force Change Password triggered');
                    this.tempToken = error.response.data.tempToken;
                    throw error; // Let the component handle the redirect
                }
                console.error('Login failed:', error);
                throw error;
            }
        },
        async fetchUser() {
            try {
                const response = await api.get('/auth/me');
                this.user = response.data;
                // If we are "remembering" (persisting), update the store too
                // For simplicity, if we have a token in storage, we update the user in storage
                if (storage.get('accessToken')) {
                    storage.set('user', this.user);
                }
            } catch (error) {
                console.error('Fetch user failed:', error);
                // Optional: logout if fetch fails (token invalid)
                // this.logout();
            }
        },
        logout() {
            this.user = null;
            this.accessToken = null;
            storage.delete('accessToken');
            storage.delete('user');
        }
    }
});
