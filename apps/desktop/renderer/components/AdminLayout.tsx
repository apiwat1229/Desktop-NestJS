import { Activity, LayoutDashboard, Package, ShoppingBag, Users } from 'lucide-react';
import { useRouter } from 'next/router';
import { useEffect, useState } from 'react';
import AnimatedBackground from './AnimatedBackground';
import Navbar from './Navbar';

interface AdminLayoutProps {
  children: React.ReactNode;
}

export default function AdminLayout({ children }: AdminLayoutProps) {
  const router = useRouter();
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
        <div className="text-foreground text-xl relative z-10">Verifying access...</div>
      </div>
    );
  }

  if (!isAdmin) return null;

  const menuItems = [
    { icon: LayoutDashboard, label: 'Dashboard', path: '/admin' },
    { icon: Users, label: 'Users', path: '/admin/users' },
    { icon: Package, label: 'Products', path: '/admin/products' },
    { icon: ShoppingBag, label: 'Orders', path: '/admin/orders' },
  ];

  return (
    <div className="min-h-screen bg-background flex flex-col font-sans">
      <Navbar />

      <div className="flex flex-1 overflow-hidden relative">
        {/* Sidebar */}
        <aside className="w-64 border-r border-border bg-card/50 backdrop-blur-xl flex flex-col z-20 overflow-y-auto hidden md:flex">
          <div className="p-4 space-y-6">
            <div>
              <h4 className="px-2 text-xs font-semibold text-muted-foreground uppercase tracking-wider mb-2">
                Main
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
                System
              </h4>
              <button className="w-full flex items-center gap-3 px-3 py-2 text-sm font-medium text-muted-foreground hover:bg-muted hover:text-foreground rounded-md transition-colors">
                <Activity size={18} />
                Analytics
              </button>
            </div>
          </div>
        </aside>

        {/* Main Content */}
        <main className="flex-1 overflow-y-auto bg-background/50 relative">
          <div className="absolute inset-0 opacity-20 pointer-events-none">
            <AnimatedBackground />
          </div>
          {children}
        </main>
      </div>
    </div>
  );
}
