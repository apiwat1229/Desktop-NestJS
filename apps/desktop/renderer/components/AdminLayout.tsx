import {
  Activity,
  Bell,
  ClipboardCheck,
  Layers,
  LayoutDashboard,
  Shield,
  Truck,
} from 'lucide-react';
import { useRouter } from 'next/router';
import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { usePermission } from '../hooks/usePermission';
import AnimatedBackground from './AnimatedBackground';
import Navbar from './Navbar';
import { Spinner } from './ui/spinner';

interface AdminLayoutProps {
  children: React.ReactNode;
}

export default function AdminLayout({ children }: AdminLayoutProps) {
  const router = useRouter();
  const { t } = useTranslation();
  const [isAdmin, setIsAdmin] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const checkAdmin = () => {
      try {
        const userStr = localStorage.getItem('user');
        if (!userStr) {
          router.push('/login');
          return;
        }

        const user = JSON.parse(userStr);
        // Allow any user with a role to enter the admin layout
        // Granular permissions (implemented below) will protect specific routes
        if (user && user.role) {
          setIsAdmin(true);
        } else {
          router.push('/login');
        }
      } catch (e) {
        console.error('Error verifying user', e);
        router.push('/login');
      } finally {
        setLoading(false);
      }
    };

    checkAdmin();
  }, [router]);

  const { can } = usePermission();

  // Route protection
  useEffect(() => {
    if (loading || !isAdmin) return;

    const path = router.pathname;

    // Define route to permission mapping
    const routePermissions: Record<string, string> = {
      '/admin/roles': 'roles',
      '/admin/suppliers': 'suppliers',
      '/admin/rubber-types': 'rubber_types',
      '/admin/notifications': 'notifications',
      '/admin/booking': 'booking_queue', // Assuming this is the path and module ID
    };

    // Check strict match or startsWith for nested routes if needed
    const requiredModule = routePermissions[path];

    if (requiredModule && !can('read', requiredModule)) {
      console.warn(`Access denied to ${path}. Missing permission for ${requiredModule}`);
      router.replace('/admin'); // Redirect to dashboard or 403 page
    }
  }, [router.pathname, loading, isAdmin, can]);

  if (loading) {
    return (
      <div className="min-h-screen bg-background flex flex-col items-center justify-center">
        <AnimatedBackground />
        <div className="relative z-10">
          <Spinner size="xl" />
        </div>
      </div>
    );
  }

  if (!isAdmin) return null;

  const menuItems = [
    { icon: LayoutDashboard, label: t('admin.sidebar.dashboard'), path: '/admin', show: true },
    {
      icon: Shield,
      label: t('admin.sidebar.roles'),
      path: '/admin/roles',
      show: can('read', 'roles'),
    },
    {
      icon: Truck,
      label: t('admin.sidebar.suppliers'),
      path: '/admin/suppliers',
      show: can('read', 'suppliers'),
    },
    {
      icon: Layers,
      label: t('admin.sidebar.rubberTypes'),
      path: '/admin/rubber-types',
      show: can('read', 'rubber_types'),
    },
    {
      icon: Bell,
      label: t('admin.sidebar.notifications'),
      path: '/admin/notifications',
      show: can('read', 'notifications'),
    },
    {
      icon: ClipboardCheck, // Make sure to import ClipboardCheck
      label: t('admin.sidebar.approvals', 'Approvals'), // effective fall back
      path: '/admin/approvals',
      show: can('read', 'approvals') || isAdmin, // Temporary: Allow all admins for now
    },
  ].filter((item) => item.show);

  return (
    <div className="h-screen overflow-hidden bg-background flex flex-col">
      <Navbar />

      <div className="flex flex-1 overflow-hidden relative">
        {/* Sidebar */}
        <aside className="w-64 border-r border-border bg-card/50 backdrop-blur-xl flex flex-col z-20 overflow-y-auto hidden md:flex">
          <div className="p-4 space-y-6">
            <div>
              <h4 className="px-2 text-xs font-semibold text-muted-foreground uppercase tracking-wider mb-2">
                {t('admin.sidebar.main')}
              </h4>
              {menuItems.map((item) => (
                <button
                  key={item.path}
                  onClick={() => router.push(item.path)}
                  className={`w-full flex items-center gap-3 px-3 py-2 text-sm font-medium rounded-md transition-colors ${
                    router.pathname === item.path
                      ? 'bg-primary/10 text-primary'
                      : 'text-muted-foreground hover:bg-muted hover:text-foreground'
                  }`}
                >
                  <item.icon size={18} />
                  {item.label}
                </button>
              ))}
            </div>

            <div>
              <h4 className="px-2 text-xs font-semibold text-muted-foreground uppercase tracking-wider mb-2">
                {t('admin.sidebar.system')}
              </h4>
              <button
                onClick={() => router.push('/admin/analytics')}
                className={`w-full flex items-center gap-3 px-3 py-2 text-sm font-medium rounded-md transition-colors ${
                  router.pathname === '/admin/analytics'
                    ? 'bg-primary/10 text-primary'
                    : 'text-muted-foreground hover:bg-muted hover:text-foreground'
                }`}
              >
                <Activity size={18} />
                {t('admin.sidebar.analytics')}
              </button>
            </div>
          </div>
        </aside>

        {/* Main Content */}
        <main className="flex-1 overflow-y-auto bg-background/50 relative">
          <div className="absolute inset-0 pointer-events-none">
            <AnimatedBackground />
          </div>
          {children}
        </main>
      </div>
    </div>
  );
}
