import { Body, Controller, Delete, Get, Param, Post } from '@nestjs/common';
import { AccessControlService } from './access-control.service';

@Controller('access-control')
export class AccessControlController {
    constructor(private readonly accessControlService: AccessControlService) { }

    @Get('apps')
    getApps() {
        return this.accessControlService.getApps();
    }

    @Get('apps/:appName/users')
    getAppUsers(@Param('appName') appName: string) {
        return this.accessControlService.getAppUsers(appName);
    }

    @Post('apps/:appName/users')
    assignPermission(
        @Param('appName') appName: string,
        @Body() body: { userId: string; actions: string[] },
    ) {
        return this.accessControlService.assignPermission(appName, body.userId, body.actions);
    }

    @Delete('apps/:appName/users/:userId')
    removePermission(
        @Param('appName') appName: string,
        @Param('userId') userId: string,
    ) {
        return this.accessControlService.removePermission(appName, userId);
    }
}
