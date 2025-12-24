import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { ServeStaticModule } from '@nestjs/serve-static';
import { join } from 'path';
import { AccessControlModule } from './access-control/access-control.module';
import { AnalyticsModule } from './analytics/analytics.module';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ApprovalsModule } from './approvals/approvals.module';
import { AuthModule } from './auth/auth.module';
import { BookingsModule } from './bookings/bookings.module';
import { MasterModule } from './master/master.module';
import { NotificationGroupsModule } from './notification-groups/notification-groups.module';
import { NotificationsModule } from './notifications/notifications.module';
import { PostsModule } from './posts/posts.module';
import { PrismaModule } from './prisma/prisma.module';
import { RolesModule } from './roles/roles.module';
import { RubberTypesModule } from './rubber-types/rubber-types.module';
import { SuppliersModule } from './suppliers/suppliers.module';
import { UsersModule } from './users/users.module';

@Module({
    imports: [
        ConfigModule.forRoot({
            isGlobal: true,
            envFilePath: '../../.env',
        }),
        PrismaModule,
        AuthModule,
        UsersModule,
        SuppliersModule,
        PostsModule,
        MasterModule,
        RubberTypesModule,
        AnalyticsModule,
        BookingsModule,
        RolesModule,
        NotificationsModule,
        ApprovalsModule,
        AccessControlModule,
        NotificationGroupsModule,
        ServeStaticModule.forRoot({
            rootPath: join(process.cwd(), 'uploads'),
            serveRoot: '/uploads',
        }),
    ],
    controllers: [AppController],
    providers: [AppService],
})
export class AppModule { }
