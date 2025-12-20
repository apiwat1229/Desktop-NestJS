import { BellRing, Loader2, Save } from 'lucide-react';
import Head from 'next/head';
import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { toast } from 'sonner';
import AdminLayout from '../../components/AdminLayout';
import { Badge } from '../../components/ui/badge';
import { Button } from '../../components/ui/button';
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from '../../components/ui/card';
import { Switch } from '../../components/ui/switch';
import { api, rolesApi, usersApi } from '../../lib/api';

interface NotificationSetting {
  id?: string;
  sourceApp: string; // e.g., 'Booking', 'User'
  actionType: string; // e.g., 'CREATE', 'UPDATE', 'DELETE'
  isActive: boolean;
  recipientRoles: string[]; // Role IDs
  recipientUsers: string[]; // User IDs
}

interface Role {
  id: string;
  name: string;
}

interface User {
  id: string;
  name: string;
  email: string;
}

// Defined System Events
const SYSTEM_EVENTS = [
  { source: 'Booking', action: 'CREATE', label: 'New Booking' },
  { source: 'Booking', action: 'UPDATE', label: 'Booking Updated' },
  { source: 'Booking', action: 'DELETE', label: 'Booking Cancelled/Deleted' },
  { source: 'User', action: 'CREATE', label: 'New User Registration' },
  { source: 'System', action: 'ERROR', label: 'System Errors' },
];

