import { CreateUserDto, UpdateUserDto } from '@my-app/types';
import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class UsersService {
    constructor(private prisma: PrismaService) { }

    async create(createUserDto: CreateUserDto) {
        const existingUser = await this.prisma.user.findUnique({
            where: { email: createUserDto.email },
        });

        if (existingUser) {
            throw new ConflictException('User with this email already exists');
        }

        if (createUserDto.username) {
            const existingUsername = await this.prisma.user.findUnique({
                // @ts-ignore
                where: { username: createUserDto.username },
            });
            if (existingUsername) {
                throw new ConflictException('Username is already taken');
            }
        }

        const hashedPassword = await bcrypt.hash(createUserDto.password, 10);

        return this.prisma.user.create({
            // @ts-ignore
            data: {
                ...createUserDto,
                password: hashedPassword,
                forceChangePassword: true,
            },
        });
    }

    async findAll() {
        return this.prisma.user.findMany({
            select: {
                id: true,
                email: true,
                username: true,
                firstName: true,
                lastName: true,
                displayName: true,
                department: true,
                position: true,
                role: true,
                status: true,
                avatar: true,
                createdAt: true,
                updatedAt: true,
            } as any,
        });
    }

    async findOne(id: string): Promise<any> {
        const user = await this.prisma.user.findUnique({
            where: { id },
            select: {
                id: true,
                email: true,
                username: true,
                firstName: true,
                lastName: true,
                displayName: true,
                department: true,
                position: true,
                role: true,
                status: true,
                avatar: true,
                createdAt: true,
                updatedAt: true,
                permissions: true,
                hod: {
                    select: {
                        id: true,
                        firstName: true,
                        lastName: true,
                        email: true,
                    }
                },
            } as any,
        });

        if (!user) {
            throw new NotFoundException(`User with ID ${id} not found`);
        }

        return user;
    }

    async findByEmail(email: string): Promise<any> {
        return this.prisma.user.findUnique({
            where: { email },
            select: {
                id: true,
                email: true,
                password: true,
                role: true,
                username: true,
                firstName: true,
                lastName: true,
                displayName: true,
                department: true,
                position: true,
                status: true,
                avatar: true,
                createdAt: true,
                updatedAt: true,
                failedLoginAttempts: true,
                forceChangePassword: true,
                permissions: true,
                hod: {
                    select: {
                        id: true,
                        firstName: true,
                        lastName: true,
                        email: true,
                    }
                },
            } as any,
        });
    }

    async findByEmailOrUsername(identifier: string): Promise<any> {
        return this.prisma.user.findFirst({
            where: {
                OR: [
                    { email: identifier },
                    { username: identifier }
                ]
            },
            select: {
                id: true,
                email: true,
                password: true,
                role: true,
                username: true,
                firstName: true,
                lastName: true,
                displayName: true,
                department: true,
                position: true,
                status: true,
                avatar: true,
                createdAt: true,
                updatedAt: true,
                failedLoginAttempts: true,
                forceChangePassword: true,
                permissions: true,
                hod: {
                    select: {
                        id: true,
                        firstName: true,
                        lastName: true,
                        email: true,
                    }
                },
            } as any,
        });
    }

    async update(id: string, updateUserDto: UpdateUserDto) {
        await this.findOne(id); // Check if exists

        const {
            username,
            email,
            password,
            firstName,
            lastName,
            displayName,
            department,
            position,
            role,
            status,
            avatar,
        } = updateUserDto;

        const dataToUpdate: any = {
            username,
            email,
            firstName,
            lastName,
            displayName,
            department,
            position,
            role,
            status,
            avatar,
        };

        if (password) {
            dataToUpdate.password = await bcrypt.hash(password, 10);
        }

        return this.prisma.user.update({
            where: { id },
            // @ts-ignore
            data: dataToUpdate,
            select: {
                id: true,
                email: true,
                username: true,
                firstName: true,
                lastName: true,
                displayName: true,
                department: true,
                position: true,
                role: true,
                status: true,
                avatar: true,
                createdAt: true,
                updatedAt: true,
            } as any,
        });
    }

    async updateLastLogin(id: string) {
        return this.prisma.user.update({
            where: { id },
            data: { lastLoginAt: new Date() },
        });
    }

    async remove(id: string) {
        await this.findOne(id); // Check if exists

        return this.prisma.user.delete({
            where: { id },
        });
    }

    async updateLoginAttempts(id: string, attempts: number, lock: boolean = false) {
        const data: any = { failedLoginAttempts: attempts };
        if (lock) {
            data.status = 'SUSPENDED'; // Lock user
        }
        return this.prisma.user.update({
            where: { id },
            data,
        });
    }

    /**
     * Unlock a locked user account
     */
    async unlockUser(id: string) {
        await this.findOne(id); // Check if exists

        return this.prisma.user.update({
            where: { id },
            data: {
                status: 'ACTIVE',
                failedLoginAttempts: 0,
            },
            select: {
                id: true,
                email: true,
                displayName: true,
                status: true,
                failedLoginAttempts: true,
            } as any,
        });
    }
}
