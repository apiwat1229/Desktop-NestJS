import { CreateSupplierDto, UpdateSupplierDto } from '@my-app/types';
import { Body, Controller, Delete, Get, Param, Patch, Post, Query, UseGuards } from '@nestjs/common';
import { ApprovalsService } from '../approvals/approvals.service';
import {
    SUPPLIERS_CREATE,
    SUPPLIERS_DELETE,
    SUPPLIERS_DELETE_REQUEST,
    SUPPLIERS_READ,
    SUPPLIERS_UPDATE,
    SUPPLIERS_UPDATE_REQUEST
} from '../auth/constants/permissions';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { Permissions } from '../auth/decorators/permissions.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { PermissionsGuard } from '../auth/guards/permissions.guard';
import { SuppliersService } from './suppliers.service';

@Controller('suppliers')
@UseGuards(JwtAuthGuard, PermissionsGuard)
export class SuppliersController {
    constructor(
        private readonly suppliersService: SuppliersService,
        private readonly approvalsService: ApprovalsService,
    ) { }

    @Post()
    @Permissions(SUPPLIERS_CREATE)
    create(@Body() createSupplierDto: CreateSupplierDto) {
        return this.suppliersService.create(createSupplierDto);
    }

    @Get()
    @Permissions(SUPPLIERS_READ)
    findAll(@Query('includeDeleted') includeDeleted?: string) {
        return this.suppliersService.findAll(includeDeleted === 'true');
    }

    @Get(':id')
    @Permissions(SUPPLIERS_READ)
    findOne(@Param('id') id: string) {
        return this.suppliersService.findOne(id);
    }

    @Patch(':id')
    @Permissions(SUPPLIERS_UPDATE)
    update(@Param('id') id: string, @Body() updateSupplierDto: UpdateSupplierDto) {
        return this.suppliersService.update(id, updateSupplierDto);
    }

    @Delete(':id')
    @Permissions(SUPPLIERS_DELETE)
    remove(@Param('id') id: string) {
        return this.suppliersService.remove(id);
    }

    // ==================== Approval Workflow ====================

    /**
     * Request approval for update
     */
    @Post(':id/update-request')
    @Permissions(SUPPLIERS_UPDATE_REQUEST)
    async requestUpdate(
        @Param('id') id: string,
        @Body() updateDto: UpdateSupplierDto,
        @CurrentUser() user: any,
    ) {
        const currentData = await this.suppliersService.findOne(id);

        return this.approvalsService.createRequest(user.id, {
            requestType: 'SUPPLIER_UPDATE',
            entityType: 'Supplier',
            entityId: id,
            sourceApp: 'SUPPLIER_MANAGEMENT',
            actionType: 'UPDATE',
            currentData,
            proposedData: updateDto,
            reason: 'Request to update supplier information',
            priority: 'NORMAL',
        });
    }

    /**
     * Request approval for delete
     */
    @Post(':id/delete-request')
    @Permissions(SUPPLIERS_DELETE_REQUEST)
    async requestDelete(
        @Param('id') id: string,
        @CurrentUser() user: any,
    ) {
        const currentData = await this.suppliersService.findOne(id);

        return this.approvalsService.createRequest(user.id, {
            requestType: 'SUPPLIER_DELETE',
            entityType: 'Supplier',
            entityId: id,
            sourceApp: 'SUPPLIER_MANAGEMENT',
            actionType: 'DELETE',
            currentData,
            proposedData: null,
            reason: 'Request to delete supplier',
            priority: 'NORMAL',
        });
    }

    /**
     * Soft delete (direct - requires permission)
     */
    @Delete(':id/soft')
    @Permissions(SUPPLIERS_DELETE)
    async softDelete(@Param('id') id: string, @CurrentUser() user: any) {
        return this.suppliersService.softDelete(id, user.id);
    }

    /**
     * Restore soft deleted supplier
     */
    @Post(':id/restore')
    @Permissions(SUPPLIERS_UPDATE)
    async restore(@Param('id') id: string) {
        return this.suppliersService.restore(id);
    }
}
