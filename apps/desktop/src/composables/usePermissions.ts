import { useAuthStore } from '@/stores/auth';
import { computed } from 'vue';

/**
 * Composable for permission checking
 */
export function usePermissions() {
    const authStore = useAuthStore();

    /**
     * Check if user has a specific permission
     */
    const hasPermission = (permission: string): boolean => {
        return authStore.hasPermission(permission);
    };

    /**
     * Check if user has ANY of the specified permissions
     */
    const hasAnyPermission = (permissions: string[]): boolean => {
        return authStore.hasAnyPermission(permissions);
    };

    /**
     * Check if user has ALL of the specified permissions
     */
    const hasAllPermissions = (permissions: string[]): boolean => {
        return authStore.hasAllPermissions(permissions);
    };

    /**
     * Check if user is admin (has all permissions)
     */
    const isAdmin = computed(() => {
        const role = authStore.user?.role;
        return role === 'ADMIN' || role === 'admin' || role === 'Administrator';
    });

    /**
     * Get all user permissions
     */
    const permissions = computed(() => authStore.userPermissions);

    return {
        hasPermission,
        hasAnyPermission,
        hasAllPermissions,
        isAdmin,
        permissions
    };
}
