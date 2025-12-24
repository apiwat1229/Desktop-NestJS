
import { CreateSupplierDto, UpdateSupplierDto } from '@my-app/types';
import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class SuppliersService {
    constructor(private prisma: PrismaService) { }

    async create(data: CreateSupplierDto) {
        return this.prisma.supplier.create({
            data: {
                code: data.code,
                name: data.name,
                firstName: data.firstName,
                lastName: data.lastName,
                title: data.title,
                taxId: data.taxId,
                address: data.address,
                phone: data.phone,
                email: data.email,
                status: data.status || 'ACTIVE',
                avatar: data.avatar,
                zipCode: data.zipCode,
                certificateNumber: data.certificateNumber,
                certificateExpire: data.certificateExpire,
                score: data.score,
                eudrQuotaUsed: data.eudrQuotaUsed,
                eudrQuotaCurrent: data.eudrQuotaCurrent,
                rubberTypeCodes: data.rubberTypeCodes || [],
                notes: data.notes,
                provinceId: data.provinceId,
                districtId: data.districtId,
                subdistrictId: data.subdistrictId,
            },
        });
    }

    async findAll(includeDeleted = false) {
        const where: any = {};

        // TODO: Uncomment after running migration
        // if (!includeDeleted) {
        //     where.deletedAt = null;
        // }

        const suppliers = await this.prisma.supplier.findMany({
            where,
            orderBy: { createdAt: 'desc' },
            include: {
                province: true,
            },
        });

        // Collect all unique rubber type codes
        const allRubberTypeCodes = [...new Set(suppliers.flatMap(s => s.rubberTypeCodes))];

        // Fetch rubber types
        const rubberTypes = await this.prisma.rubberType.findMany({
            where: {
                code: { in: allRubberTypeCodes },
            },
            select: {
                code: true,
                name: true,
                category: true,
            },
        });

        // Create a map for quick lookup
        const rubberTypeMap = new Map(rubberTypes.map(rt => [rt.code, rt]));

        // Attach details to suppliers
        return suppliers.map(supplier => ({
            ...supplier,
            rubberTypeDetails: supplier.rubberTypeCodes.map(code => {
                const type = rubberTypeMap.get(code);
                return {
                    code,
                    name: type?.name || code,
                    category: type?.category || 'Other',
                };
            }),
        }));
    }

    async findOne(id: string) {
        return this.prisma.supplier.findUnique({
            where: { id },
        });
    }

    async update(id: string, data: UpdateSupplierDto) {
        return this.prisma.supplier.update({
            where: { id },
            data,
        });
    }

    async remove(id: string) {
        return this.prisma.supplier.delete({
            where: { id },
        });
    }

    /**
     * Soft delete supplier
     */
    async softDelete(id: string, userId: string) {
        return this.prisma.supplier.update({
            where: { id },
            data: {
                deletedAt: new Date(),
                deletedBy: userId,
            } as any, // Type assertion until Prisma regenerates
        });
    }

    /**
     * Restore soft deleted supplier
     */
    async restore(id: string) {
        return this.prisma.supplier.update({
            where: { id },
            data: {
                deletedAt: null,
                deletedBy: null,
            } as any, // Type assertion until Prisma regenerates
        });
    }
}