export default function NotificationSettingsPage() {
  const { t } = useTranslation();
  const [settings, setSettings] = useState<NotificationSetting[]>([]);
  const [roles, setRoles] = useState<Role[]>([]);
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    try {
      setLoading(true);
      const [settingsRes, rolesRes, usersRes] = await Promise.all([
        api.get('/notifications/settings'),
        rolesApi.getAll(),
        usersApi.getAll(),
      ]);

      setSettings(settingsRes.data);
      setRoles(rolesRes);
      setUsers(usersRes);
    } catch (error) {
      console.error('Failed to fetch data', error);
      toast.error(t('common.errorLoading', 'Failed to load settings'));
    } finally {
      setLoading(false);
    }
  };

  const getSetting = (source: string, action: string) => {
    return (
      settings.find((s) => s.sourceApp === source && s.actionType === action) || {
        sourceApp: source,
        actionType: action,
        isActive: true,
        recipientRoles: [],
        recipientUsers: [],
      }
    );
  };

  const handleUpdate = (source: string, action: string, updates: Partial<NotificationSetting>) => {
    setSettings((prev) => {
      const existingIndex = prev.findIndex(
        (s) => s.sourceApp === source && s.actionType === action
      );
      if (existingIndex >= 0) {
        const newSettings = [...prev];
        newSettings[existingIndex] = { ...newSettings[existingIndex], ...updates };
        return newSettings;
      } else {
        return [
          ...prev,
          {
            sourceApp: source,
            actionType: action,
            isActive: true, // Default
            recipientRoles: [],
            recipientUsers: [],
            ...updates,
          } as NotificationSetting,
        ];
      }
    });
  };

  const handleSave = async () => {
    try {
      setSaving(true);
      // Save each setting that has changed (or all for simplicity in this MVP)
      // Ideally we track dirty state, but let's just loop locally modified settings.
      // Since backend upserts, we can just iterate SYSTEM_EVENTS and save their current state

      const promises = SYSTEM_EVENTS.map((event) => {
        const setting = getSetting(event.source, event.action);
        return api.put('/notifications/settings', {
          sourceApp: event.source,
          actionType: event.action,
          isActive: setting.isActive,
          recipientRoles: setting.recipientRoles,
          recipientUsers: setting.recipientUsers,
        });
      });

      await Promise.all(promises);
      toast.success(t('common.saved', 'Settings saved successfully'));
    } catch (error) {
      console.error('Failed to save', error);
      toast.error(t('common.errorSave', 'Failed to save settings'));
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <AdminLayout>
        <div className="flex items-center justify-center h-96">
          <Loader2 className="w-8 h-8 animate-spin text-primary" />
        </div>
      </AdminLayout>
    );
  }

  const roleOptions = roles.map((r) => ({ label: r.name, value: r.id }));
  // const userOptions = users.map(u => ({ label: u.name || u.email, value: u.id }));
  // Note: MultiSelect might need specific format. Adapting logic inline if needed.

  return (
    <AdminLayout>
      <Head>
        <title>{t('admin.notificationSettings.title', 'Notification Rules')} | Admin</title>
      </Head>

      <div className="p-6 w-full max-w-[1400px] mx-auto space-y-6">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-4">
            <div className="p-3 bg-purple-50 rounded-xl">
              <BellRing className="h-6 w-6 text-purple-600" />
            </div>
            <div>
              <h1 className="text-2xl font-bold tracking-tight">
                {t('admin.notificationSettings.title', 'Notification Rules')}
              </h1>
              <p className="text-sm text-muted-foreground">
                {t(
                  'admin.notificationSettings.subtitle',
                  'Configure who receives alerts for system events.'
                )}
              </p>
            </div>
          </div>
          <Button onClick={handleSave} disabled={saving}>
            {saving ? (
              <Loader2 className="mr-2 h-4 w-4 animate-spin" />
            ) : (
              <Save className="mr-2 h-4 w-4" />
            )}
            {t('common.saveChanges', 'Save Changes')}
          </Button>
        </div>

        <div className="grid gap-6">
          {SYSTEM_EVENTS.map((event) => {
            const setting = getSetting(event.source, event.action);

            return (
              <Card key={`${event.source}-${event.action}`} className="overflow-hidden">
                <CardHeader className="bg-muted/30 pb-4">
                  <div className="flex items-center justify-between">
                    <div className="space-y-1">
                      <CardTitle className="text-base flex items-center gap-2">
                        {event.label}
                        <Badge variant="outline" className="text-xs font-normal">
                          {event.source}
                        </Badge>
                      </CardTitle>
                      <CardDescription>
                        Triggered when {event.action.toLowerCase()} action occurs.
                      </CardDescription>
                    </div>
                    <div className="flex items-center gap-2">
                      <span className="text-sm font-medium text-muted-foreground">
                        {setting.isActive ? 'Active' : 'Inactive'}
                      </span>
                      <Switch
                        checked={setting.isActive}
                        onCheckedChange={(checked) =>
                          handleUpdate(event.source, event.action, { isActive: checked })
                        }
                      />
                    </div>
                  </div>
                </CardHeader>

                {setting.isActive && (
                  <CardContent className="pt-6 grid md:grid-cols-2 gap-6">
                    <div className="space-y-2">
                      <label className="text-sm font-medium">Recipients by Role</label>
                      <p className="text-xs text-muted-foreground mb-2">
                        Users with these roles will be notified.
                      </p>
                      <div className="flex flex-wrap gap-2">
                        {roles.map((role) => {
                          const isSelected = setting.recipientRoles?.includes(role.id);
                          return (
                            <Badge
                              key={role.id}
                              variant={isSelected ? 'default' : 'outline'}
                              className="cursor-pointer hover:opacity-80 transition-opacity"
                              onClick={() => {
                                const current = setting.recipientRoles || [];
                                const next = isSelected
                                  ? current.filter((id) => id !== role.id)
                                  : [...current, role.id];
                                handleUpdate(event.source, event.action, { recipientRoles: next });
                              }}
                            >
                              {role.name}
                            </Badge>
                          );
                        })}
                      </div>
                    </div>

                    {/* Placeholder for specific users if needed, keeping it simple for now */}
                    {/* 
                                <div className="space-y-2">
                                     <label className="text-sm font-medium">Specific Users</label>
                                     <p className="text-xs text-muted-foreground">Additionally notify these specific users.</p>
                                     ...
                                </div> 
                                */}
                  </CardContent>
                )}
              </Card>
            );
          })}
        </div>
      </div>
    </AdminLayout>
  );
}
