// Domain Models (matching Prisma schema)

export enum Role {
    USER = 'USER',
    ADMIN = 'ADMIN',
}

export interface User {
    id: string;
    email: string;
    name: string | null;
    password: string;
    role: Role;
    createdAt: Date;
    updatedAt: Date;
}

export interface Post {
    id: string;
    title: string;
    content: string | null;
    published: boolean;
    authorId: string;
    createdAt: Date;
    updatedAt: Date;
}
