import { AuthResponse, LoginDto, RegisterDto } from '@my-app/types';
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { UsersService } from '../users/users.service';

@Injectable()
export class AuthService {
    constructor(
        private usersService: UsersService,
        private jwtService: JwtService
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
        const user = await this.validateUser(loginDto.email, loginDto.password);
        if (!user) {
            throw new UnauthorizedException('Invalid credentials');
        }

        const payload = { email: user.email, sub: user.id, role: user.role };
        return {
            accessToken: this.jwtService.sign(payload),
            user: {
                ...user,
                createdAt: user.createdAt.toISOString(),
                updatedAt: user.updatedAt.toISOString(),
            } as any, // Cast to any to avoid strict type checks on missing optional fields during dev
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

}
