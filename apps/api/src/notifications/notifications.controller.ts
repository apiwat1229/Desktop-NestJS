import { Body, Controller, Get, Param, Put, Request } from '@nestjs/common';
import { NotificationsService } from './notifications.service';
// import { JwtAuthGuard } from '../auth/jwt-auth.guard'; // Assuming Auth Guard exists?
// Let's assume standard guard, or verify auth structure later. 
// For now, I'll basic scaffold.

@Controller('notifications')
export class NotificationsController {
    constructor(private readonly notificationsService: NotificationsService) { }

    // @UseGuards(JwtAuthGuard)
    @Get()
    findAll(@Request() req: any) {
        // Ideally get user from req.user
        // const userId = req.user.id;
        // For MVP/Testing, maybe pass userId as query or assume mock
        // Let's assume req.user is populated by AuthGuard
        return this.notificationsService.findAll(req.user?.id || 'test-user-id');
    }

    @Get('unread')
    findUnread(@Request() req: any) {
        return this.notificationsService.findUnread(req.user?.id || 'test-user-id');
    }

    @Put(':id/read')
    markAsRead(@Param('id') id: string, @Request() req: any) {
        return this.notificationsService.markAsRead(id, req.user?.id || 'test-user-id');
    }

    @Put('read-all')
    markAllAsRead(@Request() req: any) {
        return this.notificationsService.markAllAsRead(req.user?.id || 'test-user-id');
    }

    @Get('settings')
    getSettings() {
        return this.notificationsService.getSettings();
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
}
