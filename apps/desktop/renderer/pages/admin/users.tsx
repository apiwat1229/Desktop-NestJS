import { Edit2, Plus, Search, Trash2, X } from 'lucide-react';
import { useEffect, useState } from 'react';
import AdminLayout from '../../components/AdminLayout';
import { usersApi } from '../../lib/api';

export default function UsersPage() {
  const [users, setUsers] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');

  // Modal State
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingUser, setEditingUser] = useState<any>(null);
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    role: 'USER',
    password: '',
  });

  // Delete Confirmation State
  const [deleteId, setDeleteId] = useState<string | null>(null);

  const fetchUsers = async () => {
    try {
      setIsLoading(true);
      const data = await usersApi.getAll();
      setUsers(data);
    } catch (error) {
      console.error('Failed to fetch users:', error);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchUsers();
  }, []);

  const handleOpenCreate = () => {
    setEditingUser(null);
    setFormData({ name: '', email: '', role: 'USER', password: '' });
    setIsModalOpen(true);
  };

  const handleOpenEdit = (user: any) => {
    setEditingUser(user);
    setFormData({
      name: user.name || '',
      email: user.email,
      role: user.role,
      password: '',
    });
    setIsModalOpen(true);
  };

  const confirmDelete = async () => {
    if (!deleteId) return;
    try {
      await usersApi.delete(deleteId);
      fetchUsers();
      setDeleteId(null);
    } catch (error) {
      console.error('Failed to delete user:', error);
      alert('Failed to delete user');
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      if (editingUser) {
        // Update
        const updateData = { ...formData };
        if (!updateData.password) delete (updateData as any).password;
        await usersApi.update(editingUser.id, updateData);
      } else {
        // Create
        await usersApi.create(formData);
      }
      setIsModalOpen(false);
      fetchUsers();
    } catch (error) {
      console.error('Failed to save user:', error);
      alert('Failed to save user');
    }
  };

  const filteredUsers = users.filter(
    (user) =>
      user.name?.toLowerCase().includes(searchQuery.toLowerCase()) ||
      user.email?.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <AdminLayout>
      <div className="p-6 w-full max-w-7xl mx-auto space-y-8">
        {/* Header */}
        <div className="flex flex-col sm:flex-row items-center justify-between gap-4">
          <div>
            <h1 className="text-3xl font-bold tracking-tight text-foreground">Users Management</h1>
            <p className="text-muted-foreground mt-1">Manage user access and permissions.</p>
          </div>
          <button
            onClick={handleOpenCreate}
            className="inline-flex items-center justify-center rounded-lg text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50 bg-primary text-primary-foreground shadow hover:bg-primary/90 h-10 px-4 py-2"
          >
            <Plus className="mr-2 h-4 w-4" />
            Add New User
          </button>
        </div>

        {/* Filters */}
        <div className="flex items-center gap-2 bg-card p-2 rounded-lg border border-border shadow-sm max-w-sm">
          <Search className="w-5 h-5 text-muted-foreground ml-2" />
          <input
            type="text"
            placeholder="Search users..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="flex-1 bg-transparent border-none focus:outline-none text-foreground placeholder:text-muted-foreground text-sm h-full py-1"
          />
        </div>

        {/* Users Table */}
        <div className="rounded-xl border border-border bg-card text-card-foreground shadow overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full text-sm text-left">
              <thead className="text-xs text-muted-foreground uppercase bg-muted/50 border-b border-border">
                <tr>
                  <th className="px-6 py-4 font-medium">User</th>
                  <th className="px-6 py-4 font-medium">Role</th>
                  <th className="px-6 py-4 font-medium">Status</th>
                  <th className="px-6 py-4 font-medium text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-border">
                {isLoading ? (
                  <tr>
                    <td colSpan={4} className="px-6 py-8 text-center text-muted-foreground">
                      Loading users...
                    </td>
                  </tr>
                ) : filteredUsers.length === 0 ? (
                  <tr>
                    <td colSpan={4} className="px-6 py-8 text-center text-muted-foreground">
                      No users found.
                    </td>
                  </tr>
                ) : (
                  filteredUsers.map((user) => (
                    <tr key={user.id} className="hover:bg-muted/50 transition-colors">
                      <td className="px-6 py-4">
                        <div className="flex items-center gap-3">
                          <div className="h-9 w-9 rounded-full bg-primary/10 flex items-center justify-center text-primary font-medium border border-primary/20">
                            {user.name
                              ? user.name.charAt(0).toUpperCase()
                              : user.email.charAt(0).toUpperCase()}
                          </div>
                          <div>
                            <div className="font-medium text-foreground">
                              {user.name || 'Unnamed User'}
                            </div>
                            <div className="text-muted-foreground text-xs">{user.email}</div>
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4">
                        <span
                          className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium border ${
                            user.role === 'ADMIN'
                              ? 'bg-purple-100 text-purple-800 border-purple-200 dark:bg-purple-900/30 dark:text-purple-300 dark:border-purple-800'
                              : 'bg-green-100 text-green-800 border-green-200 dark:bg-green-900/30 dark:text-green-300 dark:border-green-800'
                          }`}
                        >
                          {user.role}
                        </span>
                      </td>
                      <td className="px-6 py-4">
                        <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-medium bg-emerald-100 text-emerald-800 border border-emerald-200 dark:bg-emerald-900/30 dark:text-emerald-300 dark:border-emerald-800">
                          <span className="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>
                          Active
                        </span>
                      </td>
                      <td className="px-6 py-4 text-right">
                        <div className="flex items-center justify-end gap-2">
                          <button
                            onClick={() => handleOpenEdit(user)}
                            className="p-2 text-muted-foreground hover:text-primary hover:bg-primary/10 rounded-lg transition-colors"
                            title="Edit User"
                          >
                            <Edit2 className="w-4 h-4" />
                          </button>
                          <button
                            onClick={() => setDeleteId(user.id)}
                            className="p-2 text-destructive bg-destructive/10 hover:bg-destructive/20 border border-destructive/20 rounded-lg transition-colors"
                            title="Delete User"
                          >
                            <Trash2 className="w-4 h-4" />
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </div>
      </div>

      {/* Delete Confirmation Alert Dialog */}
      {deleteId && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm animate-in fade-in duration-200">
          <div className="bg-background rounded-xl shadow-2xl border border-border w-full max-w-sm overflow-hidden animate-in zoom-in-95 duration-200 p-6 space-y-4">
            <div className="space-y-2">
              <h3 className="text-lg font-semibold text-foreground">Are you absolutely sure?</h3>
              <p className="text-sm text-muted-foreground">
                This action cannot be undone. This will permanently delete the user account and
                remove their data from our servers.
              </p>
            </div>
            <div className="flex justify-end gap-2 pt-2">
              <button
                onClick={() => setDeleteId(null)}
                className="px-4 py-2 text-sm font-medium text-muted-foreground hover:bg-muted rounded-md transition-colors"
              >
                Cancel
              </button>
              <button
                onClick={confirmDelete}
                className="px-4 py-2 text-sm font-medium bg-destructive text-destructive-foreground hover:bg-destructive/90 rounded-md transition-colors shadow-sm"
              >
                Delete
              </button>
            </div>
          </div>
        </div>
      )}

      {/* User Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm animate-in fade-in duration-200">
          <div className="bg-background rounded-xl shadow-2xl border border-border w-full max-w-md overflow-hidden animate-in zoom-in-95 duration-200">
            <div className="flex items-center justify-between p-6 border-b border-border bg-muted/30">
              <h3 className="text-lg font-semibold text-foreground">
                {editingUser ? 'Edit User' : 'Create New User'}
              </h3>
              <button
                onClick={() => setIsModalOpen(false)}
                className="text-muted-foreground hover:text-foreground transition-colors"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleSubmit} className="p-6 space-y-4">
              <div className="space-y-2">
                <label className="text-sm font-medium text-foreground">Full Name</label>
                <input
                  type="text"
                  required
                  className="w-full px-3 py-2 bg-background border border-input rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 text-foreground"
                  placeholder="John Doe"
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                />
              </div>

              <div className="space-y-2">
                <label className="text-sm font-medium text-foreground">Email Address</label>
                <input
                  type="email"
                  required
                  className="w-full px-3 py-2 bg-background border border-input rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 text-foreground"
                  placeholder="john@example.com"
                  value={formData.email}
                  onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                />
              </div>

              <div className="space-y-2">
                <label className="text-sm font-medium text-foreground">Role (Permission)</label>
                <select
                  className="w-full px-3 py-2 bg-background border border-input rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 text-foreground"
                  value={formData.role}
                  onChange={(e) => setFormData({ ...formData, role: e.target.value })}
                >
                  <option value="USER">User (Standard)</option>
                  <option value="ADMIN">Admin (Full Access)</option>
                </select>
                <p className="text-xs text-muted-foreground">
                  Admins have full access to system settings.
                </p>
              </div>

              <div className="space-y-2">
                <label className="text-sm font-medium text-foreground">
                  {editingUser ? 'New Password (Optional)' : 'Password'}
                </label>
                <input
                  type="password"
                  required={!editingUser}
                  className="w-full px-3 py-2 bg-background border border-input rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 text-foreground"
                  placeholder={editingUser ? 'Leave blank to keep current' : '••••••••'}
                  value={formData.password}
                  onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                />
              </div>

              <div className="pt-4 flex justify-end gap-3">
                <button
                  type="button"
                  onClick={() => setIsModalOpen(false)}
                  className="px-4 py-2 text-sm font-medium text-muted-foreground hover:bg-muted rounded-md transition-colors"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 text-sm font-medium bg-primary text-primary-foreground hover:bg-primary/90 rounded-md transition-colors shadow-sm"
                >
                  {editingUser ? 'Save Changes' : 'Create User'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </AdminLayout>
  );
}
