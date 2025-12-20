import { Layers, Search } from 'lucide-react';
import { useRouter } from 'next/router';
import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { toast } from 'sonner';
import AdminLayout from '../../../components/AdminLayout';
import { Button } from '../../../components/ui/button';
import { Card } from '../../../components/ui/card';
import { Input } from '../../../components/ui/input';
import { accessControlApi } from '../../../lib/api';

export default function AppsPage() {
  const router = useRouter();
  const { t } = useTranslation();
  const [apps, setApps] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');

  const fetchApps = async () => {
    try {
      setIsLoading(true);
      const data = await accessControlApi.getApps();
      setApps(data);
    } catch (error) {
      console.error('Failed to fetch apps:', error);
      toast.error(t('common.error'), {
        description: t('common.errorLoading'),
      });
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchApps();
  }, []);

  const filteredApps = apps.filter((app) =>
    app.name.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <AdminLayout>
      <div className="p-6 w-full max-w-[1400px] mx-auto space-y-8">
        {/* Header */}
        <div className="flex flex-col md:flex-row items-center justify-between gap-4">
          <div>
            <h1 className="text-2xl font-bold tracking-tight text-foreground">
              {t('admin.apps.title', 'App Permission Management')}
            </h1>
            <p className="text-sm text-muted-foreground mt-1">
              {t('admin.apps.subtitle', 'Manage user access permissions per application.')}
            </p>
          </div>
        </div>

        {/* Search */}
        <div className="relative max-w-sm">
          <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
          <Input
            type="search"
            placeholder={t('admin.apps.search', 'Search apps...')}
            className="pl-8"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>

        {/* App Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredApps.map((app) => (
            <Card
              key={app.id}
              className="p-6 hover:shadow-lg transition-all cursor-pointer group"
              onClick={() => router.push(`/admin/apps/${app.id}`)}
            >
              <div className="flex items-start justify-between">
                <div className="flex items-center gap-4">
                  <div className="p-3 rounded-lg bg-blue-50 dark:bg-blue-900/20 text-blue-600 dark:text-blue-400 group-hover:scale-105 transition-transform">
                    <Layers className="w-8 h-8" />
                  </div>
                  <div>
                    <h3 className="font-bold text-lg">{app.name}</h3>
                    <p className="text-sm text-muted-foreground line-clamp-1">{app.description}</p>
                  </div>
                </div>
              </div>

              <div className="mt-6 flex justify-end">
                <Button
                  variant="outline"
                  className="group-hover:bg-primary group-hover:text-primary-foreground"
                >
                  {t('admin.apps.manage', 'Manage Permissions')}
                </Button>
              </div>
            </Card>
          ))}

          {filteredApps.length === 0 && !isLoading && (
            <div className="col-span-full py-12 text-center text-muted-foreground bg-muted/20 rounded-lg border border-dashed border-border">
              {t('common.noData')}
            </div>
          )}
        </div>
      </div>
    </AdminLayout>
  );
}
