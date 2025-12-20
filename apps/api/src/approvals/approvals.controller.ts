import { Body, Controller, Get, Param, Post, Put, Request } from '@nestjs/common';
import { ApprovalsService } from './approvals.service';

@Controller('approvals')
export class ApprovalsController {
    constructor(private readonly approvalsService: ApprovalsService) { }

    @Post()
    create(@Body() body: any, @Request() req: any) {
        return this.approvalsService.createRequest({
            ...body,
            requesterId: req.user?.id || 'test-user-id',
        });
    }

    @Get()
    findAll() {
        return this.approvalsService.findAll();
    }

    @Get('my')
    findMyRequests(@Request() req: any) {
        return this.approvalsService.findMyRequests(req.user?.id || 'test-user-id');
    }

    @Put(':id/approve')
    approve(@Param('id') id: string, @Body() body: { comment?: string }, @Request() req: any) {
        return this.approvalsService.approve(id, req.user?.id || 'admin-id', body.comment);
    }

    @Put(':id/reject')
    reject(@Param('id') id: string, @Body() body: { comment?: string }, @Request() req: any) {
        return this.approvalsService.reject(id, req.user?.id || 'admin-id', body.comment);
    }
}
