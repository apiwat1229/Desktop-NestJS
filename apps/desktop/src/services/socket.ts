import { useAuthStore } from '@/stores/auth';
import { io, Socket } from 'socket.io-client';

class SocketService {
    private socket: Socket | null = null;
    private isConnected = false;

    connect() {
        if (this.socket && this.isConnected) return;

        const authStore = useAuthStore();
        // Allow connection if token exists, but we might need to wait for user ID for room joining
        const token = localStorage.getItem('token') || authStore.accessToken;
        if (!token) {
            console.warn('SocketService: No token found, aborting connection.');
            return;
        }

        const apiUrl = import.meta.env.VITE_API_URL || 'http://localhost:2530';
        const socketUrl = apiUrl.replace('/api', '');

        console.log('SocketService: Connecting to', socketUrl);

        this.socket = io(socketUrl, {
            transports: ['websocket'],
            autoConnect: true,
            auth: {
                token: token
            }
        });

        this.socket.on('connect', () => {
            console.log('SocketService: Connected:', this.socket?.id);
            this.isConnected = true;
            // Try to join if user is already available
            if (authStore.user?.id) {
                this.joinRoom(authStore.user.id);
            } else {
                console.log('SocketService: User ID not ready yet, waiting for joinRoom call.');
            }
        });

        this.socket.on('disconnect', () => {
            console.log('SocketService: Disconnected');
            this.isConnected = false;
        });

        this.socket.on('connect_error', (err) => {
            console.error('SocketService: Connection error:', err);
        });

        // Debug
        this.socket.on('notification', (data) => {
            console.log('SocketService: Received notification event:', data);
        });
    }

    joinRoom(userId: string) {
        if (this.socket && this.isConnected) {
            console.log(`SocketService: Joining room user:${userId}`);
            this.socket.emit('join', userId);
        } else {
            console.warn('SocketService: Cannot join room, socket not connected.');
        }
    }

    disconnect() {
        if (this.socket) {
            this.socket.disconnect();
            this.socket = null;
            this.isConnected = false;
        }
    }

    on(event: string, callback: (...args: any[]) => void) {
        if (!this.socket) this.connect(); // Lazy connect
        this.socket?.on(event, callback);
    }

    off(event: string, callback?: (...args: any[]) => void) {
        if (this.socket) {
            this.socket.off(event, callback);
        }
    }
}

export const socketService = new SocketService();
