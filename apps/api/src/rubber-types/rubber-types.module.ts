import { Module } from '@nestjs/common';
import { ApprovalsModule } from '../approvals/approvals.module';
import { PrismaService } from '../prisma/prisma.service';
import { RubberTypesController } from './rubber-types.controller';
import { RubberTypesService } from './rubber-types.service';

@Module({
    imports: [ApprovalsModule],
    controllers: [RubberTypesController],
    providers: [RubberTypesService, PrismaService],
})
export class RubberTypesModule { }
