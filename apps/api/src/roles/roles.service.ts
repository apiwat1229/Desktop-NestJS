
import { Injectable, OnModuleInit } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

// NOTE: Role table has been removed from the schema.
// System now uses User.role field directly with predefined role codes.
// This service is kept for backward compatibility but all methods are disabled.

const DEFAULT_ROLES = [
    {
        id: 'admin',
        name: 'Administrator',
        description: 'Full system access and configuration',
        color: 'bg-blue-600',
        icon: 'Shield',
        permissions: {
            users: { read: true, write: true, delete: true },
            roles: { read: true, write: true, delete: true },
            settings: { read: true, write: true, delete: true },
        },
    },
    {
        id: 'md',
        name: 'Managing Director',
        description: 'Executive oversight and approval',
        color: 'bg-purple-600',
        icon: 'Briefcase',
        permissions: {
            users: { read: true, write: false, delete: false },
            reports: { read: true, write: true, delete: true },
        }
    },
    {
        id: 'staff_1',
        name: 'Staff 1',
        description: 'Standard operations',
        color: 'bg-emerald-500',
        icon: 'User',
        permissions: {
            bookings: { read: true, write: true, delete: false },
        }
    },
    // Add other default roles as needed matching INITIAL_ROLES from frontend
    { id: 'gm', name: 'General Manager', description: 'General management', color: 'bg-purple-500', icon: 'Briefcase', permissions: {} },
    { id: 'manager', name: 'Manager', description: 'Departmental management', color: 'bg-orange-500', icon: 'Briefcase', permissions: {} },
    { id: 'asst_mgr', name: 'Assistant Manager', description: 'Support management', color: 'bg-orange-400', icon: 'Briefcase', permissions: {} },
    { id: 'senior_sup', name: 'Senior Supervisor', description: 'Senior supervision', color: 'bg-indigo-500', icon: 'Users', permissions: {} },
    { id: 'supervisor', name: 'Supervisor', description: 'Team supervision', color: 'bg-indigo-400', icon: 'Users', permissions: {} },
    { id: 'senior_staff_1', name: 'Senior Staff 1', description: 'Advanced operations', color: 'bg-green-500', icon: 'User', permissions: {} },
    { id: 'staff_2', name: 'Staff 2', description: 'Standard operations', color: 'bg-emerald-500', icon: 'User', permissions: {} },
    { id: 'senior_staff_2', name: 'Senior Staff 2', description: 'Advanced operations', color: 'bg-green-500', icon: 'User', permissions: {} },
    { id: 'op_leader', name: 'Operator Leader', description: 'Line leadership', color: 'bg-slate-500', icon: 'Layers', permissions: {} },
];

@Injectable()
export class RolesService implements OnModuleInit {
    constructor(private prisma: PrismaService) { }

    async onModuleInit() {
        // Seeding disabled - roles are now hardcoded in User.role field
        // await this.seedDefaults();
    }

    async seedDefaults() {
        console.log('Role seeding skipped - Role table has been removed');
        // Role table no longer exists
        // for (const role of DEFAULT_ROLES) {
        //     await this.prisma.role.upsert({
        //         where: { name: role.name },
        //         update: {},
        //         create: {
        //             id: role.id,
        //             name: role.name,
        //             description: role.description,
        //             color: role.color,
        //             icon: role.icon,
        //             permissions: role.permissions,
        //         }
        //     });
        // }
    }

    async findAll() {
        // Return hardcoded roles for backward compatibility
        return DEFAULT_ROLES;
    }

    async findOne(id: string) {
        // Return hardcoded role for backward compatibility
        return DEFAULT_ROLES.find(r => r.id === id) || null;
    }

    async update(id: string, data: any) {
        throw new Error('Role updates are not supported - roles are now hardcoded');
    }

    async create(data: any) {
        throw new Error('Role creation is not supported - roles are now hardcoded');
    }

    async remove(id: string) {
        throw new Error('Role deletion is not supported - roles are now hardcoded');
    }
}
