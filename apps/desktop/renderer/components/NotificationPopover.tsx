import { formatDistanceToNow } from 'date-fns';
import { enUS, th } from 'date-fns/locale';
import { AlertTriangle, Bell, Check, CheckCircle, Info, Trash2, XCircle } from 'lucide-react';
import { useTranslation } from 'react-i18next';
import { useLanguageStore } from '../stores/languageStore';
import { Notification, useNotificationStore } from '../stores/notificationStore';
import { Button } from './ui/button';
import { Popover, PopoverContent, PopoverTrigger } from './ui/popover';

export default function NotificationPopover() {
  const { t } = useTranslation();
  const { language } = useLanguageStore();
  const { notifications, unreadCount, markAsRead, markAllAsRead, clearAll, removeNotification } =
    useNotificationStore();

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

  return (
    <Popover>
      <PopoverTrigger asChild>
        <Button variant="ghost" size="icon" className="relative group">
          <Bell
            className={`h-5 w-5 text-gray-600 transition-all ${
              unreadCount > 0 ? 'animate-bell text-primary' : ''
            }`}
          />
          {unreadCount > 0 && (
            <span className="absolute -top-1 -right-1 flex h-5 w-5 items-center justify-center rounded-full bg-red-500 text-[10px] text-white ring-2 ring-white">
              {unreadCount > 99 ? '99+' : unreadCount}
            </span>
          )}
          <span className="sr-only">Notifications</span>
        </Button>
      </PopoverTrigger>
      <PopoverContent className="w-80 p-0" align="end">
        <div className="flex items-center justify-between px-4 py-3 border-b">
          <h4 className="font-semibold text-sm">{t('notifications.title')}</h4>
          <div className="flex items-center gap-1">
            {notifications.length > 0 && (
              <>
                <Button
                  variant="ghost"
                  size="icon"
                  className="h-8 w-8 text-muted-foreground hover:text-foreground"
                  onClick={markAllAsRead}
                  title={t('notifications.markAllRead')}
                >
                  <Check className="h-4 w-4" />
                </Button>
                <Button
                  variant="ghost"
                  size="icon"
                  className="h-8 w-8 text-muted-foreground hover:text-destructive"
                  onClick={clearAll}
                  title={t('notifications.clearAll')}
                >
                  <Trash2 className="h-4 w-4" />
                </Button>
              </>
            )}
          </div>
        </div>
        <div className="max-h-[300px] overflow-y-auto">
          {notifications.length === 0 ? (
            <div className="p-8 text-center text-muted-foreground text-sm">
              <Bell className="h-8 w-8 mx-auto mb-2 opacity-20" />
              <p>{t('notifications.empty')}</p>
            </div>
          ) : (
            <div className="divide-y">
              {notifications.map((notification) => (
                <div
                  key={notification.id}
                  className={`p-4 flex gap-3 transition-colors hover:bg-muted/50 ${
                    !notification.read ? 'bg-blue-50/50 dark:bg-blue-900/10' : ''
                  }`}
                  onClick={() => markAsRead(notification.id)}
                >
                  <div className="mt-1 flex-shrink-0">{getIcon(notification.type)}</div>
                  <div className="flex-1 space-y-1">
                    <p
                      className={`text-sm font-medium leading-none ${!notification.read ? 'text-foreground' : 'text-muted-foreground'}`}
                    >
                      {notification.title}
                    </p>
                    <p className="text-xs text-muted-foreground text-pretty">
                      {notification.message}
                    </p>
                    <p className="text-[10px] text-muted-foreground pt-1">
                      {formatDistanceToNow(new Date(notification.timestamp), {
                        addSuffix: true,
                        locale: language === 'th' ? th : enUS,
                      })}
                    </p>
                  </div>
                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      removeNotification(notification.id);
                    }}
                    className="flex-shrink-0 text-muted-foreground hover:text-foreground opacity-0 group-hover:opacity-100 transition-opacity"
                  >
                    <span className="sr-only">Remove</span>
                    <XCircle className="h-3 w-3" />
                  </button>
                </div>
              ))}
            </div>
          )}
        </div>
      </PopoverContent>
    </Popover>
  );
}
