import { Bell, CheckCircle2, Plus, Settings, Trash2 } from 'lucide-react';
import Head from 'next/head';
import Link from 'next/link';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import AdminLayout from '../../../components/AdminLayout';
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from '../../../components/ui/alert-dialog';
import { Button } from '../../../components/ui/button';
import { DataTable } from '../../../components/ui/data-table';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '../../../components/ui/dialog';
import { Input } from '../../../components/ui/input';
import { Label } from '../../../components/ui/label';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '../../../components/ui/select';
import { Textarea } from '../../../components/ui/textarea';
import { useToast } from '../../../components/ui/use-toast';
import { NotificationType, useNotificationStore } from '../../../stores/notificationStore';
import { useNotificationColumns } from './columns';

export default function NotificationManagement() {
  const { t } = useTranslation();
  const { toast } = useToast();
  const {
    notifications,
    addNotification,
    removeNotification,
    markAsRead,
    clearAll,
    markAllAsRead,
  } = useNotificationStore();

  const [isCreateOpen, setIsCreateOpen] = useState(false);
  const [newTitle, setNewTitle] = useState('');
  const [newMessage, setNewMessage] = useState('');
  const [newType, setNewType] = useState<NotificationType>('info');

  // Confirmation States
  const [deleteId, setDeleteId] = useState<string | null>(null);
  const [isClearConfirmOpen, setIsClearConfirmOpen] = useState(false);

  const columns = useNotificationColumns({
    onDelete: (id) => setDeleteId(id),
    onMarkAsRead: (id) => {
      markAsRead(id);
    },
  });

  const handleConfirmDelete = () => {
    if (deleteId) {
      removeNotification(deleteId);
      toast({
        description: t('admin.notifications.notificationDeleted'),
      });
      setDeleteId(null);
    }
  };

  const handleConfirmClearAll = () => {
    clearAll();
    toast({
      description: t('notifications.clearedAll'),
    });
    setIsClearConfirmOpen(false);
  };

  const handleCreate = () => {
    if (!newTitle || !newMessage) return;

    addNotification({
      title: newTitle,
      message: newMessage,
      type: newType,
    });

    toast({
      title: t('common.success'),
      description: t('admin.notifications.notificationCreated'),
      variant: 'success',
    });

    setNewTitle('');
    setNewMessage('');
    setNewType('info');
    setIsCreateOpen(false);
  };

  const stats = {
    total: notifications.length,
    unread: notifications.filter((n) => !n.read).length,
    read: notifications.filter((n) => n.read).length,
  };

  return (
    <AdminLayout>
      <Head>
        <title>{t('admin.notifications.title')} | Admin</title>
      </Head>

      <div className="p-6 w-full max-w-[1400px] mx-auto space-y-8">
        {/* Header Card */}
        <div className="bg-card rounded-xl border border-border shadow-sm p-4 md:p-6 flex flex-col xl:flex-row items-center justify-between gap-6 transition-all hover:shadow-md">
          {/* Left: Title & Icon */}
          <div className="flex items-center gap-4 w-full xl:w-auto">
            <div className="p-3 bg-blue-50 dark:bg-blue-900/20 rounded-xl transition-transform hover:scale-105">
              <Bell className="h-6 w-6 text-blue-600 dark:text-blue-400" />
            </div>
            <div>
              <h1 className="text-xl font-bold tracking-tight text-foreground">
                {t('admin.notifications.title')}
              </h1>
              <p className="text-sm text-muted-foreground">{t('admin.notifications.subtitle')}</p>
            </div>
          </div>

          {/* Center: Stats Widget */}
          <div className="hidden md:flex items-center bg-background/50 rounded-xl border border-border p-1 shadow-sm">
            <div className="px-6 py-2 flex flex-col items-center min-w-[100px] border-r border-border/50 last:border-0">
              <span className="text-[10px] font-bold text-muted-foreground uppercase tracking-wider">
                Total
              </span>
              <span className="text-lg font-bold text-foreground">{stats.total}</span>
            </div>
            <div className="w-px h-8 bg-border"></div>
            <div className="px-6 py-2 flex flex-col items-center min-w-[100px]">
              <span className="text-[10px] font-bold text-muted-foreground uppercase tracking-wider text-orange-500">
                Unread
              </span>
              <span className="text-lg font-bold text-orange-500">{stats.unread}</span>
            </div>
            <div className="w-px h-8 bg-border"></div>
            <div className="px-6 py-2 flex flex-col items-center min-w-[100px]">
              <span className="text-[10px] font-bold text-muted-foreground uppercase tracking-wider text-green-600">
                Read
              </span>
              <span className="text-lg font-bold text-green-600">{stats.read}</span>
            </div>
          </div>

          {/* Right: Action Buttons */}
          <div className="flex items-center gap-2 w-full xl:w-auto">
            <Link href="/admin/notification-settings">
              <Button variant="outline" size="icon" title={t('admin.settings', 'Settings')}>
                <Settings className="w-4 h-4" />
              </Button>
            </Link>
            <Button variant="outline" onClick={markAllAsRead} disabled={notifications.length === 0}>
              <CheckCircle2 className="w-4 h-4 mr-2" />
              {t('notifications.markAllRead')}
            </Button>
            <Button
              variant="destructive"
              onClick={() => setIsClearConfirmOpen(true)}
              disabled={notifications.length === 0}
            >
              <Trash2 className="w-4 h-4 mr-2" />
              {t('notifications.clearAll')}
            </Button>
            <Dialog open={isCreateOpen} onOpenChange={setIsCreateOpen}>
              <DialogTrigger asChild>
                <Button className="bg-primary text-primary-foreground shadow-lg hover:bg-primary/90 hover:shadow-xl hover:-translate-y-0.5">
                  <Plus className="w-4 h-4 mr-2" />
                  {t('admin.notifications.create')}
                </Button>
              </DialogTrigger>
              <DialogContent>
                <DialogHeader>
                  <DialogTitle>{t('admin.notifications.createNew')}</DialogTitle>
                  <DialogDescription>
                    {t('admin.notifications.createDescription')}
                  </DialogDescription>
                </DialogHeader>
                <div className="space-y-4 py-4">
                  <div className="space-y-2">
                    <Label htmlFor="title">{t('admin.notifications.titleLabel')}</Label>
                    <Input
                      id="title"
                      value={newTitle}
                      onChange={(e) => setNewTitle(e.target.value)}
                      placeholder={t('admin.notifications.titlePlaceholder')}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="type">{t('admin.notifications.type')}</Label>
                    <Select
                      value={newType}
                      onValueChange={(v) => setNewType(v as NotificationType)}
                    >
                      <SelectTrigger>
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="info">Info</SelectItem>
                        <SelectItem value="success">Success</SelectItem>
                        <SelectItem value="warning">Warning</SelectItem>
                        <SelectItem value="error">Error</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="message">{t('admin.notifications.message')}</Label>
                    <Textarea
                      id="message"
                      value={newMessage}
                      onChange={(e) => setNewMessage(e.target.value)}
                      placeholder={t('admin.notifications.messagePlaceholder')}
                    />
                  </div>
                </div>
                <DialogFooter>
                  <Button variant="outline" onClick={() => setIsCreateOpen(false)}>
                    {t('common.cancel')}
                  </Button>
                  <Button onClick={handleCreate}>{t('common.create')}</Button>
                </DialogFooter>
              </DialogContent>
            </Dialog>
          </div>
        </div>

        {/* Table Container */}
        <div className="rounded-xl border border-border bg-card text-card-foreground shadow">
          <div className="bg-card rounded-lg border shadow-sm p-6">
            <DataTable
              columns={columns}
              data={notifications}
              searchKey="title"
              searchPlaceholder={t('admin.notifications.search')}
            />
          </div>
        </div>
      </div>

      {/* Delete Confirmation Dialog */}
      <AlertDialog open={!!deleteId} onOpenChange={(open) => !open && setDeleteId(null)}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <div className="mx-auto w-12 h-12 rounded-xl bg-red-50 flex items-center justify-center mb-2">
              <Trash2 className="w-6 h-6 text-red-600" />
            </div>
            <AlertDialogTitle>{t('common.deleteConfirm')}</AlertDialogTitle>
            <AlertDialogDescription>
              {t(
                'admin.notifications.deleteConfirmMessage',
                'Are you sure you want to delete this notification?'
              )}
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel onClick={() => setDeleteId(null)}>
              {t('common.cancel')}
            </AlertDialogCancel>
            <AlertDialogAction
              onClick={handleConfirmDelete}
              className="bg-destructive text-destructive-foreground hover:bg-destructive/90"
            >
              {t('common.delete')}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>

      {/* Clear All Confirmation Dialog */}
      <AlertDialog open={isClearConfirmOpen} onOpenChange={setIsClearConfirmOpen}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <div className="mx-auto w-12 h-12 rounded-xl bg-red-50 flex items-center justify-center mb-2">
              <Trash2 className="w-6 h-6 text-red-600" />
            </div>
            <AlertDialogTitle>{t('common.clearAllConfirm')}</AlertDialogTitle>
            <AlertDialogDescription>
              {t(
                'admin.notifications.clearAllConfirmMessage',
                'This will permanently delete all notifications. This action cannot be undone.'
              )}
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel onClick={() => setIsClearConfirmOpen(false)}>
              {t('common.cancel')}
            </AlertDialogCancel>
            <AlertDialogAction
              onClick={handleConfirmClearAll}
              className="bg-destructive text-destructive-foreground hover:bg-destructive/90"
            >
              {t('common.clearAll')}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </AdminLayout>
  );
}
