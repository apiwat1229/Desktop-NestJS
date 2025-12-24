/**
 * Comprehensive list of all permissions in the system
 * Format: resource:action or resource:action:modifier
 */

// ==================== Users ====================
export const USERS_READ = 'users:read';
export const USERS_CREATE = 'users:create';
export const USERS_UPDATE = 'users:update';
export const USERS_DELETE = 'users:delete';

// ==================== Suppliers ====================
export const SUPPLIERS_READ = 'suppliers:read';
export const SUPPLIERS_CREATE = 'suppliers:create';
export const SUPPLIERS_UPDATE = 'suppliers:update';
export const SUPPLIERS_UPDATE_REQUEST = 'suppliers:update:request';
export const SUPPLIERS_DELETE = 'suppliers:delete';
export const SUPPLIERS_DELETE_REQUEST = 'suppliers:delete:request';
export const SUPPLIERS_APPROVE = 'suppliers:approve';

// ==================== Rubber Types ====================
export const RUBBER_TYPES_READ = 'rubberTypes:read';
export const RUBBER_TYPES_CREATE = 'rubberTypes:create';
export const RUBBER_TYPES_UPDATE = 'rubberTypes:update';
export const RUBBER_TYPES_UPDATE_REQUEST = 'rubberTypes:update:request';
export const RUBBER_TYPES_DELETE = 'rubberTypes:delete';
export const RUBBER_TYPES_DELETE_REQUEST = 'rubberTypes:delete:request';
export const RUBBER_TYPES_APPROVE = 'rubberTypes:approve';

// ==================== Approvals ====================
export const APPROVALS_VIEW = 'approvals:view';
export const APPROVALS_APPROVE = 'approvals:approve';
export const APPROVALS_REJECT = 'approvals:reject';

// ==================== Notifications ====================
export const NOTIFICATIONS_READ = 'notifications:read';
export const NOTIFICATIONS_CREATE = 'notifications:create';
export const NOTIFICATIONS_DELETE = 'notifications:delete';

// ==================== Roles ====================
export const ROLES_READ = 'roles:read';
export const ROLES_CREATE = 'roles:create';
export const ROLES_UPDATE = 'roles:update';
export const ROLES_DELETE = 'roles:delete';

// ==================== Bookings ====================
export const BOOKINGS_READ = 'bookings:read';
export const BOOKINGS_CREATE = 'bookings:create';
export const BOOKINGS_UPDATE = 'bookings:update';
export const BOOKINGS_DELETE = 'bookings:delete';

// ==================== Analytics ====================
export const ANALYTICS_VIEW = 'analytics:view';

/**
 * Get all permissions as an array
 */
export const ALL_PERMISSIONS = [
    USERS_READ, USERS_CREATE, USERS_UPDATE, USERS_DELETE,
    SUPPLIERS_READ, SUPPLIERS_CREATE, SUPPLIERS_UPDATE, SUPPLIERS_UPDATE_REQUEST,
    SUPPLIERS_DELETE, SUPPLIERS_DELETE_REQUEST, SUPPLIERS_APPROVE,
    RUBBER_TYPES_READ, RUBBER_TYPES_CREATE, RUBBER_TYPES_UPDATE, RUBBER_TYPES_UPDATE_REQUEST,
    RUBBER_TYPES_DELETE, RUBBER_TYPES_DELETE_REQUEST, RUBBER_TYPES_APPROVE,
    APPROVALS_VIEW, APPROVALS_APPROVE, APPROVALS_REJECT,
    NOTIFICATIONS_READ, NOTIFICATIONS_CREATE, NOTIFICATIONS_DELETE,
    ROLES_READ, ROLES_CREATE, ROLES_UPDATE, ROLES_DELETE,
    BOOKINGS_READ, BOOKINGS_CREATE, BOOKINGS_UPDATE, BOOKINGS_DELETE,
    ANALYTICS_VIEW
];

/**
 * Permission groups for easier management
 */
export const PERMISSION_GROUPS = {
    USERS: [USERS_READ, USERS_CREATE, USERS_UPDATE, USERS_DELETE],
    SUPPLIERS: [
        SUPPLIERS_READ, SUPPLIERS_CREATE, SUPPLIERS_UPDATE, SUPPLIERS_UPDATE_REQUEST,
        SUPPLIERS_DELETE, SUPPLIERS_DELETE_REQUEST, SUPPLIERS_APPROVE
    ],
    RUBBER_TYPES: [
        RUBBER_TYPES_READ, RUBBER_TYPES_CREATE, RUBBER_TYPES_UPDATE, RUBBER_TYPES_UPDATE_REQUEST,
        RUBBER_TYPES_DELETE, RUBBER_TYPES_DELETE_REQUEST, RUBBER_TYPES_APPROVE
    ],
    APPROVALS: [APPROVALS_VIEW, APPROVALS_APPROVE, APPROVALS_REJECT],
    NOTIFICATIONS: [NOTIFICATIONS_READ, NOTIFICATIONS_CREATE, NOTIFICATIONS_DELETE],
    ROLES: [ROLES_READ, ROLES_CREATE, ROLES_UPDATE, ROLES_DELETE],
    BOOKINGS: [BOOKINGS_READ, BOOKINGS_CREATE, BOOKINGS_UPDATE, BOOKINGS_DELETE],
    ANALYTICS: [ANALYTICS_VIEW]
};
