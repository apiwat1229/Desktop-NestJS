import { Body, Controller, Delete, Get, Param, Patch, Post, Query, UseGuards } from '@nestjs/common';
import { ApprovalsService } from '../approvals/approvals.service';
import {
    RUBBER_TYPES_CREATE,
    RUBBER_TYPES_DELETE,
    RUBBER_TYPES_DELETE_REQUEST,
    RUBBER_TYPES_READ,
    RUBBER_TYPES_UPDATE,
    RUBBER_TYPES_UPDATE_REQUEST
} from '../auth/constants/permissions';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { Permissions } from '../auth/decorators/permissions.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { PermissionsGuard } from '../auth/guards/permissions.guard';
import { RubberTypesService } from './rubber-types.service';

@Controller('rubber-types')
@UseGuards(JwtAuthGuard, PermissionsGuard)
export class RubberTypesController {
    constructor(
        private readonly rubberTypesService: RubberTypesService,
        private readonly approvalsService: ApprovalsService,
    ) { }

    @Post()
    @Permissions(RUBBER_TYPES_CREATE)
    create(@Body() createRubberTypeDto: any) {
        return this.rubberTypesService.create(createRubberTypeDto);
    }

    @Get()
    @Permissions(RUBBER_TYPES_READ)
    findAll(@Query('includeDeleted') includeDeleted?: string) {
        return this.rubberTypesService.findAll(includeDeleted === 'true');
    }

    @Get(':id')
    @Permissions(RUBBER_TYPES_READ)
    findOne(@Param('id') id: string) {
        return this.rubberTypesService.findOne(id);
    }

    @Patch(':id')
    @Permissions(RUBBER_TYPES_UPDATE)
    update(@Param('id') id: string, @Body() updateRubberTypeDto: any) {
        return this.rubberTypesService.update(id, updateRubberTypeDto);
    }

    @Delete(':id')
    @Permissions(RUBBER_TYPES_DELETE)
    remove(@Param('id') id: string) {
        return this.rubberTypesService.remove(id);
    }

    // ==================== Approval Workflow ====================

    @Post(':id/update-request')
    @Permissions(RUBBER_TYPES_UPDATE_REQUEST)
    async requestUpdate(
        @Param('id') id: string,
        @Body() updateDto: any,
        @CurrentUser() user: any,
    ) {
        const currentData = await this.rubberTypesService.findOne(id);

        return this.approvalsService.createRequest(user.id, {
            requestType: 'RUBBER_TYPE_UPDATE',
            entityType: 'RubberType',
            entityId: id,
            sourceApp: 'RUBBER_TYPE_MANAGEMENT',
            actionType: 'UPDATE',
            currentData,
            proposedData: updateDto,
            reason: 'Request to update rubber type information',
            priority: 'NORMAL',
        });
    }

    @Post(':id/delete-request')
    @Permissions(RUBBER_TYPES_DELETE_REQUEST)
    async requestDelete(
        @Param('id') id: string,
        @CurrentUser() user: any,
    ) {
        const currentData = await this.rubberTypesService.findOne(id);

        return this.approvalsService.createRequest(user.id, {
            requestType: 'RUBBER_TYPE_DELETE',
            entityType: 'RubberType',
            entityId: id,
            sourceApp: 'RUBBER_TYPE_MANAGEMENT',
            actionType: 'DELETE',
            currentData,
            proposedData: null,
            reason: 'Request to delete rubber type',
            priority: 'NORMAL',
        });
    }

    @Delete(':id/soft')
    @Permissions(RUBBER_TYPES_DELETE)
    async softDelete(@Param('id') id: string, @CurrentUser() user: any) {
        return this.rubberTypesService.softDelete(id, user.id);
    }

    @Post(':id/restore')
    @Permissions(RUBBER_TYPES_UPDATE)
    async restore(@Param('id') id: string) {
        return this.rubberTypesService.restore(id);
    }
}
