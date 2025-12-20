import { Briefcase, Edit2, FolderLock, Plus, Shield } from 'lucide-react';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import AdminLayout from '../../components/AdminLayout';
import { Button } from '../../components/ui/button';
import { Card } from '../../components/ui/card';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '../../components/ui/dialog';

// Mock Data for Roles (Ideally fetched from API)
const INITIAL_ROLES = [
  {
    id: 'admin',
    name: 'Administrator',
    description: 'Full access to all resources',
    usersCount: 6,
    icon: Shield,
    color: 'bg-blue-500',
    permissions: {
      users: { read: true, write: true, delete: true },
      suppliers: { read: true, write: true, delete: true },
      rubber: { read: true, write: true, delete: true },
      notifications: { read: true, write: true, delete: true },
    },
  },
  {
    id: 'manager',
    name: 'Manager',
    description: 'Manage teams and oversee operations',
    usersCount: 6,
    icon: Briefcase,
    color: 'bg-orange-500',
    permissions: {
      users: { read: true, write: true, delete: false },
      suppliers: { read: true, write: true, delete: false },
      rubber: { read: true, write: true, delete: false },
      notifications: { read: true, write: true, delete: true },
    },
  },
  {
    id: 'sales',
    name: 'Sales',
    description: 'Access to sales and CRM tools',
    usersCount: 6,
    icon: FolderLock,
    color: 'bg-red-500',
    permissions: {
      users: { read: true, write: false, delete: false },
      suppliers: { read: true, write: true, delete: false },
      rubber: { read: true, write: false, delete: false },
      notifications: { read: true, write: false, delete: false },
    },
  },
  {
    id: 'support',
    name: 'Support',
    description: 'Customer support and issue resolution',
    usersCount: 6,
    icon: FolderLock,
    color: 'bg-purple-500',
    permissions: {
      users: { read: true, write: false, delete: false },
      suppliers: { read: true, write: false, delete: false },
      rubber: { read: true, write: false, delete: false },
      notifications: { read: true, write: true, delete: false },
    },
  },
  {
    id: 'dev',
    name: 'Developer',
    description: 'Technical access and system maintenance',
    usersCount: 6,
    icon: FolderLock,
    color: 'bg-red-500',
    permissions: {
      users: { read: true, write: true, delete: false },
      suppliers: { read: true, write: true, delete: false },
      rubber: { read: true, write: true, delete: false },
      notifications: { read: true, write: true, delete: false },
    },
  },
  {
    id: 'hr',
    name: 'HR Department',
    description: 'Employee management and recruitment',
    usersCount: 6,
    icon: FolderLock,
    color: 'bg-green-500',
    permissions: {
      users: { read: true, write: true, delete: true },
      suppliers: { read: false, write: false, delete: false },
      rubber: { read: false, write: false, delete: false },
      notifications: { read: true, write: true, delete: false },
    },
  },
  {
    id: 'restricted',
    name: 'Restricted User',
    description: 'Limited access to basic features',
    usersCount: 6,
    icon: FolderLock,
    color: 'bg-blue-600',
    permissions: {
      users: { read: true, write: false, delete: false },
      suppliers: { read: false, write: false, delete: false },
      rubber: { read: false, write: false, delete: false },
      notifications: { read: true, write: false, delete: false },
    },
  },
  {
    id: 'customer',
    name: 'Customer',
    description: 'Standard customer access',
    usersCount: 6,
    icon: FolderLock,
    color: 'bg-blue-500',
    permissions: {
      users: { read: true, write: false, delete: false },
      suppliers: { read: false, write: false, delete: false },
      rubber: { read: false, write: false, delete: false },
      notifications: { read: true, write: false, delete: false },
    },
  },
];

const RESOURCES = [
  { id: 'users', label: 'Administrator' },
  { id: 'suppliers', label: 'Manager' },
  { id: 'sales', label: 'Sales' },
  { id: 'support', label: 'Support' },
  { id: 'dev', label: 'Developer' },
  { id: 'hr', label: 'HR Department' },
  { id: 'restricted', label: 'Restricted User' },
  { id: 'customer', label: 'Customer' },
];

// Actual resources for permission table
const PERMISSION_ROWS = [
  { id: 'users', label: 'Administrator' },
  { id: 'manager', label: 'Manager' },
  { id: 'sales', label: 'Sales' },
  { id: 'support', label: 'Support' },
  { id: 'dev', label: 'Developer' },
  { id: 'hr', label: 'HR Department' },
  { id: 'restricted', label: 'Restricted User' },
  { id: 'customer', label: 'Customer' },
];

