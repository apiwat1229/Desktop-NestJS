import { ColumnDef } from '@tanstack/react-table';
import { formatDistanceToNow } from 'date-fns';
import { enUS, th } from 'date-fns/locale';
import {
  AlertTriangle,
  ArrowUpDown,
  Check,
  CheckCircle,
  Info,
  Trash2,
  XCircle,
} from 'lucide-react';
import { useTranslation } from 'react-i18next';
import { Button } from '../../../components/ui/button';
import { Checkbox } from '../../../components/ui/checkbox';
import { useLanguageStore } from '../../../stores/languageStore';
import { Notification } from '../../../stores/notificationStore';

interface ColumnsProps {
  onDelete: (id: string) => void;
  onMarkAsRead: (id: string) => void;
}

export const useNotificationColumns = ({
  onDelete,
  onMarkAsRead,
}: ColumnsProps): ColumnDef<Notification>[] => {
  const { t } = useTranslation();
  const { language } = useLanguageStore();

  const getIcon = (type: Notification['type']) => {
    switch (type) {
      case 'success':
        return <CheckCircle className="h-4 w-4 text-green-500" />;
      case 'warning':
        return <AlertTriangle className="h-4 w-4 text-yellow-500" />;
      case 'error':
        return <XCircle className="h-4 w-4 text-red-500" />;
      default:
        return <Info className="h-4 w-4 text-blue-500" />;
    }
  };

  return [
    {
      id: 'select',
      header: ({ table }) => (
        <Checkbox
          checked={
            table.getIsAllPageRowsSelected()
              ? true
              : table.getIsSomePageRowsSelected()
                ? 'indeterminate'
                : false
          }
          onCheckedChange={(value) => table.toggleAllPageRowsSelected(!!value)}
          aria-label={t('common.selectAll')}
        />
      ),
      cell: ({ row }) => (
        <Checkbox
          checked={row.getIsSelected()}
          onCheckedChange={(value) => row.toggleSelected(!!value)}
          aria-label={t('common.selectRow')}
        />
      ),
      enableSorting: false,
      enableHiding: false,
    },
    {
      accessorKey: 'type',
      header: t('admin.notifications.type'),
      cell: ({ row }) => (
        <div className="flex items-center justify-center">{getIcon(row.original.type)}</div>
      ),
    },
    {
      accessorKey: 'title',
      header: ({ column }) => {
        return (
          <Button
            variant="ghost"
            onClick={() => column.toggleSorting(column.getIsSorted() === 'asc')}
          >
            {t('admin.notifications.title')}
            <ArrowUpDown className="ml-2 h-4 w-4" />
          </Button>
        );
      },
      cell: ({ row }) => <span className="font-medium">{row.original.title}</span>,
    },
    {
      accessorKey: 'message',
      header: t('admin.notifications.message'),
      cell: ({ row }) => (
        <span
          className="text-muted-foreground truncate max-w-[300px] block"
          title={row.original.message}
        >
          {row.original.message}
        </span>
      ),
    },
    {
      accessorKey: 'read',
      header: t('admin.notifications.status'),
      cell: ({ row }) => (
        <span
          className={`inline-flex items-center rounded-full px-2 py-1 text-xs font-medium ring-1 ring-inset ${
            row.original.read
              ? 'bg-gray-50 text-gray-600 ring-gray-500/10'
              : 'bg-blue-50 text-blue-700 ring-blue-700/10'
          }`}
        >
          {row.original.read ? t('admin.notifications.read') : t('admin.notifications.unread')}
        </span>
      ),
    },
    {
      accessorKey: 'timestamp',
      header: t('admin.notifications.date'),
      cell: ({ row }) => (
        <span className="text-sm text-muted-foreground">
          {formatDistanceToNow(new Date(row.original.timestamp), {
            addSuffix: true,
            locale: language === 'th' ? th : enUS,
          })}
        </span>
      ),
    },
    {
      id: 'actions',
      header: t('common.actions'),
      cell: ({ row }) => {
        return (
          <div className="flex items-center gap-2">
            {!row.original.read && (
              <Button
                variant="ghost"
                size="icon"
                onClick={() => onMarkAsRead(row.original.id)}
                title={t('admin.notifications.markAsRead')}
              >
                <Check className="h-4 w-4" />
              </Button>
            )}
            <Button
              variant="ghost"
              size="icon"
              className="text-destructive hover:text-destructive/90"
              onClick={() => onDelete(row.original.id)}
              title={t('common.delete')}
            >
              <Trash2 className="h-4 w-4" />
            </Button>
          </div>
        );
      },
    },
  ];
};
