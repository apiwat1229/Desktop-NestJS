import {
    OnGatewayConnection,
    OnGatewayDisconnect,
    WebSocketGateway,
    WebSocketServer,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';

@WebSocketGateway({
    cors: {
        origin: '*',
    },
})
export class NotificationsGateway implements OnGatewayConnection, OnGatewayDisconnect {
    @WebSocketServer()
    server: Server;

    // Track connected clients mapped to userIds
    private userSockets = new Map<string, string[]>();

    handleConnection(client: Socket) {
        console.log(`Client connected: ${client.id}`);
        // Basic auth or handshake logic can be added here
        // For now, we expect client to emit 'join' event after connecting
        client.on('join', (userId: string) => {
            if (userId) {
                console.log(`User ${userId} joined via socket ${client.id}`);
                const sockets = this.userSockets.get(userId) || [];
                sockets.push(client.id);
                this.userSockets.set(userId, sockets);
                client.join(`user:${userId}`); // Join room for specific user
            }
        });
    }

    handleDisconnect(client: Socket) {
        console.log(`Client disconnected: ${client.id}`);
        // Cleanup socket from user mapping
        this.userSockets.forEach((sockets, userId) => {
            const index = sockets.indexOf(client.id);
            if (index !== -1) {
                sockets.splice(index, 1);
                if (sockets.length === 0) {
                    this.userSockets.delete(userId);
                }
            }
        });
    }

    sendNotificationToUser(userId: string, notification: any) {
        // Emit to user's room
        const roomName = `user:${userId}`;
        console.log(`[Gateway] Emitting 'notification' to room: ${roomName} | Title: ${notification.title}`);
        this.server.to(roomName).emit('notification', notification);
    }
}