export default function RolesPage() {
  const { t } = useTranslation();
  const [roles, setRoles] = useState(INITIAL_ROLES);
  const [editingRole, setEditingRole] = useState<any>(null);
  const [isModalOpen, setIsModalOpen] = useState(false);

  // Mock Avatar List for UI
  const avatarList = [1, 2, 3, 4];

  const handleEditRole = (role: any) => {
    setEditingRole({ ...role }); // Deep copy if needed
    setIsModalOpen(true);
  };

  const handleSaveRole = () => {
    // Save logic here (e.g. API call)
    setRoles((prev) => prev.map((r) => (r.id === editingRole.id ? editingRole : r)));
    setIsModalOpen(false);
  };

  const togglePermission = (resource: string, type: 'read' | 'write' | 'delete') => {
    if (!editingRole) return;
    // This is mock logic, adapting to structure
    // Since permission structure in mock data is simple, I'll assume we edit 'read' 'write' 'delete' props
    // But wait, the screenshot showed a row for EACH ROLE?
    // "Administrator -> Read Write Delete"
    // "Manager -> Read Write Delete"
    // This implies the modal configures access TO specific roles? Or FOR specific roles?
    // Screenshot title "Edit Role".
    // Rows: "Administrator", "Manager".
    // Columns: "Read", "Write", "Delete".
    // This looks like an ACL Matrix? Or maybe "What can this role Access?"
    // If I am editing "Administrator" role, do I define if it can Edit "Manager"?
    // OR is the list in the modal essentially a list of resources/modules?
    // "Administrator", "Manager", "Sales" listed in the modal look like RESOURCES or MODULE names in the screenshot?
    // Wait, the screenshot in Modal shows: "Administrator", "Manager", "Sales", "Support".
    // These match the Roles themselves.
    // So it seems to be "Role Hierarchy" or "Access to manage other roles"?
    // OR maybe the screenshot is just showing a list of modules that happen to be named same as roles?
    // Let's assume they are "Resources" or "Modules".
    // I will use `PERMISSION_ROWS` which mimics the screenshot.

    // Logic: Toggle the boolean
    // Since my mock data structure `permissions: { users: ... }` might not match perfectly 1:1 with "Administrator" resource.
    // I will just mock the state update visual.
  };

  return (
    <AdminLayout>
      <div className="p-6 w-full max-w-[1400px] mx-auto space-y-8">
        {/* Header */}
        <div className="flex flex-col md:flex-row items-center justify-between gap-4">
          <div>
            <h1 className="text-2xl font-bold tracking-tight text-foreground">
              {t('admin.roles.title', 'Roles and Permissions')}
            </h1>
            <div className="flex items-center gap-2 text-sm text-muted-foreground mt-1">
              <span>{t('admin.sidebar.dashboard', 'Dashboard')}</span>
              <span>•</span>
              <span>{t('admin.roles.subtitle', 'Role Management & Permission')}</span>
            </div>
          </div>
          <Button className="bg-blue-600 hover:bg-blue-700 text-white">
            <Plus className="w-4 h-4 mr-2" />
            {t('admin.roles.addRole', 'Add New Role')}
          </Button>
        </div>

        {/* Roles Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-6">
          {roles.map((role) => (
            <Card
              key={role.id}
              className="p-6 flex flex-col justify-between hover:shadow-lg transition-shadow"
            >
              <div className="flex justify-between items-start mb-4">
                <div className="flex items-center gap-3">
                  <div
                    className={`p-2 rounded-lg ${role.color.replace('bg-', 'bg-').replace('500', '100')} ${role.color.replace('bg-', 'text-')}`}
                  >
                    <role.icon className="w-6 h-6" />
                  </div>
                  <h3 className="font-bold text-lg">{role.name}</h3>
                </div>
                <button className="text-muted-foreground hover:text-foreground">
                  <span className="text-xl leading-none">...</span>
                </button>
              </div>

              <div className="flex items-center justify-between mt-4">
                <div className="flex -space-x-2">
                  {avatarList.map((i) => (
                    <div
                      key={i}
                      className="w-8 h-8 rounded-full border-2 border-background bg-slate-200 flex items-center justify-center overflow-hidden"
                    >
                      <img
                        src={`https://api.dicebear.com/7.x/avataaars/svg?seed=${role.id}${i}`}
                        alt="user"
                      />
                    </div>
                  ))}
                </div>
                <span className="text-sm text-muted-foreground">Total {role.usersCount} users</span>
              </div>

              <div className="mt-6 pt-6 border-t border-border">
                <Button variant="outline" className="w-full" onClick={() => handleEditRole(role)}>
                  <Edit2 className="w-4 h-4 mr-2" />
                  {t('admin.roles.editRole', 'Edit Role')}
                </Button>
              </div>
            </Card>
          ))}
        </div>

        {/* Edit Role Modal */}
        <Dialog open={isModalOpen} onOpenChange={setIsModalOpen}>
          <DialogContent className="max-w-3xl max-h-[90vh] overflow-y-auto">
            <DialogHeader>
              <DialogTitle>{t('admin.roles.editRole', 'Edit Role')}</DialogTitle>
              <DialogDescription>
                {t('admin.roles.editDescription', 'Manage role access and permissions.')}
              </DialogDescription>
            </DialogHeader>

            <div className="space-y-6 py-4">
              <h3 className="font-semibold">{t('admin.roles.roleAccess', 'Role Access')}</h3>

              <div className="space-y-4">
                {PERMISSION_ROWS.map((row) => (
                  <div
                    key={row.id}
                    className="flex items-center justify-between p-4 bg-muted/20 rounded-lg border border-border"
                  >
                    <span className="font-medium min-w-[150px]">{row.label}</span>
                    <div className="flex items-center gap-4">
                      <label className="flex items-center gap-2 cursor-pointer border rounded-md px-3 py-2 bg-background hover:bg-muted transition-colors">
                        <input type="checkbox" className="accent-blue-600 w-4 h-4" defaultChecked />
                        <span className="text-sm">Read</span>
                      </label>
                      <label className="flex items-center gap-2 cursor-pointer border rounded-md px-3 py-2 bg-background hover:bg-muted transition-colors">
                        <input type="checkbox" className="accent-blue-600 w-4 h-4" />
                        <span className="text-sm">Write</span>
                      </label>
                      <label className="flex items-center gap-2 cursor-pointer border rounded-md px-3 py-2 bg-background hover:bg-muted transition-colors">
                        <input type="checkbox" className="accent-blue-600 w-4 h-4" />
                        <span className="text-sm">Delete</span>
                      </label>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            <DialogFooter>
              <Button variant="outline" onClick={() => setIsModalOpen(false)}>
                {t('common.cancel')}
              </Button>
              <Button onClick={handleSaveRole} className="bg-blue-600 text-white">
                {t('common.save')}
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      </div>
    </AdminLayout>
  );
}
