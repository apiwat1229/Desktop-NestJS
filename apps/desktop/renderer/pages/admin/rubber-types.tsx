import { Layers, Plus, Trash2 } from 'lucide-react';
import React, { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import AdminLayout from '../../components/AdminLayout';
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from '../../components/ui/alert-dialog';
import { DataTable } from '../../components/ui/data-table';
import { Spinner } from '../../components/ui/spinner';
import { useToast } from '../../components/ui/use-toast';
import { rubberTypesApi } from '../../lib/api';
import { RubberType, useRubberTypeColumns } from './rubber-types/columns';

export default function RubberTypesPage() {
  const [data, setData] = useState<RubberType[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingItem, setEditingItem] = useState<RubberType | null>(null);
  const [deleteId, setDeleteId] = useState<string | null>(null);
  const { t } = useTranslation();

  const { toast } = useToast();

  // Form Data
  const [formData, setFormData] = useState({
    code: '',
    name: '',
    description: '',
    is_active: true,
  });

  const fetchData = async () => {
    try {
      setIsLoading(true);
      const res = await rubberTypesApi.getAll();
      setData(res);
    } catch (error) {
      console.error('Failed to fetch rubber types:', error);
      toast({
        title: 'Error',
        description: 'Failed to fetch rubber types.',
        variant: 'destructive',
      });
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  const handleOpenCreate = () => {
    setEditingItem(null);
    setFormData({ code: '', name: '', description: '', is_active: true });
    setIsModalOpen(true);
  };

  const handleOpenEdit = (item: RubberType) => {
    setEditingItem(item);
    setFormData({
      code: item.code,
      name: item.name,
      description: item.description || '',
      is_active: item.is_active,
    });
    setIsModalOpen(true);
  };

  const handleDelete = (id: string) => {
    setDeleteId(id);
  };

  const confirmDelete = async () => {
    if (!deleteId) return;
    try {
      await rubberTypesApi.delete(deleteId);
      toast({
        title: 'Success',
        description: 'Rubber type deleted successfully.',
        variant: 'success',
      });
      fetchData();
      setDeleteId(null);
    } catch (error) {
      console.error('Failed to delete:', error);
      toast({
        title: 'Error',
        description: 'Failed to delete rubber type.',
        variant: 'destructive',
      });
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      if (editingItem) {
        await rubberTypesApi.update(editingItem.id, formData);
        toast({
          title: 'Success',
          description: 'Rubber type updated successfully.',
          variant: 'success',
        });
      } else {
        await rubberTypesApi.create(formData);
        toast({
          title: 'Success',
          description: 'Rubber type created successfully.',
          variant: 'success',
        });
      }
      setIsModalOpen(false);
      fetchData();
    } catch (error: any) {
      console.error('Failed to save:', error);
      toast({
        title: 'Error',
        description: error.response?.data?.message || 'Failed to save rubber type.',
        variant: 'destructive',
      });
    }
  };

  const columns = useRubberTypeColumns({
    onEdit: handleOpenEdit,
    onDelete: handleDelete,
  });

  const stats = React.useMemo(() => {
    return {
      total: data.length,
      active: data.filter((item) => item.is_active).length,
      inactive: data.filter((item) => !item.is_active).length,
    };
  }, [data]);

  if (isLoading) {
    return (
      <AdminLayout>
        <div className="h-[calc(100vh-100px)] w-full flex items-center justify-center">
          <Spinner size="xl" />
        </div>
      </AdminLayout>
    );
  }

  return (
    <AdminLayout>
      <div className="p-6 w-full max-w-[1400px] mx-auto space-y-8">
        {/* Header Card */}
        <div className="bg-card rounded-xl border border-border shadow-sm p-4 md:p-6 flex flex-col xl:flex-row items-center justify-between gap-6 transition-all hover:shadow-md">
          {/* Left: Title & Icon */}
          <div className="flex items-center gap-4 w-full xl:w-auto">
            <div className="p-3 bg-blue-50 dark:bg-blue-900/20 rounded-xl transition-transform hover:scale-105">
              <Layers className="h-6 w-6 text-blue-600 dark:text-blue-400" />
            </div>
            <div>
              <h1 className="text-xl font-bold tracking-tight text-foreground">
                Rubber Types Management
              </h1>
              <p className="text-sm text-muted-foreground">
                Manage rubber types and their configurations.
              </p>
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
              <span className="text-[10px] font-bold text-muted-foreground uppercase tracking-wider text-green-600">
                Active
              </span>
              <span className="text-lg font-bold text-green-600">{stats.active}</span>
            </div>
            <div className="w-px h-8 bg-border"></div>
            <div className="px-6 py-2 flex flex-col items-center min-w-[100px]">
              <span className="text-[10px] font-bold text-muted-foreground uppercase tracking-wider text-destructive">
                Inactive
              </span>
              <span className="text-lg font-bold text-destructive">{stats.inactive}</span>
            </div>
          </div>

          {/* Right: Action Button */}
          <button
            onClick={handleOpenCreate}
            className="w-full xl:w-auto inline-flex items-center justify-center rounded-lg text-sm font-medium transition-all focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 bg-primary text-primary-foreground shadow-lg hover:bg-primary/90 hover:shadow-xl hover:-translate-y-0.5 h-11 px-8"
          >
            <Plus className="mr-2 h-4 w-4" />
            Add New Rubber Type
          </button>
        </div>

        {/* Data Table */}
        <div className="rounded-xl border border-border bg-card text-card-foreground shadow">
          <div className="bg-card rounded-lg border shadow-sm p-6">
            <DataTable columns={columns} data={data} searchKey="name" />
          </div>
        </div>

        {/* Create / Edit Modal */}
        {isModalOpen && (
          <div className="fixed inset-0 z-50 w-screen h-screen grid place-items-center p-4 bg-black/50 backdrop-blur-sm animate-in fade-in duration-200">
            <div className="bg-background rounded-xl shadow-2xl border border-border w-full max-w-lg overflow-hidden animate-in zoom-in-95 duration-200 relative">
              <div className="flex items-center justify-between p-6 border-b border-border bg-muted/10">
                <div>
                  <h3 className="text-xl font-bold text-foreground flex items-center gap-2">
                    {editingItem ? (
                      <Layers className="w-5 h-5 text-primary" />
                    ) : (
                      <Plus className="w-5 h-5 text-primary" />
                    )}
                    {editingItem ? 'Edit Rubber Type' : 'Add New Rubber Type'}
                  </h3>
                  <p className="text-sm text-muted-foreground mt-1">
                    {editingItem
                      ? 'Update rubber type details.'
                      : 'Add a new rubber type to the system.'}
                  </p>
                </div>
                <button
                  onClick={() => setIsModalOpen(false)}
                  className="text-muted-foreground hover:text-foreground transition-colors p-2 hover:bg-muted rounded-full"
                >
                  ✕
                </button>
              </div>

              <form onSubmit={handleSubmit} className="p-6 space-y-6">
                <div>
                  <label className="text-sm font-medium text-foreground mb-1 block">
                    Code <span className="text-destructive">*</span>
                  </label>
                  <input
                    type="text"
                    required
                    className="w-full px-3 py-2 bg-background border border-input rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 text-foreground"
                    placeholder="E.g. RT-001"
                    value={formData.code}
                    onChange={(e) => setFormData({ ...formData, code: e.target.value })}
                  />
                </div>
                <div>
                  <label className="text-sm font-medium text-foreground mb-1 block">
                    Name <span className="text-destructive">*</span>
                  </label>
                  <input
                    type="text"
                    required
                    className="w-full px-3 py-2 bg-background border border-input rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 text-foreground"
                    placeholder="E.g. Latex 100%"
                    value={formData.name}
                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                  />
                </div>
                <div>
                  <label className="text-sm font-medium text-foreground mb-1 block">
                    Description
                  </label>
                  <textarea
                    rows={3}
                    className="w-full px-3 py-2 bg-background border border-input rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 text-foreground resize-none"
                    value={formData.description}
                    onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                  />
                </div>
                <div className="flex items-center gap-2 p-3 border border-border rounded-lg bg-card/50">
                  <input
                    type="checkbox"
                    id="is_active"
                    checked={formData.is_active}
                    onChange={(e) => setFormData({ ...formData, is_active: e.target.checked })}
                    className="rounded border-gray-300 text-primary shadow-sm focus:ring-primary w-4 h-4"
                  />
                  <label
                    htmlFor="is_active"
                    className="text-sm font-medium text-foreground cursor-pointer select-none"
                  >
                    Active (Enabled)
                  </label>
                </div>

                <div className="flex justify-end gap-3 pt-2">
                  <button
                    type="button"
                    onClick={() => setIsModalOpen(false)}
                    className="px-4 py-2 text-sm font-medium text-muted-foreground hover:bg-muted rounded-md transition-colors"
                  >
                    Cancel
                  </button>
                  <button
                    type="submit"
                    className="px-6 py-2 text-sm font-medium bg-primary text-primary-foreground hover:bg-primary/90 rounded-md transition-colors shadow-lg shadow-primary/20"
                  >
                    {editingItem ? 'Save Changes' : 'Create Rubber Type'}
                  </button>
                </div>
              </form>
            </div>
          </div>
        )}

        {/* Delete Confirmation */}
        <AlertDialog open={!!deleteId} onOpenChange={(open) => !open && setDeleteId(null)}>
          <AlertDialogContent>
            <AlertDialogHeader>
              <div className="mx-auto w-12 h-12 rounded-xl bg-red-50 flex items-center justify-center mb-2">
                <Trash2 className="w-6 h-6 text-red-600" />
              </div>
              <AlertDialogTitle>Delete Rubber Type?</AlertDialogTitle>
              <AlertDialogDescription>
                This will permanently delete this rubber type.
              </AlertDialogDescription>
            </AlertDialogHeader>
            <AlertDialogFooter>
              <AlertDialogCancel onClick={() => setDeleteId(null)}>Cancel</AlertDialogCancel>
              <AlertDialogAction
                onClick={confirmDelete}
                className="bg-destructive text-destructive-foreground hover:bg-destructive/90"
              >
                Delete
              </AlertDialogAction>
            </AlertDialogFooter>
          </AlertDialogContent>
        </AlertDialog>
      </div>
    </AdminLayout>
  );
}
