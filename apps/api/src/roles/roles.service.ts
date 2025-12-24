import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class RolesService {
    constructor(private prisma: PrismaService) { }

    async findAll() {
        const roles = await this.prisma.role.findMany({
            include: {
                _count: {
                    select: { users: true }
                }
            },
            orderBy: { name: 'asc' }
        });

        return roles.map(role => ({
            ...role,
            userCount: role._count.users
        }));
    }

    async findOne(id: string) {
        const role = await this.prisma.role.findUnique({
            where: { id },
            include: {
                users: {
                    select: {
                        id: true,
                        email: true,
                        firstName: true,
                        lastName: true,
                        displayName: true,
                        avatar: true,
                        department: true,
                        position: true,
                        employeeId: true
                    }
                },
                _count: {
                    select: { users: true }
                }
            }
        });

        if (!role) {
            throw new NotFoundException(`Role with ID ${id} not found`);
        }

        return {
            ...role,
            userCount: role._count.users
        };
    }

    async create(data: any) {
        return this.prisma.role.create({
            data: {
                name: data.name,
                description: data.description,
                icon: data.icon,
                color: data.color,
                permissions: data.permissions || [],
                isActive: data.isActive ?? true
            }
        });
    }

    async update(id: string, data: any) {
        return this.prisma.role.update({
            where: { id },
            data: {
                name: data.name,
                description: data.description,
                icon: data.icon,
                color: data.color,
                permissions: data.permissions,
                isActive: data.isActive
            }
        });
    }

    async remove(id: string) {
        // Check if role has users
        const role = await this.prisma.role.findUnique({
            where: { id },
            include: { _count: { select: { users: true } } }
        });

        if (!role) {
            throw new NotFoundException(`Role with ID ${id} not found`);
        }

        if (role._count.users > 0) {
            throw new Error(`Cannot delete role with ${role._count.users} assigned users`);
        }

        return this.prisma.role.delete({
            where: { id }
        });
    }
}
