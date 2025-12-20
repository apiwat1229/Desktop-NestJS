// API Request/Response Types
import { Type } from 'class-transformer';
import { IsArray, IsDate, IsEmail, IsNotEmpty, IsNumber, IsOptional, IsString } from 'class-validator';

export interface ApiResponse<T = any> {
    success: boolean;
    data?: T;
    error?: string;
    message?: string;
}

export interface PaginatedResponse<T> {
    data: T[];
    total: number;
    page: number;
    pageSize: number;
    totalPages: number;
}

// Auth DTOs
export interface LoginDto {
    email: string;
    password: string;
}

export interface RegisterDto {
    email: string;
    password: string;
    username?: string;
    firstName?: string;
    lastName?: string;
}

export interface AuthResponse {
    accessToken: string;
    user: UserDto;
}

// User DTOs
export interface UserDto {
    id: string;
    email: string;
    username: string | null;
    firstName: string | null;
    lastName: string | null;
    displayName: string | null;
    department: string | null;
    position: string | null;
    role: 'USER' | 'ADMIN';
    status: 'ACTIVE' | 'INACTIVE' | 'SUSPENDED';
    pinCode: string | null;
    hodId: string | null;
    avatar: string | null;
    createdAt: string;
    updatedAt: string;
}

export interface CreateUserDto {
    email: string;
    password: string;
    username?: string;
    firstName?: string;
    lastName?: string;
    displayName?: string;
    department?: string;
    position?: string;
    role?: 'USER' | 'ADMIN';
    status?: 'ACTIVE' | 'INACTIVE' | 'SUSPENDED';
    pinCode?: string;
    hodId?: string;
    avatar?: string;
}

export class UpdateUserDto {
    @IsOptional()
    @IsString()
    username?: string;

    @IsOptional()
    @IsEmail()
    email?: string;

    @IsOptional()
    @IsString()
    password?: string;

    @IsOptional()
    @IsString()
    firstName?: string;

    @IsOptional()
    @IsString()
    lastName?: string;

    @IsOptional()
    @IsString()
    displayName?: string;

    @IsOptional()
    @IsString()
    department?: string;

    @IsOptional()
    @IsString()
    position?: string;

    @IsOptional()
    @IsString()
    role?: string;

    @IsOptional()
    @IsString()
    status?: string;

    @IsOptional()
    @IsString()
    pinCode?: string;

    @IsOptional()
    @IsString()
    hodId?: string;

    @IsOptional()
    @IsString()
    avatar?: string;
}

export class CreateSupplierDto {
    @IsString()
    @IsNotEmpty()
    code!: string;

    @IsString()
    @IsNotEmpty()
    name!: string;

    @IsOptional()
    @IsString()
    firstName?: string;

    @IsOptional()
    @IsString()
    lastName?: string;

    @IsOptional()
    @IsString()
    title?: string;

    @IsOptional()
    @IsString()
    taxId?: string;

    @IsOptional()
    @IsString()
    address?: string;

    @IsOptional()
    @IsNumber()
    provinceId?: number;

    @IsOptional()
    @IsNumber()
    districtId?: number;

    @IsOptional()
    @IsNumber()
    subdistrictId?: number;

    @IsOptional()
    @IsString()
    zipCode?: string;

    @IsOptional()
    @IsString()
    phone?: string;

    @IsOptional()
    @IsEmail()
    email?: string;

    @IsOptional()
    @IsString()
    status?: string;

    @IsOptional()
    @IsString()
    avatar?: string;

    @IsOptional()
    @IsString()
    certificateNumber?: string;

    @IsOptional()
    @Type(() => Date)
    @IsDate()
    certificateExpire?: Date;

    @IsOptional()
    @IsNumber()
    score?: number;

    @IsOptional()
    @IsNumber()
    eudrQuotaUsed?: number;

    @IsOptional()
    @IsNumber()
    eudrQuotaCurrent?: number;

    @IsOptional()
    @IsArray()
    @IsString({ each: true })
    rubberTypeCodes?: string[];

    @IsOptional()
    @IsString()
    notes?: string;
}

export class UpdateSupplierDto {
    @IsOptional()
    @IsString()
    code?: string;

    @IsOptional()
    @IsString()
    name?: string;

    @IsOptional()
    @IsString()
    firstName?: string;

    @IsOptional()
    @IsString()
    lastName?: string;

    @IsOptional()
    @IsString()
    title?: string;

    @IsOptional()
    @IsString()
    taxId?: string;

    @IsOptional()
    @IsString()
    address?: string;

    @IsOptional()
    @IsNumber()
    provinceId?: number;

    @IsOptional()
    @IsNumber()
    districtId?: number;

    @IsOptional()
    @IsNumber()
    subdistrictId?: number;

    @IsOptional()
    @IsString()
    zipCode?: string;

    @IsOptional()
    @IsString()
    phone?: string;

    @IsOptional()
    @IsEmail()
    email?: string;

    @IsOptional()
    @IsString()
    status?: string;

    @IsOptional()
    @IsString()
    avatar?: string;

    @IsOptional()
    @IsString()
    certificateNumber?: string;

    @IsOptional()
    @Type(() => Date)
    @IsDate()
    certificateExpire?: Date;

    @IsOptional()
    @IsNumber()
    score?: number;

    @IsOptional()
    @IsNumber()
    eudrQuotaUsed?: number;

    @IsOptional()
    @IsNumber()
    eudrQuotaCurrent?: number;

    @IsOptional()
    @IsArray()
    @IsString({ each: true })
    rubberTypeCodes?: string[];

    @IsOptional()
    @IsString()
    notes?: string;
}

// Post DTOs
export interface PostDto {
    id: string;
    title: string;
    content: string | null;
    published: boolean;
    authorId: string;
    author?: UserDto;
    createdAt: string;
    updatedAt: string;
}

export interface CreatePostDto {
    title: string;
    content?: string;
    published?: boolean;
    authorId?: string; // Optional if inferred from auth
}

export interface UpdatePostDto {
    title?: string;
    content?: string;
    published?: boolean;
}
