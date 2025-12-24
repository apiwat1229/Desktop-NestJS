import { AuthResponse, LoginDto, RegisterDto } from '@my-app/types';
import { ForbiddenException, Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { NotificationsService } from '../notifications/notifications.service';
import { UsersService } from '../users/users.service';

@Injectable()
export class AuthService {
    constructor(
        private usersService: UsersService,
        private jwtService: JwtService,
        private notificationsService: NotificationsService
    ) { }

    async validateUser(identifier: string, password: string): Promise<any> {
        const user = await this.usersService.findByEmailOrUsername(identifier);

        if (user && (await bcrypt.compare(password, user.password))) {
            const { password, ...result } = user;
            return result;
        }
        return null;
    }

    async login(loginDto: LoginDto): Promise<AuthResponse> {
        const identifier = loginDto.email || loginDto.username;
        if (!identifier) {
            throw new UnauthorizedException('Email or Username is required');
        }
        // Check if user exists
        const user = await this.usersService.findByEmailOrUsername(identifier);
        if (!user) {
            throw new UnauthorizedException('User not found');
        }

        // Check if locked
        if (user.status === 'SUSPENDED') {
            throw new UnauthorizedException('Account is locked. Please contact admin.');
        }

        // Check password
        const isMatch = await bcrypt.compare(loginDto.password, user.password);
        if (!isMatch) {
            // Increment failed attempts
            const attempts = (user.failedLoginAttempts || 0) + 1;
            const shouldLock = attempts >= 5;

            await this.usersService.updateLoginAttempts(user.id, attempts, shouldLock);

            if (shouldLock) {
                // Notify IT group
                await this.notifyITGroup(user);
                throw new UnauthorizedException('Account has been locked due to multiple failed login attempts. Please contact IT support.');
            }
            const remaining = 5 - attempts;
            throw new UnauthorizedException(`Password incorrect. ${remaining} attempts remaining.`);
        }

        // Reset attempts on success
        if (user.failedLoginAttempts > 0) {
            await this.usersService.updateLoginAttempts(user.id, 0);
        }


        if (user.forceChangePassword) {
            // Create a temporary token specifically for changing password
            const tempToken = this.jwtService.sign(
                { sub: user.id, email: user.email, scope: 'CHANGE_PASSWORD' },
                { expiresIn: '30m' }
            );

            throw new ForbiddenException({
                code: 'MUST_CHANGE_PASSWORD',
                tempToken,
                message: 'You must change your password to continue.'
            });
        }

        // Update last login
        await this.usersService.updateLastLogin(user.id);

        const payload = { email: user.email, sub: user.id, role: user.role };
        return {
            accessToken: this.jwtService.sign(payload),
            user: {
                ...user,
                createdAt: user.createdAt.toISOString(),
                updatedAt: user.updatedAt.toISOString(),
            } as any,
        };
    }


    async register(registerDto: RegisterDto): Promise<AuthResponse> {
        const hashedPassword = await bcrypt.hash(registerDto.password, 10);
        const user = await this.usersService.create({
            ...registerDto,
            password: hashedPassword,
        });

        const { password, ...userWithoutPassword } = user;
        const payload = { email: user.email, sub: user.id, role: user.role };

        return {
            accessToken: this.jwtService.sign(payload),
            user: {
                ...userWithoutPassword,
                createdAt: userWithoutPassword.createdAt.toISOString(),
                updatedAt: userWithoutPassword.updatedAt.toISOString(),
            } as any,
        };
    }

    async signup(signupDto: any) {
        // Check if email already exists
        const existingUser = await this.usersService.findByEmailOrUsername(signupDto.email);

        if (existingUser) {
            throw new ForbiddenException('Email already registered');
        }

        // Hash password
        const hashedPassword = await bcrypt.hash(signupDto.password, 10);

        // Create user with PENDING status and no role
        const user = await this.usersService.createPendingUser({
            email: signupDto.email,
            firstName: signupDto.firstName,
            lastName: signupDto.lastName,
            password: hashedPassword,
        });

        return {
            message: 'Account created successfully. Please wait for admin approval.',
            userId: user.id,
        };
    }

    async changePassword(userId: string, oldPass: string, newPass: string) {
        // 1. Get user to get current password hash
        const user = await this.usersService.findOne(userId); // findOne typically returns user without password if select is used?
        // Wait, usersService.findOne selects specific fields. Currently it does NOT select password.
        // I need to use findByEmail or a new method `findForAuth` that returns password.

        // I can use `this.usersService.findByEmailOrUsername(user.email)` if I have email?
        // findOne does NOT return password.
        // But `findByEmail` DOES return password (in `select`).
        // So I can use `user.email` from `findOne` to call `findByEmail`.
        // Or I can just use `prisma` directly if I injected it? No, explicit dependency is better.
        // Let's rely on `findByEmail` or add `findWithPassword`.

        // Actually, users.service `findByEmail` (step 220) selects `password: true`.
        // users.service `findOne` (step 175) does NOT select password.

        const fullUser = await this.usersService.findByEmail(user.email);

        if (!fullUser || !fullUser.password) {
            throw new UnauthorizedException('User not found');
        }

        const isMatch = await bcrypt.compare(oldPass, fullUser.password);
        if (!isMatch) {
            throw new UnauthorizedException('Old password is incorrect');
        }

        const hashedPassword = await bcrypt.hash(newPass, 10);

        await this.usersService.update(userId, {
            password: hashedPassword,
            forceChangePassword: false,
        });

        return { message: 'Password changed successfully' };
    }

    /**
     * Notify IT group when account is locked
     */
    private async notifyITGroup(user: any) {
        try {
            // Get IT group members
            const itGroup = await this.notificationsService.getGroupMembers('IT');

            if (!itGroup || itGroup.length === 0) {
                console.warn('[Auth] IT group not found or has no members');
                return;
            }

            // Send notification to each IT member
            for (const member of itGroup) {
                await this.notificationsService.create({
                    userId: member.id,
                    title: 'Account Locked - Security Alert',
                    message: `User account ${user.email} (${user.displayName || 'N/A'}) has been locked due to 5 failed login attempts.`,
                    type: 'WARNING',
                    sourceApp: 'AUTH',
                    actionType: 'ACCOUNT_LOCKED',
                    entityId: user.id,
                    actionUrl: `/admin/users`,
                });
            }

            console.log(`[Auth] Notified ${itGroup.length} IT members about locked account: ${user.email}`);
        } catch (error) {
            console.error('[Auth] Failed to notify IT group:', error);
            // Don't throw - notification failure shouldn't prevent lock
        }
    }
}
