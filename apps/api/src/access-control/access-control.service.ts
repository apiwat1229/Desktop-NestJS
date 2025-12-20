import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class AccessControlService {
    constructor(private prisma: PrismaService) { }

    // List all available "Apps" (Hardcoded or Dynamic based on usage)
    // For now, let's return a list of defined apps we know exist
    getApps() {
        return [
            { id: 'bookings', name: 'Booking Queue', description: 'Manage supplier bookings' },
            { id: 'inventory', name: 'Inventory', description: 'Warehouse and stock management' },
            { id: 'users', name: 'User Management', description: 'Administer users and roles' },
            { id: 'suppliers', name: 'Supplier Management', description: 'Manage supplier database' },
        ];
    }

    // Get users involved in an App (either by role or explicit permission)
    async getAppUsers(appName: string) {
        // 1. Get explicit permissions
        const permissions = await this.prisma.userAppPermission.findMany({
            where: { appName },
            include: { user: true },
        });

        // 2. We could also fetch users who have "global" access via Role, but for "App Permission" view,
        // we primarily want to see who has *specific* overrides or assignments.
        // Let's return the permissions list, which contains the User info.
        return permissions.map(p => ({
            ...p,
            user: {
                id: p.user.id,
                firstName: p.user.firstName,
                lastName: p.user.lastName,
                email: p.user.email,
                avatar: p.user.avatar,
                role: p.user.role,
            }
        }));
    }

    // Assign/Update permission for a user in an app
    async assignPermission(appName: string, userId: string, actions: string[]) {
        return this.prisma.userAppPermission.upsert({
            where: {
                userId_appName: {
                    userId,
                    appName,
                },
            },
            update: {
                actions: actions, // Pass array directly, Prisma handles Json
            },
            create: {
                userId,
                appName,
                actions: actions,
            },
        });
    }

    // Remove user from app (delete permission record)
    async removePermission(appName: string, userId: string) {
        return this.prisma.userAppPermission.delete({
            where: {
                userId_appName: {
                    userId,
                    appName,
                },
            },
        });
    }
}
