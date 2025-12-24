import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { Observable } from 'rxjs';

@Injectable()
export class PermissionsGuard implements CanActivate {
    constructor(private reflector: Reflector) { }

    canActivate(
        context: ExecutionContext,
    ): boolean | Promise<boolean> | Observable<boolean> {
        // Get required permissions from decorator
        const requiredPermissions = this.reflector.getAllAndOverride<string[]>('permissions', [
            context.getHandler(),
            context.getClass(),
        ]);

        // If no permissions required, allow access
        if (!requiredPermissions || requiredPermissions.length === 0) {
            return true;
        }

        const request = context.switchToHttp().getRequest();
        const user = request.user;

        // If no user, deny access
        if (!user) {
            return false;
        }

        // Admin role has all permissions
        if (user.role === 'ADMIN' || user.role === 'admin' || user.role === 'Administrator') {
            return true;
        }

        // Check if user has required permissions
        const userPermissions = user.permissions || [];

        // User must have ALL required permissions
        return requiredPermissions.every(permission =>
            userPermissions.includes(permission)
        );
    }
}
