import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
    console.log('🌱 Seeding database...');

    // Create admin user
    const admin = await prisma.user.upsert({
        where: { email: 'admin@example.com' },
        update: {},
        create: {
            email: 'admin@example.com',
            firstName: 'Admin',
            lastName: 'User',
            displayName: 'Admin User',
            password: '$2b$10$YourHashedPasswordHere', // Use bcrypt to hash in production
            role: 'ADMIN',
        },
    });

    console.log('✅ Created admin user:', admin);

    // Create requested admin user
    const ytrcAdmin = await prisma.user.upsert({
        where: { email: 'admin@ytrc.co.th' },
        update: {
            password: '$2b$10$vjIjDP5PS6K/pLgwrkpzTOhNVAkVyqW6.JIWFpwx1mJqhHQ4zvLfC',
            role: 'ADMIN',
        },
        create: {
            email: 'admin@ytrc.co.th',
            firstName: 'YTRC',
            lastName: 'Admin',
            displayName: 'YTRC Admin',
            password: '$2b$10$vjIjDP5PS6K/pLgwrkpzTOhNVAkVyqW6.JIWFpwx1mJqhHQ4zvLfC',
            role: 'ADMIN',
        },
    });

    console.log('✅ Created YTRC admin user:', ytrcAdmin);

    // Create Requested Admin: apiwat.s
    const apiwatAdmin = await prisma.user.upsert({
        where: { email: 'apiwat.s@ytrc.co.th' },
        update: {
            password: '$2b$10$uLQpYm8AOSk6oO5GKJND3u.NsSZhPvgdJZwu1/C8CEgOHEpdV.gRe',
            role: 'ADMIN',
        },
        create: {
            email: 'apiwat.s@ytrc.co.th',
            username: 'apiwat.s',
            firstName: 'Apiwat',
            lastName: 'S',
            displayName: 'Apiwat S.',
            password: '$2b$10$uLQpYm8AOSk6oO5GKJND3u.NsSZhPvgdJZwu1/C8CEgOHEpdV.gRe',
            role: 'ADMIN',
        },
    });
    console.log('✅ Created Admin user: apiwat.s', apiwatAdmin);

    // Create sample user
    const user = await prisma.user.upsert({
        where: { email: 'user@example.com' },
        update: {},
        create: {
            email: 'user@example.com',
            firstName: 'Sample',
            lastName: 'User',
            displayName: 'Sample User',
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

    // Initial Notification Settings
    const defaultSettings = [
        { sourceApp: 'BOOKING', actionType: 'CREATE', active: true, roles: ['ADMIN', 'MANAGER'] },
        { sourceApp: 'BOOKING', actionType: 'CANCEL', active: true, roles: ['ADMIN'] },
        { sourceApp: 'USER', actionType: 'REGISTER', active: true, roles: ['ADMIN'] },
        { sourceApp: 'USER', actionType: 'APPROVAL_REQUEST', active: true, roles: ['ADMIN', 'MANAGER'] },
        { sourceApp: 'SUPPLIER', actionType: 'CREATE', active: true, roles: ['ADMIN', 'PURCHASING'] },
    ];

    for (const setting of defaultSettings) {
        await prisma.notificationSetting.upsert({
            where: {
                sourceApp_actionType: {
                    sourceApp: setting.sourceApp,
                    actionType: setting.actionType,
                }
            },
            update: {}, // Don't overwrite if exists
            create: {
                sourceApp: setting.sourceApp,
                actionType: setting.actionType,
                isActive: setting.active,
                recipientRoles: setting.roles,
                channels: ["IN_APP"]
            }
        });
    }
    console.log('✅ Seeded notification settings');

    console.log('✅ Seeded notification settings');

    // Seed Notification Groups
    const groups = ['MANAGEMENT', 'PRODUCTION', 'HR', 'SALES', 'IT'];
    for (const name of groups) {
        await prisma.notificationGroup.upsert({
            where: { name },
            update: {},
            create: { name }
        });
    }
    console.log('✅ Seeded notification groups');

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
