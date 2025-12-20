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

    async remove(id: string) {
        await this.findOne(id); // Check if exists

        return this.prisma.user.delete({
            where: { id },
        });
    }
}
