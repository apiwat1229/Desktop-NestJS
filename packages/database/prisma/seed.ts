import { PrismaClient } from '../node_modules/.prisma/client';

const prisma = new PrismaClient();

async function main() {
    console.log('🌱 Seeding database...');

    // Create admin user
    const admin = await prisma.user.upsert({
        where: { email: 'admin@example.com' },
        update: {},
        create: {
            email: 'admin@example.com',
            name: 'Admin User',
            password: '$2b$10$YourHashedPasswordHere', // Use bcrypt to hash in production
            role: 'ADMIN',
        },
    });

    console.log('✅ Created admin user:', admin);

    // Create sample user
    const user = await prisma.user.upsert({
        where: { email: 'user@example.com' },
        update: {},
        create: {
            email: 'user@example.com',
            name: 'Sample User',
            password: '$2b$10$YourHashedPasswordHere', // Use bcrypt to hash in production
            role: 'USER',
        },
    });

    console.log('✅ Created sample user:', user);

    // Create sample post
    const post = await prisma.post.create({
        data: {
            title: 'Welcome to the Monorepo',
            content: 'This is a sample post created during database seeding.',
            published: true,
            authorId: admin.id,
        },
    });

    console.log('✅ Created sample post:', post);

    console.log('🎉 Seeding completed!');
}

main()
    .catch((e) => {
        console.error('❌ Seeding failed:', e);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });
