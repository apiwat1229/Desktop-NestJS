/**
 * Permission constants for the application
 * Format: resource:action or resource:action:modifier
 */

// Users Permissions
export const USERS_READ = 'users:read';
export const USERS_CREATE = 'users:create';
export const USERS_UPDATE = 'users:update';
export const USERS_DELETE = 'users:delete';

// Suppliers Permissions
export const SUPPLIERS_READ = 'suppliers:read';
export const SUPPLIERS_CREATE = 'suppliers:create';
export const SUPPLIERS_UPDATE = 'suppliers:update';
export const SUPPLIERS_UPDATE_REQUEST = 'suppliers:update:request';
export const SUPPLIERS_DELETE = 'suppliers:delete';
export const SUPPLIERS_DELETE_REQUEST = 'suppliers:delete:request';
export const SUPPLIERS_APPROVE = 'suppliers:approve';

// Rubber Types Permissions
export const RUBBER_TYPES_READ = 'rubberTypes:read';
export const RUBBER_TYPES_CREATE = 'rubberTypes:create';
export const RUBBER_TYPES_UPDATE = 'rubberTypes:update';
export const RUBBER_TYPES_UPDATE_REQUEST = 'rubberTypes:update:request';
export const RUBBER_TYPES_DELETE = 'rubberTypes:delete';
export const RUBBER_TYPES_DELETE_REQUEST = 'rubberTypes:delete:request';
export const RUBBER_TYPES_APPROVE = 'rubberTypes:approve';

// Approvals Permissions
export const APPROVALS_VIEW = 'approvals:view';
export const APPROVALS_APPROVE = 'approvals:approve';
export const APPROVALS_REJECT = 'approvals:reject';

// Notifications Permissions
export const NOTIFICATIONS_READ = 'notifications:read';
export const NOTIFICATIONS_CREATE = 'notifications:create';
export const NOTIFICATIONS_DELETE = 'notifications:delete';

// Roles Permissions
export const ROLES_READ = 'roles:read';
export const ROLES_CREATE = 'roles:create';
export const ROLES_UPDATE = 'roles:update';
export const ROLES_DELETE = 'roles:delete';

// Bookings Permissions
export const BOOKINGS_READ = 'bookings:read';
export const BOOKINGS_CREATE = 'bookings:create';
export const BOOKINGS_UPDATE = 'bookings:update';
export const BOOKINGS_DELETE = 'bookings:delete';

// Analytics Permissions
export const ANALYTICS_VIEW = 'analytics:view';

/**
 * Permission groups for UI display
 */
export const PERMISSION_GROUPS = {
    'User Management': [
        { value: USERS_READ, label: 'View Users' },
        { value: USERS_CREATE, label: 'Create Users' },
        { value: USERS_UPDATE, label: 'Update Users' },
        { value: USERS_DELETE, label: 'Delete Users' },
    ],
    'Suppliers': [
        { value: SUPPLIERS_READ, label: 'View Suppliers' },
        { value: SUPPLIERS_CREATE, label: 'Create Suppliers' },
        { value: SUPPLIERS_UPDATE, label: 'Update Suppliers' },
        { value: SUPPLIERS_UPDATE_REQUEST, label: 'Request Updates' },
        { value: SUPPLIERS_DELETE, label: 'Delete Suppliers' },
        { value: SUPPLIERS_DELETE_REQUEST, label: 'Request Deletions' },
        { value: SUPPLIERS_APPROVE, label: 'Approve Changes' },
    ],
    'Rubber Types': [
        { value: RUBBER_TYPES_READ, label: 'View Rubber Types' },
        { value: RUBBER_TYPES_CREATE, label: 'Create Rubber Types' },
        { value: RUBBER_TYPES_UPDATE, label: 'Update Rubber Types' },
        { value: RUBBER_TYPES_UPDATE_REQUEST, label: 'Request Updates' },
        { value: RUBBER_TYPES_DELETE, label: 'Delete Rubber Types' },
        { value: RUBBER_TYPES_DELETE_REQUEST, label: 'Request Deletions' },
        { value: RUBBER_TYPES_APPROVE, label: 'Approve Changes' },
    ],
    'Approvals': [
        { value: APPROVALS_VIEW, label: 'View Approvals' },
        { value: APPROVALS_APPROVE, label: 'Approve Requests' },
        { value: APPROVALS_REJECT, label: 'Reject Requests' },
    ],
    'Notifications': [
        { value: NOTIFICATIONS_READ, label: 'View Notifications' },
        { value: NOTIFICATIONS_CREATE, label: 'Create Notifications' },
        { value: NOTIFICATIONS_DELETE, label: 'Delete Notifications' },
    ],
    'Roles & Permissions': [
        { value: ROLES_READ, label: 'View Roles' },
        { value: ROLES_CREATE, label: 'Create Roles' },
        { value: ROLES_UPDATE, label: 'Update Roles' },
        { value: ROLES_DELETE, label: 'Delete Roles' },
    ],
    'Booking Queue': [
        { value: BOOKINGS_READ, label: 'View Bookings' },
        { value: BOOKINGS_CREATE, label: 'Create Bookings' },
        { value: BOOKINGS_UPDATE, label: 'Update Bookings' },
        { value: BOOKINGS_DELETE, label: 'Delete Bookings' },
    ],
    'Analytics': [
        { value: ANALYTICS_VIEW, label: 'View Analytics' },
    ],
};

/**
 * All permissions as array
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
