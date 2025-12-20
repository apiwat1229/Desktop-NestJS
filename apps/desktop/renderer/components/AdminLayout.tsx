import { Activity, Bell, Layers, LayoutDashboard, Truck, Users } from 'lucide-react';
import { useRouter } from 'next/router';
import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
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
        if (user.role && (user.role === 'admin' || user.role === 'ADMIN')) {
          setIsAdmin(true);
        } else {
          router.push('/posts');
        }
      } catch (e) {
        console.error('Error verifying admin role', e);
        router.push('/login');
      } finally {
        setLoading(false);
      }
    };

    checkAdmin();
  }, [router]);

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
    { icon: LayoutDashboard, label: t('admin.sidebar.dashboard'), path: '/admin' },
    { icon: Users, label: t('admin.sidebar.users'), path: '/admin/users' },
    { icon: Truck, label: t('admin.sidebar.suppliers'), path: '/admin/suppliers' },
    { icon: Layers, label: t('admin.sidebar.rubberTypes'), path: '/admin/rubber-types' },
    { icon: Bell, label: t('admin.sidebar.notifications'), path: '/admin/notifications' },
  ];

  return (
    <div className="min-h-screen bg-background flex flex-col">
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
