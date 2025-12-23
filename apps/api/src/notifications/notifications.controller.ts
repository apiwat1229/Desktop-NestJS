import { Body, Controller, Delete, Get, Param, Post, Put, Request, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { NotificationsService } from './notifications.service';

@Controller('notifications')
@UseGuards(JwtAuthGuard) // Apply authentication to all routes
export class NotificationsController {
    constructor(private readonly notificationsService: NotificationsService) { }

    @Get()
    findAll(@Request() req: any) {
        return this.notificationsService.findAll(req.user.userId);
    }

    @Get('unread')
    findUnread(@Request() req: any) {
        return this.notificationsService.findUnread(req.user.userId);
    }

    @Put(':id/read')
    markAsRead(@Param('id') id: string, @Request() req: any) {
        return this.notificationsService.markAsRead(id, req.user.userId);
    }

    @Delete(':id')
    delete(@Param('id') id: string, @Request() req: any) {
        return this.notificationsService.delete(id, req.user.userId);
    }

    @Put('read-all')
    markAllAsRead(@Request() req: any) {
        return this.notificationsService.markAllAsRead(req.user.userId);
    }

    @Get('settings')
    getSettings() {
        return this.notificationsService.getSettings();
    }

    @Post('broadcast')
    broadcast(@Body() body: {
        title: string;
        message: string;
        type?: 'INFO' | 'SUCCESS' | 'WARNING' | 'ERROR';
        recipientRoles?: string[];
        recipientUsers?: string[];
        recipientGroups?: string[];
    }, @Request() req: any) {
        return this.notificationsService.broadcast({
            ...body,
            senderId: req.user?.userId
        });
    }

    @Get('history')
    getBroadcastHistory() {
        return this.notificationsService.getBroadcastHistory();
    }

    @Put('settings')
    updateSetting(@Body() body: {
        sourceApp: string;
        actionType: string;
        isActive?: boolean;
        recipientRoles?: string[];
        recipientUsers?: string[];
        channels?: string[];
    }) {
        return this.notificationsService.updateSetting(
            body.sourceApp,
            body.actionType,
            {
                isActive: body.isActive,
                recipientRoles: body.recipientRoles,
                recipientUsers: body.recipientUsers,
                channels: body.channels,
            }
        );
    }

    @Get('groups')
    getGroups() {
        return this.notificationsService.findAllGroups();
    }

    @Post('groups')
    createGroup(@Body() body: { name: string; description?: string; memberIds?: string[] }) {
        return this.notificationsService.createGroup(body);
    }

    @Put('groups/:id')
    updateGroup(@Param('id') id: string, @Body() body: { name?: string; description?: string; memberIds?: string[] }) {
        return this.notificationsService.updateGroup(id, body);
    }

    @Delete('groups/:id')
    deleteGroup(@Param('id') id: string) {
        return this.notificationsService.deleteGroup(id);
    }

    @Delete('broadcast/:id')
    deleteBroadcast(@Param('id') id: string) {
        return this.notificationsService.deleteBroadcast(id);
    }

    @Delete('broadcast')
    deleteBroadcasts(@Body() body: { ids: string[] }) {
        return this.notificationsService.deleteBroadcasts(body.ids);
    }
}
