
import { Module } from '@nestjs/common';
import { ApprovalsModule } from '../approvals/approvals.module';
import { PrismaModule } from '../prisma/prisma.module';
import { SuppliersController } from './suppliers.controller';
import { SuppliersService } from './suppliers.service';

@Module({
    imports: [PrismaModule, ApprovalsModule],
    controllers: [SuppliersController],
    providers: [SuppliersService],
})
export class SuppliersModule { }
