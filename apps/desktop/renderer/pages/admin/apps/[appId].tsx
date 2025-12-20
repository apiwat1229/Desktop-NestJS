import { ArrowLeft, Plus, Trash2 } from 'lucide-react';
import { useRouter } from 'next/router';
import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { toast } from 'sonner';
import AdminLayout from '../../../components/AdminLayout';
import { Button } from '../../../components/ui/button';
import { Card } from '../../../components/ui/card';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '../../../components/ui/dialog';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '../../../components/ui/select';
import { Switch } from '../../../components/ui/switch';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '../../../components/ui/table';
import { accessControlApi, usersApi } from '../../../lib/api';

const AVAILABLE_ACTIONS = ['read', 'create', 'update', 'delete', 'approve'];

export default function AppDetailsPage() {
  const router = useRouter();
  const { appId } = router.query;
  const { t } = useTranslation();

  const [isLoading, setIsLoading] = useState(true);
  const [app, setApp] = useState<any>(null);
  const [appUsers, setAppUsers] = useState<any[]>([]);
  const [allUsers, setAllUsers] = useState<any[]>([]);

  // Modal State
  const [isAddUserOpen, setIsAddUserOpen] = useState(false);
  const [selectedUserId, setSelectedUserId] = useState('');
  const [selectedActions, setSelectedActions] = useState<string[]>(['read']);

  // Fetch Data
  const fetchData = async () => {
    if (!appId) return;
    try {
      setIsLoading(true);
      // 1. Get App Info (We might need an endpoint for single app, or filter from list)
      // For now, let's fetch list and find.
      const apps = await accessControlApi.getApps();
      const currentApp = apps.find((a: any) => a.id === appId);
      setApp(currentApp);

      // 2. Get Users in this App
      const usersData = await accessControlApi.getAppUsers(appId as string);
      setAppUsers(usersData);

      // 3. Get All Users for selection
      const allUsersData = await usersApi.getAll();
      setAllUsers(allUsersData);
    } catch (error) {
      console.error('Failed to load app data:', error);
      toast.error(t('common.error'), { description: t('common.errorLoading') });
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    if (appId) fetchData();
  }, [appId]);

  const handleAddUser = async () => {
    if (!selectedUserId) return;
    try {
      await accessControlApi.assignPermission(appId as string, selectedUserId, selectedActions);
      toast.success(t('common.success'), { description: t('common.saved') });
      setIsAddUserOpen(false);
      setSelectedUserId('');
      setSelectedActions(['read']);
      fetchData();
    } catch (error) {
      console.error('Failed to add user:', error);
      toast.error(t('common.error'), { description: t('common.saveFailed') });
    }
  };

  const handleUpdatePermission = async (userId: string, action: string, checked: boolean) => {
    try {
      // Find current user permissions locally first to toggle
      const userIndex = appUsers.findIndex((u) => u.userId === userId);
      if (userIndex === -1) return;

      const userPerm = appUsers[userIndex];
      let newActions = [...(userPerm.actions as string[])];

      if (checked) {
        if (!newActions.includes(action)) newActions.push(action);
      } else {
        newActions = newActions.filter((a) => a !== action);
      }

      // Optimistic Update
      const newAppUsers = [...appUsers];
      newAppUsers[userIndex] = { ...userPerm, actions: newActions };
      setAppUsers(newAppUsers);

      // API Call
      await accessControlApi.assignPermission(appId as string, userId, newActions);
      toast.success(t('common.success'), { description: 'Permission updated' });
    } catch (error) {
      console.error('Failed to update permission:', error);
      toast.error(t('common.error'), { description: 'Failed to update' });
      fetchData(); // Revert
    }
  };

  const handleRemoveUser = async (userId: string) => {
    if (!confirm(t('common.deleteConfirm'))) return;
    try {
      await accessControlApi.removePermission(appId as string, userId);
      toast.success(t('common.success'), { description: t('common.deleted') });
      fetchData();
    } catch (error) {
      console.error('Failed to remove user:', error);
      toast.error(t('common.error'), { description: t('common.error') });
    }
  };

  if (!app && !isLoading) return <div>App not found</div>;

  return (
    <AdminLayout>
      <div className="p-6 w-full max-w-[1400px] mx-auto space-y-8">
        {/* Header */}
        <div className="flex items-center gap-4">
          <Button variant="ghost" size="icon" onClick={() => router.back()}>
            <ArrowLeft className="w-5 h-5" />
          </Button>
          <div>
            <h1 className="text-2xl font-bold tracking-tight text-foreground">
              {app?.name || 'Loading...'}
            </h1>
            <p className="text-sm text-muted-foreground">{app?.description}</p>
          </div>
          <div className="ml-auto">
            <Button onClick={() => setIsAddUserOpen(true)}>
              <Plus className="w-4 h-4 mr-2" />
              {t('admin.apps.addUser', 'Add User')}
            </Button>
          </div>
        </div>

        {/* Users Table */}
        <Card>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>User</TableHead>
                <TableHead>Email</TableHead>
                {AVAILABLE_ACTIONS.map((action) => (
                  <TableHead key={action} className="text-center w-[100px] capitalize">
                    {action}
                  </TableHead>
                ))}
                <TableHead className="text-right">Action</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {appUsers.map((perm) => (
                <TableRow key={perm.id}>
                  <TableCell className="font-medium">
                    <div className="flex items-center gap-3">
                      <div className="w-8 h-8 rounded-full bg-slate-100 overflow-hidden">
                        <img
                          src={
                            perm.user.avatar ||
                            `https://api.dicebear.com/7.x/avataaars/svg?seed=${perm.user.id}`
                          }
                          alt="avatar"
                        />
                      </div>
                      <div>
                        <div>
                          {perm.user.firstName} {perm.user.lastName}
                        </div>
                        <div className="text-xs text-muted-foreground">{perm.user.role}</div>
                      </div>
                    </div>
                  </TableCell>
                  <TableCell>{perm.user.email}</TableCell>
                  {AVAILABLE_ACTIONS.map((action) => (
                    <TableCell key={action} className="text-center">
                      <Switch
                        checked={(perm.actions as string[]).includes(action)}
                        onCheckedChange={(checked) =>
                          handleUpdatePermission(perm.userId, action, checked)
                        }
                      />
                    </TableCell>
                  ))}
                  <TableCell className="text-right">
                    <Button
                      variant="ghost"
                      size="icon"
                      className="text-red-500 hover:text-red-700 hover:bg-red-50"
                      onClick={() => handleRemoveUser(perm.userId)}
                    >
                      <Trash2 className="w-4 h-4" />
                    </Button>
                  </TableCell>
                </TableRow>
              ))}
              {appUsers.length === 0 && (
                <TableRow>
                  <TableCell
                    colSpan={2 + AVAILABLE_ACTIONS.length + 1}
                    className="h-24 text-center text-muted-foreground"
                  >
                    {t('admin.apps.noUsers', 'No users configured for this app yet.')}
                  </TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
        </Card>

        {/* Add User Modal */}
        <Dialog open={isAddUserOpen} onOpenChange={setIsAddUserOpen}>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>{t('admin.apps.addUser', 'Add User to App')}</DialogTitle>
              <DialogDescription>Select a user to grant access to {app?.name}.</DialogDescription>
            </DialogHeader>
            <div className="space-y-4 py-4">
              <div className="space-y-2">
                <label className="text-sm font-medium">User</label>
                <Select value={selectedUserId} onValueChange={setSelectedUserId}>
                  <SelectTrigger>
                    <SelectValue placeholder="Select user..." />
                  </SelectTrigger>
                  <SelectContent>
                    {allUsers
                      .filter((u) => !appUsers.some((au) => au.userId === u.id)) // Exclude already added
                      .map((user) => (
                        <SelectItem key={user.id} value={user.id}>
                          {user.firstName} {user.lastName} ({user.email})
                        </SelectItem>
                      ))}
                  </SelectContent>
                </Select>
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium">Initial Permissions</label>
                <div className="flex flex-wrap gap-4">
                  {AVAILABLE_ACTIONS.map((action) => (
                    <div key={action} className="flex items-center space-x-2">
                      <Switch
                        id={`new-${action}`}
                        checked={selectedActions.includes(action)}
                        onCheckedChange={(checked) => {
                          if (checked) setSelectedActions([...selectedActions, action]);
                          else setSelectedActions(selectedActions.filter((a) => a !== action));
                        }}
                      />
                      <label
                        htmlFor={`new-${action}`}
                        className="capitalize text-sm cursor-pointer"
                      >
                        {action}
                      </label>
                    </div>
                  ))}
                </div>
              </div>
            </div>
            <DialogFooter>
              <Button variant="outline" onClick={() => setIsAddUserOpen(false)}>
                Cancel
              </Button>
              <Button onClick={handleAddUser} disabled={!selectedUserId}>
                Add User
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      </div>
    </AdminLayout>
  );
}
