import {
  Briefcase,
  Check,
  Eye,
  EyeOff,
  Lock,
  Plus,
  Shield,
  Trash2,
  Upload,
  User,
  Users,
  X,
} from 'lucide-react';
import { useEffect, useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import AdminLayout from '../../components/AdminLayout';
import ImageCropper from '../../components/ImageCropper';
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
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '../../components/ui/select';
import { Spinner } from '../../components/ui/spinner';
import { useToast } from '../../components/ui/use-toast';
import { usersApi } from '../../lib/api';
import { useAuthStore } from '../../stores/authStore';
import { useUserColumns } from './users/columns';

export default function UsersPage() {
  const { t } = useTranslation();
  const { toast } = useToast();
  const [users, setUsers] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  // Modal State
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingUser, setEditingUser] = useState<any>(null);

  // Detailed Form Data
  const [formData, setFormData] = useState({
    // Account Info
    email: '',
    username: '',
    displayName: '',
    avatar: '',

    // Personal Info
    firstName: '',
    lastName: '',

    // Work Info
    department: '',
    position: '',
    hodId: '',

    // Security & Access
    role: 'USER',
    status: 'ACTIVE',
    password: '',
    confirmPassword: '',
    pinCode: '', // 6 digits
  });

  // UI States
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [avatarPreview, setAvatarPreview] = useState<string>('');

  // Delete Confirmation State
  const [deleteId, setDeleteId] = useState<string | null>(null);
  const [showSaveConfirm, setShowSaveConfirm] = useState(false);

  // Avatar Cropper State
  const [isCropperOpen, setIsCropperOpen] = useState(false);
  const [pendingImage, setPendingImage] = useState<string | null>(null);

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

  useEffect(() => {
    fetchUsers();
  }, []);

  const handleOpenCreate = () => {
    setEditingUser(null);
    setFormData({
      email: '',
      username: '',
      displayName: '',
      firstName: '',
      lastName: '',
      department: '',
      position: '',
      hodId: '',
      role: 'USER',
      status: 'ACTIVE',
      password: '',
      confirmPassword: '',
      pinCode: '',
      avatar: '',
    });
    setAvatarPreview('');
    setIsModalOpen(true);
  };

  const handleOpenEdit = async (user: any) => {
    console.log('handleOpenEdit called with:', user);
    setEditingUser(user);
    setFormData({
      email: user.email || '',
      username: user.username || '',
      displayName: user.displayName || '',
      firstName: user.firstName || '',
      lastName: user.lastName || '',
      department: user.department || '',
      position: user.position || '',
      hodId: user.hodId || '',
      role: user.role || 'USER',
      status: user.status || 'ACTIVE',
      password: '',
      confirmPassword: '',
      pinCode: user.pinCode || '',
      avatar: user.avatar || '',
    });
    setAvatarPreview(user.avatar || '');
    setIsModalOpen(true);

    // Fetch full user details to get avatar if missing from list
    try {
      console.log('Fetching full details for id:', user.id);
      const fullUser = await usersApi.getOne(user.id);
      console.log('Full user details fetched:', fullUser);

      if (fullUser.avatar) {
        console.log('Avatar found in full details, updating preview.');
        setFormData((prev) => ({ ...prev, avatar: fullUser.avatar }));
        setAvatarPreview(fullUser.avatar);
      } else {
        console.log('No avatar in full details.');
      }
    } catch (error) {
      console.error('Failed to fetch full user details:', error);
    }
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

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    console.log('handleSubmit triggered', formData);

    // Manual Validation for required fields
    const missingFields = [];
    if (!formData.username) missingFields.push('username');
    if (!formData.role) missingFields.push('role');
    if (!formData.status) missingFields.push('status');
    if (!formData.department) missingFields.push('department');
    if (!formData.position) missingFields.push('position');

    if (missingFields.length > 0) {
      console.log('Validation failed. Missing:', missingFields);
      toast({
        variant: 'destructive',
        title: t('common.error'),
        description: t(
          'admin.users.requiredFieldsError',
          `Please fill in: ${missingFields.join(', ')}`
        ),
      });
      return;
    }

    if (!editingUser && formData.password !== formData.confirmPassword) {
      toast({
        variant: 'destructive',
        title: t('common.error'),
        description: t('admin.users.passwordMismatch', "Passwords don't match!"),
      });
      return;
    }

    // Bypass confirmation for debugging/UX
    toast({ title: t('common.loading'), description: 'Saving user...' });
    executeSave();
    // setShowSaveConfirm(true);
  };

  const executeSave = async () => {
    try {
      const payload = { ...formData };

      // Cleanup empty fields
      if (!payload.password) delete (payload as any).password;
      delete (payload as any).confirmPassword;
      if (!payload.hodId) delete (payload as any).hodId;
      if (!payload.pinCode) delete (payload as any).pinCode;

      let savedUser;
      if (editingUser) {
        savedUser = await usersApi.update(editingUser.id, payload);

        // Update local session if editing self
        const currentUser = useAuthStore.getState().user;
        if (currentUser && currentUser.id === editingUser.id) {
          useAuthStore.getState().updateUser(savedUser);
        }
      } else {
        await usersApi.create(payload);
      }
      setIsModalOpen(false);
      setShowSaveConfirm(false);
      setAvatarPreview('');
      fetchUsers();
      toast({
        title: t('common.success'),
        description: editingUser ? t('admin.users.updated') : t('admin.users.created'),
      });
    } catch (error: any) {
      console.error('Failed to save user:', error);
      toast({
        variant: 'destructive',
        title: t('common.error'),
        description: error.response?.data?.message || 'Failed to save user',
      });
    }
  };

  const handleAvatarChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      // Check file size (max 2MB)
      if (file.size > 2 * 1024 * 1024) {
        toast({
          variant: 'destructive',
          title: t('common.error'),
          description: t('admin.users.fileSizeError', 'File size must be less than 2MB'),
        });
        return;
      }

      // Check file type
      if (!file.type.startsWith('image/')) {
        toast({
          variant: 'destructive',
          title: t('common.error'),
          description: t('admin.users.fileTypeError', 'Please select an image file'),
        });
        return;
      }

      const reader = new FileReader();
      reader.onloadend = () => {
        setPendingImage(reader.result as string);
        setIsCropperOpen(true);
      };
      reader.readAsDataURL(file);
      // Reset input value so same file selects trigger onChange
      e.target.value = '';
    }
  };

  const handleRemoveAvatar = () => {
    setFormData({ ...formData, avatar: '' });
    setAvatarPreview('');
  };

  const stats = useMemo(() => {
    return {
      total: users.length,
      active: users.filter((u) => u.status === 'ACTIVE').length,
      inactive: users.filter((u) => u.status === 'INACTIVE').length,
      suspended: users.filter((u) => u.status === 'SUSPENDED').length,
    };
  }, [users]);

  // Define columns
  const columns = useUserColumns({
    onEdit: handleOpenEdit,
    onDelete: (id) => setDeleteId(id),
  });

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
        {/* Header */}
        {/* Header Card */}
        <div className="bg-card rounded-xl border border-border shadow-sm p-4 md:p-6 flex flex-col xl:flex-row items-center justify-between gap-6 transition-all hover:shadow-md">
          {/* Left: Title & Icon */}
          <div className="flex items-center gap-4 w-full xl:w-auto">
            <div className="p-3 bg-blue-50 dark:bg-blue-900/20 rounded-xl transition-transform hover:scale-105">
              <Users className="h-6 w-6 text-blue-600 dark:text-blue-400" />
            </div>
            <div>
              <h1 className="text-xl font-bold tracking-tight text-foreground">
                {t('admin.users.title')}
              </h1>
              <p className="text-sm text-muted-foreground">{t('admin.users.subtitle')}</p>
            </div>
          </div>

          {/* Center: Stats Widget */}
          <div className="hidden md:flex items-center bg-background/50 rounded-xl border border-border p-1 shadow-sm">
            <div className="px-6 py-2 flex flex-col items-center min-w-[100px] border-r border-border/50 last:border-0">
              <span className="text-[10px] font-bold text-muted-foreground uppercase tracking-wider">
                {t('admin.status.total')}
              </span>
              <span className="text-lg font-bold text-foreground">{stats.total}</span>
            </div>
            <div className="w-px h-8 bg-border"></div>
            <div className="px-6 py-2 flex flex-col items-center min-w-[100px]">
              <span className="text-[10px] font-bold text-muted-foreground uppercase tracking-wider text-green-600">
                {t('admin.status.active')}
              </span>
              <span className="text-lg font-bold text-green-600">{stats.active}</span>
            </div>
            <div className="w-px h-8 bg-border"></div>
            <div className="px-6 py-2 flex flex-col items-center min-w-[100px]">
              <span className="text-[10px] font-bold text-muted-foreground uppercase tracking-wider text-destructive">
                {t('admin.status.inactive')}
              </span>
              <span className="text-lg font-bold text-destructive">{stats.inactive}</span>
            </div>
            <div className="w-px h-8 bg-border"></div>
            <div className="px-6 py-2 flex flex-col items-center min-w-[100px]">
              <span className="text-[10px] font-bold text-muted-foreground uppercase tracking-wider text-orange-500">
                {t('admin.status.suspended')}
              </span>
              <span className="text-lg font-bold text-orange-500">{stats.suspended}</span>
            </div>
          </div>

          {/* Right: Action Button */}
          <button
            onClick={handleOpenCreate}
            className="w-full xl:w-auto inline-flex items-center justify-center rounded-lg text-sm font-medium transition-all focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 bg-primary text-primary-foreground shadow-lg hover:bg-primary/90 hover:shadow-xl hover:-translate-y-0.5 h-11 px-8"
          >
            <Plus className="mr-2 h-4 w-4" />
            {t('admin.users.addUser')}
          </button>
        </div>

        {/* Users Table */}
        <div className="rounded-xl border border-border bg-card text-card-foreground shadow">
          <div className="bg-card rounded-lg border shadow-sm p-6">
            <DataTable columns={columns} data={users} />
          </div>
        </div>
      </div>

      <AlertDialog open={!!deleteId} onOpenChange={(open) => !open && setDeleteId(null)}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <div className="mx-auto w-12 h-12 rounded-xl bg-red-50 flex items-center justify-center mb-2">
              <Trash2 className="w-6 h-6 text-red-600" />
            </div>
            <AlertDialogTitle>{t('admin.users.deleteConfirm')}</AlertDialogTitle>
            <AlertDialogDescription>{t('admin.users.deleteMessage')}</AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel onClick={() => setDeleteId(null)}>
              {t('common.cancel')}
            </AlertDialogCancel>
            <AlertDialogAction
              onClick={confirmDelete}
              className="bg-destructive text-destructive-foreground"
            >
              {t('common.delete')}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>

      {/* Advanced Create/Edit User Modal */}
      {/* Advanced Create/Edit User Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 w-screen h-screen grid place-items-center p-4 bg-black/50 backdrop-blur-sm animate-in fade-in duration-200">
          <div className="bg-background rounded-xl shadow-2xl border border-border w-full max-w-4xl flex flex-col max-h-[90vh] animate-in zoom-in-95 duration-200 relative">
            {/* Modal Header */}
            <div className="flex-none flex items-center justify-between p-6 border-b border-border bg-muted/10">
              <div>
                <h3 className="text-xl font-bold text-foreground flex items-center gap-2">
                  <Plus className="w-5 h-5 text-primary" />
                  {editingUser
                    ? t('admin.users.editUserAccount')
                    : t('admin.users.createNewUserAccount')}
                </h3>
                <p className="text-sm text-muted-foreground mt-1">
                  {editingUser
                    ? t('admin.users.updateUserDescription')
                    : t('admin.users.createUserDescription')}
                </p>
              </div>
              <button
                onClick={() => setIsModalOpen(false)}
                className="text-muted-foreground hover:text-foreground transition-colors p-2 hover:bg-muted rounded-full"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleSubmit} className="p-8 overflow-y-auto">
              <div className="grid grid-cols-1 lg:grid-cols-2 gap-x-12 gap-y-10">
                {/* LEFT COLUMN */}
                <div className="space-y-10">
                  {/* Account Info */}
                  <div className="space-y-4">
                    <div className="flex items-center gap-2 border-b border-border pb-2">
                      <User className="w-4 h-4 text-primary" />
                      <h4 className="font-semibold text-sm uppercase tracking-wider text-muted-foreground">
                        {t('admin.users.accountInfo')}
                      </h4>
                    </div>

                    <div className="space-y-3">
                      <div>
                        <label className="text-sm font-medium text-foreground mb-1 block">
                          {t('admin.users.email')} <span className="text-destructive">*</span>
                        </label>
                        <input
                          type="email"
                          className="w-full px-3 py-2 bg-background border border-input rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 text-foreground"
                          placeholder="john.doe@company.com"
                          value={formData.email}
                          onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                        />
                      </div>

                      <div className="grid grid-cols-2 gap-4">
                        <div>
                          <label className="text-sm font-medium text-foreground mb-1 block">
                            {t('admin.users.username')} <span className="text-destructive">*</span>
                          </label>
                          <input
                            type="text"
                            className="w-full px-3 py-2 bg-background border border-input rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 text-foreground"
                            placeholder="johndoe"
                            value={formData.username}
                            onChange={(e) => setFormData({ ...formData, username: e.target.value })}
                          />
                        </div>
                        <div>
                          <label className="text-sm font-medium text-foreground mb-1 block">
                            {t('admin.users.displayName')}
                          </label>
                          <input
                            type="text"
                            className="w-full px-3 py-2 bg-background border border-input rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 text-foreground"
                            placeholder="John D."
                            value={formData.displayName}
                            onChange={(e) =>
                              setFormData({ ...formData, displayName: e.target.value })
                            }
                          />
                        </div>
                        <div className="col-span-2">
                          <label className="text-sm font-medium text-foreground mb-1 block">
                            {t('admin.users.avatarImage')}
                          </label>
                          <div className="flex items-start gap-4">
                            {/* Avatar Preview */}
                            <div className="flex-shrink-0">
                              {avatarPreview ? (
                                <div className="relative group">
                                  <img
                                    src={avatarPreview}
                                    alt="Avatar preview"
                                    className="w-20 h-20 rounded-full object-cover border-2 border-border"
                                  />
                                  <button
                                    type="button"
                                    onClick={handleRemoveAvatar}
                                    className="absolute -top-2 -right-2 p-1 bg-destructive text-destructive-foreground rounded-full opacity-0 group-hover:opacity-100 transition-opacity"
                                  >
                                    <X className="w-3 h-3" />
                                  </button>
                                </div>
                              ) : (
                                <div className="w-20 h-20 rounded-full bg-muted flex items-center justify-center border-2 border-dashed border-border">
                                  <User className="w-8 h-8 text-muted-foreground" />
                                </div>
                              )}
                            </div>

                            {/* Upload Button */}
                            <div className="flex-1">
                              <label
                                htmlFor="avatar-upload"
                                className="inline-flex items-center gap-2 px-4 py-2 bg-muted hover:bg-muted/80 text-foreground rounded-md text-sm font-medium cursor-pointer transition-colors border border-border"
                              >
                                <Upload className="w-4 h-4" />
                                {avatarPreview
                                  ? t('admin.users.changeImage')
                                  : t('admin.users.uploadImage')}
                              </label>
                              <input
                                id="avatar-upload"
                                type="file"
                                accept="image/*"
                                className="hidden"
                                onChange={handleAvatarChange}
                              />
                              <p className="text-[10px] text-muted-foreground mt-2">
                                {t('admin.users.maxFileSize')}
                              </p>
                              {pendingImage && (
                                <ImageCropper
                                  open={isCropperOpen}
                                  imageSrc={pendingImage}
                                  onClose={() => setIsCropperOpen(false)}
                                  onCropComplete={(croppedImage) => {
                                    setFormData({ ...formData, avatar: croppedImage });
                                    setAvatarPreview(croppedImage);
                                    setIsCropperOpen(false);
                                  }}
                                />
                              )}
                            </div>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>

                  {/* Personal Info */}
                  <div className="space-y-4">
                    <div className="flex items-center gap-2 border-b border-border pb-2">
                      <span className="w-4 h-4 bg-primary/20 rounded flex items-center justify-center text-[10px] font-bold text-primary">
                        ID
                      </span>
                      <h4 className="font-semibold text-sm uppercase tracking-wider text-muted-foreground">
                        {t('admin.users.personalInfo')}
                      </h4>
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <label className="text-sm font-medium text-foreground mb-1 block">
                          {t('admin.users.firstName')} <span className="text-destructive">*</span>
                        </label>
                        <input
                          type="text"
                          className="w-full px-3 py-2 bg-background border border-input rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 text-foreground"
                          placeholder="John"
                          value={formData.firstName}
                          onChange={(e) => setFormData({ ...formData, firstName: e.target.value })}
                        />
                      </div>
                      <div>
                        <label className="text-sm font-medium text-foreground mb-1 block">
                          {t('admin.users.lastName')} <span className="text-destructive">*</span>
                        </label>
                        <input
                          type="text"
                          className="w-full px-3 py-2 bg-background border border-input rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 text-foreground"
                          placeholder="Doe"
                          value={formData.lastName}
                          onChange={(e) => setFormData({ ...formData, lastName: e.target.value })}
                        />
                      </div>
                    </div>
                  </div>

                  {/* Work Info */}
                  <div className="space-y-4">
                    <div className="flex items-center gap-2 border-b border-border pb-2">
                      <Briefcase className="w-4 h-4 text-primary" />
                      <h4 className="font-semibold text-sm uppercase tracking-wider text-muted-foreground">
                        {t('admin.users.workInfo')}
                      </h4>
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <label className="text-sm font-medium text-foreground mb-1 block">
                          {t('admin.users.department')} <span className="text-destructive">*</span>
                        </label>
                        <div className="relative">
                          <Select
                            value={formData.department}
                            onValueChange={(val) => setFormData({ ...formData, department: val })}
                          >
                            <SelectTrigger>
                              <SelectValue placeholder={t('admin.users.selectDepartment')} />
                            </SelectTrigger>
                            <SelectContent>
                              <SelectItem value="Quality Assurance">
                                {t('admin.departments.qa')}
                              </SelectItem>
                              <SelectItem value="Production">
                                {t('admin.departments.production')}
                              </SelectItem>
                              <SelectItem value="Raw Material Receiving">
                                {t('admin.departments.rawMaterial')}
                              </SelectItem>
                              <SelectItem value="Information Technology">
                                {t('admin.departments.it')}
                              </SelectItem>
                              <SelectItem value="Human Resource">
                                {t('admin.departments.hr')}
                              </SelectItem>
                              <SelectItem value="Accounting">
                                {t('admin.departments.accounting')}
                              </SelectItem>
                              <SelectItem value="Finance">
                                {t('admin.departments.finance')}
                              </SelectItem>
                              <SelectItem value="Purchasing">
                                {t('admin.departments.purchasing')}
                              </SelectItem>
                              <SelectItem value="Shipping">
                                {t('admin.departments.shipping')}
                              </SelectItem>
                            </SelectContent>
                          </Select>
                        </div>
                      </div>
                      <div>
                        <label className="text-sm font-medium text-foreground mb-1 block">
                          {t('admin.users.position')} <span className="text-destructive">*</span>
                        </label>
                        <div className="relative">
                          <Select
                            value={formData.position}
                            onValueChange={(val) => setFormData({ ...formData, position: val })}
                          >
                            <SelectTrigger>
                              <SelectValue placeholder={t('admin.users.selectPosition')} />
                            </SelectTrigger>
                            <SelectContent>
                              <SelectItem value="Managing Director">
                                {t('admin.positions.md')}
                              </SelectItem>
                              <SelectItem value="General Manager">
                                {t('admin.positions.gm')}
                              </SelectItem>
                              <SelectItem value="Manager">
                                {t('admin.positions.manager')}
                              </SelectItem>
                              <SelectItem value="Assistant Manager">
                                {t('admin.positions.asstMgr')}
                              </SelectItem>
                              <SelectItem value="Senior Supervisor">
                                {t('admin.positions.seniorSup')}
                              </SelectItem>
                              <SelectItem value="Supervisor">{t('admin.positions.sup')}</SelectItem>
                              <SelectItem value="Senior Staff 2">
                                {t('admin.positions.seniorStaff2')}
                              </SelectItem>
                              <SelectItem value="Senior Staff 1">
                                {t('admin.positions.seniorStaff1')}
                              </SelectItem>
                              <SelectItem value="Staff 2">{t('admin.positions.staff2')}</SelectItem>
                              <SelectItem value="Staff 1">{t('admin.positions.staff1')}</SelectItem>
                              <SelectItem value="Operator Leader">
                                {t('admin.positions.opLeader')}
                              </SelectItem>
                            </SelectContent>
                          </Select>
                        </div>
                      </div>
                    </div>

                    <div>
                      <label className="text-sm font-medium text-foreground mb-1 block flex items-center gap-1">
                        {t('admin.users.hodUser')}
                        <span className="text-xs text-muted-foreground ml-1 font-normal">
                          {t('admin.users.hodUserHelp')}
                        </span>
                      </label>
                      <div className="relative">
                        <Select
                          value={formData.hodId}
                          onValueChange={(val) => setFormData({ ...formData, hodId: val })}
                        >
                          <SelectTrigger>
                            <SelectValue placeholder={t('admin.users.selectHod')} />
                          </SelectTrigger>
                          <SelectContent>
                            {users
                              .filter((u) => u.id !== editingUser?.id)
                              .map((u) => (
                                <SelectItem key={u.id} value={u.id}>
                                  {u.firstName} {u.lastName} ({u.position})
                                </SelectItem>
                              ))}
                          </SelectContent>
                        </Select>
                      </div>
                    </div>
                  </div>
                </div>

                {/* RIGHT COLUMN */}
                <div className="space-y-10">
                  {/* Security & Access */}
                  <div className="space-y-4">
                    <div className="flex items-center gap-2 border-b border-border pb-2">
                      <Shield className="w-4 h-4 text-primary" />
                      <h4 className="font-semibold text-sm uppercase tracking-wider text-muted-foreground">
                        {t('admin.users.securityAccess')}
                      </h4>
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <label className="text-sm font-medium text-foreground mb-1 block">
                          {t('admin.users.role')} <span className="text-destructive">*</span>
                        </label>
                        <div className="relative">
                          <Select
                            value={formData.role}
                            onValueChange={(val) => setFormData({ ...formData, role: val })}
                          >
                            <SelectTrigger>
                              <SelectValue />
                            </SelectTrigger>
                            <SelectContent>
                              <SelectItem value="USER">{t('admin.users.roles.user')}</SelectItem>
                              <SelectItem value="ADMIN">{t('admin.users.roles.admin')}</SelectItem>
                            </SelectContent>
                          </Select>
                        </div>
                      </div>
                      <div>
                        <label className="text-sm font-medium text-foreground mb-1 block">
                          {t('admin.users.status')} <span className="text-destructive">*</span>
                        </label>
                        <div className="relative">
                          <Select
                            value={formData.status}
                            onValueChange={(val) => setFormData({ ...formData, status: val })}
                          >
                            <SelectTrigger>
                              <SelectValue />
                            </SelectTrigger>
                            <SelectContent>
                              <SelectItem value="ACTIVE">{t('admin.status.active')}</SelectItem>
                              <SelectItem value="INACTIVE">{t('admin.status.inactive')}</SelectItem>
                              <SelectItem value="SUSPENDED">
                                {t('admin.status.suspended')}
                              </SelectItem>
                            </SelectContent>
                          </Select>
                        </div>
                      </div>
                    </div>
                  </div>

                  {/* Password */}
                  <div className="space-y-4">
                    <div className="flex items-center gap-2 border-b border-border pb-2">
                      <Lock className="w-4 h-4 text-primary" />
                      <h4 className="font-semibold text-sm uppercase tracking-wider text-muted-foreground">
                        {t('admin.users.setPassword')}
                      </h4>
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <label className="text-sm font-medium text-foreground mb-1 block">
                          {t('admin.users.password')} <span className="text-destructive">*</span>
                        </label>
                        <div className="relative">
                          <input
                            type={showPassword ? 'text' : 'password'}
                            className="w-full px-3 py-2 bg-background border border-input rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 text-foreground pr-10"
                            placeholder={editingUser ? '(Unchanged)' : '••••••••'}
                            value={formData.password}
                            onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                          />
                          <button
                            type="button"
                            onClick={() => setShowPassword(!showPassword)}
                            className="absolute right-3 top-2.5 text-muted-foreground hover:text-foreground"
                          >
                            {showPassword ? (
                              <EyeOff className="w-4 h-4" />
                            ) : (
                              <Eye className="w-4 h-4" />
                            )}
                          </button>
                        </div>
                      </div>
                      <div>
                        <label className="text-sm font-medium text-foreground mb-1 block">
                          {t('admin.users.confirmPassword')}{' '}
                          <span className="text-destructive">*</span>
                        </label>
                        <div className="relative">
                          <input
                            type={showConfirmPassword ? 'text' : 'password'}
                            className="w-full px-3 py-2 bg-background border border-input rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 text-foreground pr-10"
                            placeholder={editingUser ? '(Unchanged)' : '••••••••'}
                            value={formData.confirmPassword}
                            onChange={(e) =>
                              setFormData({ ...formData, confirmPassword: e.target.value })
                            }
                          />
                          <button
                            type="button"
                            onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                            className="absolute right-3 top-2.5 text-muted-foreground hover:text-foreground"
                          >
                            {showConfirmPassword ? (
                              <EyeOff className="w-4 h-4" />
                            ) : (
                              <Eye className="w-4 h-4" />
                            )}
                          </button>
                        </div>
                      </div>
                    </div>
                  </div>

                  {/* Action Buttons */}
                  <div className="pt-6 border-t border-border flex justify-end gap-3">
                    <button
                      type="button"
                      onClick={() => setIsModalOpen(false)}
                      className="px-6 py-2 text-sm font-medium text-muted-foreground hover:bg-muted rounded-md transition-colors border border-transparent hover:border-border"
                    >
                      {t('common.cancel')}
                    </button>
                    <button
                      type="button"
                      onClick={handleSubmit}
                      className="px-8 py-2 text-sm font-medium bg-primary text-primary-foreground hover:bg-primary/90 rounded-md transition-colors shadow-lg shadow-primary/20 flex items-center gap-2"
                    >
                      <Check className="w-4 h-4" />
                      {editingUser ? t('admin.users.saveChanges') : t('admin.users.confirmCreate')}
                    </button>
                  </div>
                </div>
              </div>
            </form>
          </div>
        </div>
      )}
    </AdminLayout>
  );
}
