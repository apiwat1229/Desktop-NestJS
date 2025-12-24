import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class RubberTypesService {
    constructor(private prisma: PrismaService) { }

    async create(data: any) {
        return this.prisma.rubberType.create({
            data: {
                code: data.code,
                name: data.name,
                description: data.description,
                is_active: data.status === 'ACTIVE' || data.is_active === true, // handle both
            },
        });
    }

    async findAll(includeDeleted = false) {
        const where: any = {};

        // TODO: Uncomment after running migration
        // if (!includeDeleted) {
        //     where.deletedAt = null;
        // }

        return this.prisma.rubberType.findMany({
            where,
            orderBy: { code: 'asc' },
        });
    }

    async findOne(id: string) {
        return this.prisma.rubberType.findUnique({
            where: { id },
        });
    }

    async update(id: string, data: any) {
        return this.prisma.rubberType.update({
            where: { id },
            data: {
                code: data.code,
                name: data.name,
                description: data.description,
                is_active: data.status ? data.status === 'ACTIVE' : data.is_active,
            },
        });
    }

    async remove(id: string) {
        return this.prisma.rubberType.delete({
            where: { id },
        });
    }

    /**
     * Soft delete rubber type
     */
    async softDelete(id: string, userId: string) {
        return this.prisma.rubberType.update({
            where: { id },
            data: {
                deletedAt: new Date(),
                deletedBy: userId,
            } as any, // Type assertion until Prisma regenerates
        });
    }

    /**
     * Restore soft deleted rubber type
     */
    async restore(id: string) {
        return this.prisma.rubberType.update({
            where: { id },
            data: {
                deletedAt: null,
                deletedBy: null,
            } as any, // Type assertion until Prisma regenerates
        });
    }
}
