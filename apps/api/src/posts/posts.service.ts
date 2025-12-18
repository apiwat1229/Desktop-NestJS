import { CreatePostDto, UpdatePostDto } from '@my-app/types';
import { ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class PostsService {
    constructor(private prisma: PrismaService) { }

    async create(createPostDto: CreatePostDto, authorId: string) {
        return this.prisma.post.create({
            data: {
                ...createPostDto,
                authorId,
            },
            include: {
                author: {
                    select: {
                        id: true,
                        email: true,
                        name: true,
                        role: true,
                    },
                },
            },
        });
    }

    async findAll(published?: boolean) {
        return this.prisma.post.findMany({
            where: published !== undefined ? { published } : undefined,
            include: {
                author: {
                    select: {
                        id: true,
                        email: true,
                        name: true,
                        role: true,
                    },
                },
            },
            orderBy: {
                createdAt: 'desc',
            },
        });
    }

    async findOne(id: string) {
        const post = await this.prisma.post.findUnique({
            where: { id },
            include: {
                author: {
                    select: {
                        id: true,
                        email: true,
                        name: true,
                        role: true,
                    },
                },
            },
        });

        if (!post) {
            throw new NotFoundException(`Post with ID ${id} not found`);
        }

        return post;
    }

    async update(id: string, updatePostDto: UpdatePostDto, userId: string, userRole: string) {
        const post = await this.findOne(id);

        // Only author or admin can update
        if (post.authorId !== userId && userRole !== 'ADMIN') {
            throw new ForbiddenException('You can only update your own posts');
        }

        return this.prisma.post.update({
            where: { id },
            data: updatePostDto,
            include: {
                author: {
                    select: {
                        id: true,
                        email: true,
                        name: true,
                        role: true,
                    },
                },
            },
        });
    }

    async remove(id: string, userId: string, userRole: string) {
        const post = await this.findOne(id);

        // Only author or admin can delete
        if (post.authorId !== userId && userRole !== 'ADMIN') {
            throw new ForbiddenException('You can only delete your own posts');
        }

        return this.prisma.post.delete({
            where: { id },
        });
    }
}
