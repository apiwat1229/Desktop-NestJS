import { Activity, Calendar, CreditCard, DollarSign, Download, Users } from 'lucide-react';
import { useTranslation } from 'react-i18next';
import AdminLayout from '../components/AdminLayout';

export default function AdminPanel() {
  const { t } = useTranslation();
  return (
    <AdminLayout>
      <div className="p-6 w-full max-w-[1400px] mx-auto space-y-8">
        <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 mb-8">
          <div>
            <h2 className="text-3xl font-bold tracking-tight text-foreground">
              {t('admin.dashboard.title')}
            </h2>
            <p className="text-muted-foreground mt-1">{t('admin.dashboard.subtitle')}</p>
          </div>
          <div className="flex items-center gap-2">
            <button className="inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50 border border-input bg-background shadow-sm hover:bg-accent hover:text-accent-foreground h-9 px-4 py-2 text-foreground">
              <Calendar className="mr-2 h-4 w-4" />
              <span>Jan 20, 2024 - Feb 09, 2024</span>
            </button>
            <button className="inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50 bg-primary text-primary-foreground shadow hover:bg-primary/90 h-9 px-4 py-2">
              <Download className="mr-2 h-4 w-4" />
              {t('admin.dashboard.download')}
            </button>
          </div>
        </div>

        {/* Tabs */}
        <div className="space-y-4">
          <div className="inline-flex h-9 items-center justify-center rounded-lg bg-muted p-1 text-muted-foreground w-full sm:w-auto">
            <button className="inline-flex items-center justify-center whitespace-nowrap rounded-md px-3 py-1 text-sm font-medium ring-offset-background transition-all focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 bg-background text-foreground shadow">
              {t('admin.dashboard.tabs.overview')}
            </button>
            <button className="inline-flex items-center justify-center whitespace-nowrap rounded-md px-3 py-1 text-sm font-medium ring-offset-background transition-all focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 hover:bg-background/50 hover:text-foreground">
              {t('admin.dashboard.tabs.analytics')}
            </button>
            <button className="inline-flex items-center justify-center whitespace-nowrap rounded-md px-3 py-1 text-sm font-medium ring-offset-background transition-all focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 hover:bg-background/50 hover:text-foreground">
              {t('admin.dashboard.tabs.reports')}
            </button>
            <button className="inline-flex items-center justify-center whitespace-nowrap rounded-md px-3 py-1 text-sm font-medium ring-offset-background transition-all focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 hover:bg-background/50 hover:text-foreground">
              {t('admin.dashboard.tabs.notifications')}
            </button>
          </div>

          {/* Metrics Cards */}
          <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
            <div className="rounded-xl border border-border bg-card text-card-foreground shadow p-6">
              <div className="flex flex-row items-center justify-between pb-2">
                <h3 className="tracking-tight text-sm font-medium">
                  {t('admin.dashboard.metrics.revenue')}
                </h3>
                <DollarSign className="h-4 w-4 text-muted-foreground" />
              </div>
              <div className="text-2xl font-bold">$45,231.89</div>
              <p className="text-xs text-muted-foreground mt-1">
                +20.1% {t('admin.dashboard.metrics.fromLastMonth')}
              </p>
            </div>

            <div className="rounded-xl border border-border bg-card text-card-foreground shadow p-6">
              <div className="flex flex-row items-center justify-between pb-2">
                <h3 className="tracking-tight text-sm font-medium">
                  {t('admin.dashboard.metrics.subscriptions')}
                </h3>
                <Users className="h-4 w-4 text-muted-foreground" />
              </div>
              <div className="text-2xl font-bold">+2350</div>
              <p className="text-xs text-muted-foreground mt-1">
                +180.1% {t('admin.dashboard.metrics.fromLastMonth')}
              </p>
            </div>

            <div className="rounded-xl border border-border bg-card text-card-foreground shadow p-6">
              <div className="flex flex-row items-center justify-between pb-2">
                <h3 className="tracking-tight text-sm font-medium">
                  {t('admin.dashboard.metrics.sales')}
                </h3>
                <CreditCard className="h-4 w-4 text-muted-foreground" />
              </div>
              <div className="text-2xl font-bold">+12,234</div>
              <p className="text-xs text-muted-foreground mt-1">
                +19% {t('admin.dashboard.metrics.fromLastMonth')}
              </p>
            </div>

            <div className="rounded-xl border border-border bg-card text-card-foreground shadow p-6">
              <div className="flex flex-row items-center justify-between pb-2">
                <h3 className="tracking-tight text-sm font-medium">
                  {t('admin.dashboard.metrics.activeNow')}
                </h3>
                <Activity className="h-4 w-4 text-muted-foreground" />
              </div>
              <div className="text-2xl font-bold">+573</div>
              <p className="text-xs text-muted-foreground mt-1">
                +201 {t('admin.dashboard.metrics.sinceLastHour')}
              </p>
            </div>
          </div>

          {/* Main Chart & Recent Sales */}
          <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-7">
            {/* Visual Chart */}
            <div className="col-span-4 rounded-xl border border-border bg-card text-card-foreground shadow">
              <div className="p-6 pb-4">
                <h3 className="font-semibold leading-none tracking-tight">
                  {t('admin.dashboard.tabs.overview')}
                </h3>
              </div>
              <div className="p-6 pt-0">
                <div className="h-[300px] w-full flex items-end justify-between gap-2 px-2">
                  {[35, 78, 45, 90, 60, 48, 85, 30, 65, 55, 80, 40].map((height, i) => (
                    <div
                      key={i}
                      className="group relative flex-1 bg-primary/10 hover:bg-primary/20 rounded-t-sm transition-all h-full flex items-end"
                    >
                      <div
                        className="w-full bg-primary rounded-t-sm transition-all group-hover:bg-primary/80"
                        style={{ height: `${height}%` }}
                      />
                    </div>
                  ))}
                </div>
              </div>
            </div>

            {/* Recent Sales List */}
            <div className="col-span-3 rounded-xl border border-border bg-card text-card-foreground shadow">
              <div className="p-6 pb-4">
                <h3 className="font-semibold leading-none tracking-tight">
                  {t('admin.dashboard.recentSales.title')}
                </h3>
                <p className="text-sm text-muted-foreground">
                  {t('admin.dashboard.recentSales.subtitle', { count: 265 })}
                </p>
              </div>
              <div className="p-6 pt-0 space-y-6">
                {[
                  {
                    name: 'Olivia Martin',
                    email: 'olivia.martin@email.com',
                    amount: '+$1,999.00',
                    initials: 'OM',
                  },
                  {
                    name: 'Jackson Lee',
                    email: 'jackson.lee@email.com',
                    amount: '+$39.00',
                    initials: 'JL',
                  },
                  {
                    name: 'Isabella Nguyen',
                    email: 'isabella.nguyen@email.com',
                    amount: '+$299.00',
                    initials: 'IN',
                  },
                  {
                    name: 'William Kim',
                    email: 'will@email.com',
                    amount: '+$99.00',
                    initials: 'WK',
                  },
                  {
                    name: 'Sofia Davis',
                    email: 'sofia.davis@email.com',
                    amount: '+$39.00',
                    initials: 'SD',
                  },
                ].map((user, i) => (
                  <div key={i} className="flex items-center">
                    <div className="h-9 w-9 rounded-full bg-primary/10 flex items-center justify-center text-xs font-medium text-primary">
                      {user.initials}
                    </div>
                    <div className="ml-4 space-y-1">
                      <p className="text-sm font-medium leading-none">{user.name}</p>
                      <p className="text-sm text-muted-foreground">{user.email}</p>
                    </div>
                    <div className="ml-auto font-medium text-sm">{user.amount}</div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </div>
    </AdminLayout>
  );
}
