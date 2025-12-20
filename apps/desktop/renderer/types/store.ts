export interface User {
    id: string;
    email: string;
    username: string;
    name?: string; // Kept for backward compatibility
    firstName?: string;
    lastName?: string;
    displayName?: string;
    avatar?: string;
    role?: string;
    roles?: string[];
    department?: string;
    position?: string;
}

export interface AuthState {
    user: User | null;
    accessToken: string | null;
    isAuthenticated: boolean;
    login: (user: User, token: string) => void;
    logout: () => void;
    updateUser: (user: Partial<User>) => void;
}

export interface Settings {
    theme: 'light' | 'dark' | 'system';
    fontSize: number;
    primaryColor: string;
    borderRadius: number;
    fontFamily: string;
}

export interface SettingsState extends Settings {
    setTheme: (theme: Settings['theme']) => void;
    setFontSize: (size: number) => void;
    setPrimaryColor: (color: string) => void;
    setBorderRadius: (radius: number) => void;
    setFontFamily: (family: string) => void;
    resetSettings: () => void;
}
