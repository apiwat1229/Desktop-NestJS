import { SetMetadata } from '@nestjs/common';

/**
 * Decorator to specify required permissions for a route
 * @param permissions - Array of permission strings required to access the route
 * 
 * @example
 * @Permissions('users:read', 'users:update')
 * @Get()
 * findAll() { ... }
 */
export const Permissions = (...permissions: string[]) => SetMetadata('permissions', permissions);
