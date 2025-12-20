import { Camera, Loader2, Lock, User as UserIcon } from 'lucide-react';
import Head from 'next/head';
import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import ImageCropper from '../components/ImageCropper';
import { Avatar, AvatarFallback, AvatarImage } from '../components/ui/avatar';
import { Button } from '../components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '../components/ui/card';
import { Input } from '../components/ui/input';
import { Label } from '../components/ui/label';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '../components/ui/tabs';
import { useToast } from '../components/ui/use-toast';
import UserLayout from '../components/UserLayout';
import { usersApi } from '../lib/api';
import { useAuthStore } from '../stores/authStore';

export default function ProfilePage() {
  const { t } = useTranslation();
  const { user, updateUser } = useAuthStore();
  const { toast } = useToast();
  const [isLoading, setIsLoading] = useState(false);
  const [isCropperOpen, setIsCropperOpen] = useState(false);
  const [pendingImage, setPendingImage] = useState<string | null>(null);

  // General Form State
  const [generalForm, setGeneralForm] = useState({
    displayName: '',
    email: '',
    username: '',
    firstName: '',
    lastName: '',
    avatar: '',
  });

  // Password Form State
  const [passwordForm, setPasswordForm] = useState({
    currentPassword: '',
    newPassword: '',
    confirmPassword: '',
  });

  useEffect(() => {
    if (user) {
      setGeneralForm({
        displayName: user.displayName || '',
        email: user.email || '',
        username: user.username || '',
        firstName: user.firstName || '',
        lastName: user.lastName || '',
        avatar: user.avatar || '',
      });
    }
  }, [user]);

  const handleGeneralSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!user?.id) return;

    setIsLoading(true);
    try {
      // In a real app, we would upload the file if changed.
      // For now, we assume simple text updates or URL updates.
      await usersApi.update(user.id, generalForm);
      updateUser(generalForm);
      toast({
        title: t('common.success'),
        description: t('userProfile.updateSuccess'),
        variant: 'success',
      });
    } catch (error) {
      console.error(error);
      toast({
        title: t('common.error'),
        description: t('common.errorOccurred'),
        variant: 'destructive',
      });
    } finally {
      setIsLoading(false);
    }
  };

  const handlePasswordSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!user?.id) return;

    if (passwordForm.newPassword !== passwordForm.confirmPassword) {
      toast({
        title: t('common.error'),
        description: t('userProfile.passwordMismatch'),
        variant: 'destructive',
      });
      return;
    }

    setIsLoading(true);
    try {
      // Assuming the API handles password update via user update
      // or a specific endpoint. Based on typical REST, patching the user
      // with a new password field is common, or a specific endpoint.
      // Since we don't see a specific one, we'll try patching.
      // NOTE: Real security requires current password verification on backend.
      await usersApi.update(user.id, {
        password: passwordForm.newPassword,
        // currentPassword: passwordForm.currentPassword // If backend requires it
      });

      toast({
        title: t('common.success'),
        description: t('userProfile.passwordUpdateSuccess'),
        variant: 'success',
      });
      setPasswordForm({
        currentPassword: '',
        newPassword: '',
        confirmPassword: '',
      });
    } catch (error) {
      console.error(error);
      toast({
        title: t('common.error'),
        description: t('common.errorOccurred'),
        variant: 'destructive',
      });
    } finally {
      setIsLoading(false);
    }
  };

  if (!user) return null;

  return (
    <UserLayout>
      <Head>
        <title>My Profile | App</title>
      </Head>

      <div className="container max-w-4xl py-8 space-y-8">
        <div>
          <h2 className="text-3xl font-bold tracking-tight">{t('userProfile.title')}</h2>
          <p className="text-muted-foreground">{t('userProfile.subtitle')}</p>
        </div>

        <Tabs defaultValue="general" className="w-full">
          <TabsList className="grid w-full grid-cols-2 lg:w-[400px]">
            <TabsTrigger value="general" className="gap-2">
              <UserIcon className="w-4 h-4" />
              {t('userProfile.general')}
            </TabsTrigger>
            <TabsTrigger value="security" className="gap-2">
              <Lock className="w-4 h-4" />
              {t('userProfile.security')}
            </TabsTrigger>
          </TabsList>

          <TabsContent value="general" className="mt-6 space-y-6">
            <Card>
              <CardHeader>
                <CardTitle>{t('userProfile.avatar')}</CardTitle>
                <CardDescription>{t('userProfile.uploadAvatar')}</CardDescription>
              </CardHeader>
              <CardContent className="flex items-center gap-6">
                <Avatar className="w-24 h-24 border-4 border-background shadow-sm">
                  <AvatarImage src={generalForm.avatar} />
                  <AvatarFallback className="text-xl">
                    {user.firstName?.charAt(0) || user.username?.charAt(0)}
                  </AvatarFallback>
                </Avatar>
                <div className="space-y-2">
                  <Label htmlFor="avatar-upload">{t('userProfile.uploadAvatar')}</Label>
                  <div className="flex gap-2 items-center">
                    <Input
                      id="avatar-upload"
                      type="file"
                      accept="image/*"
                      className="hidden"
                      onChange={(e) => {
                        const file = e.target.files?.[0];
                        if (file) {
                          if (file.size > 2 * 1024 * 1024) {
                            toast({
                              title: t('common.error'),
                              description: 'Image size must be less than 2MB',
                              variant: 'destructive',
                            });
                            return;
                          }
                          const reader = new FileReader();
                          reader.onload = () => {
                            setPendingImage(reader.result as string);
                            setIsCropperOpen(true);
                          };
                          reader.readAsDataURL(file);
                          // Reset input value so same file selects trigger onChange
                          e.target.value = '';
                        }
                      }}
                    />
                    <Button
                      type="button"
                      variant="outline"
                      onClick={() => document.getElementById('avatar-upload')?.click()}
                    >
                      <Camera className="w-4 h-4 mr-2" />
                      {t('userProfile.uploadAvatar')}
                    </Button>
                    <p className="text-xs text-muted-foreground">Max 2MB.</p>
                  </div>
                  {pendingImage && (
                    <ImageCropper
                      open={isCropperOpen}
                      imageSrc={pendingImage}
                      onClose={() => setIsCropperOpen(false)}
                      onCropComplete={(croppedImage) => {
                        setGeneralForm({ ...generalForm, avatar: croppedImage });
                        setIsCropperOpen(false);
                      }}
                    />
                  )}
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle>{t('userProfile.personalInfo')}</CardTitle>
                <CardDescription>{t('userProfile.subtitle')}</CardDescription>
              </CardHeader>
              <form onSubmit={handleGeneralSubmit}>
                <CardContent className="space-y-4">
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div className="space-y-2">
                      <Label htmlFor="username">{t('userProfile.username')}</Label>
                      <Input
                        id="username"
                        value={generalForm.username}
                        disabled
                        className="bg-muted"
                      />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="email">{t('userProfile.email')}</Label>
                      <Input
                        id="email"
                        value={generalForm.email}
                        onChange={(e) => setGeneralForm({ ...generalForm, email: e.target.value })}
                      />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="firstName">{t('userProfile.firstName')}</Label>
                      <Input
                        id="firstName"
                        value={generalForm.firstName}
                        onChange={(e) =>
                          setGeneralForm({ ...generalForm, firstName: e.target.value })
                        }
                      />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="lastName">{t('userProfile.lastName')}</Label>
                      <Input
                        id="lastName"
                        value={generalForm.lastName}
                        onChange={(e) =>
                          setGeneralForm({ ...generalForm, lastName: e.target.value })
                        }
                      />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="displayName">{t('userProfile.displayName')}</Label>
                      <Input
                        id="displayName"
                        value={generalForm.displayName}
                        onChange={(e) =>
                          setGeneralForm({ ...generalForm, displayName: e.target.value })
                        }
                      />
                    </div>
                  </div>
                </CardContent>
                <div className="flex justify-end p-6 pt-0">
                  <Button type="submit" disabled={isLoading}>
                    {isLoading && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                    {t('userProfile.saveChanges')}
                  </Button>
                </div>
              </form>
            </Card>
          </TabsContent>

          <TabsContent value="security" className="mt-6">
            <Card>
              <CardHeader>
                <CardTitle>{t('userProfile.changePassword')}</CardTitle>
                <CardDescription>
                  Ensure your account is using a long, random password to stay secure.
                </CardDescription>
              </CardHeader>
              <form onSubmit={handlePasswordSubmit}>
                <CardContent className="space-y-4">
                  <div className="space-y-2">
                    <Label htmlFor="currentPassword">{t('userProfile.currentPassword')}</Label>
                    <Input
                      id="currentPassword"
                      type="password"
                      value={passwordForm.currentPassword}
                      onChange={(e) =>
                        setPasswordForm({ ...passwordForm, currentPassword: e.target.value })
                      }
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="newPassword">{t('userProfile.newPassword')}</Label>
                    <Input
                      id="newPassword"
                      type="password"
                      value={passwordForm.newPassword}
                      onChange={(e) =>
                        setPasswordForm({ ...passwordForm, newPassword: e.target.value })
                      }
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="confirmPassword">{t('profile.confirmPassword')}</Label>
                    <Input
                      id="confirmPassword"
                      type="password"
                      value={passwordForm.confirmPassword}
                      onChange={(e) =>
                        setPasswordForm({ ...passwordForm, confirmPassword: e.target.value })
                      }
                    />
                  </div>
                </CardContent>
                <div className="flex justify-end p-6 pt-0">
                  <Button type="submit" disabled={isLoading}>
                    {isLoading && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                    {t('profile.changePassword')}
                  </Button>
                </div>
              </form>
            </Card>
          </TabsContent>
        </Tabs>
      </div>
    </UserLayout>
  );
}
