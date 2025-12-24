import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsDateString, IsEnum, IsObject, IsOptional, IsString } from 'class-validator';

export class CreateApprovalRequestDto {
    @ApiProperty({ example: 'SUPPLIER_DELETE', description: 'Type of request' })
    @IsString()
    requestType: string;

    @ApiProperty({ example: 'Supplier', description: 'Entity type' })
    @IsString()
    entityType: string;

    @ApiProperty({ example: 'uuid', description: 'Entity ID' })
    @IsString()
    entityId: string;

    @ApiProperty({ example: 'USER_MANAGEMENT', description: 'Source application' })
    @IsString()
    sourceApp: string;

    @ApiProperty({ example: 'DELETE', description: 'Action type' })
    @IsString()
    actionType: string;

    @ApiPropertyOptional({ description: 'Current data snapshot' })
    @IsOptional()
    @IsObject()
    currentData?: any;

    @ApiPropertyOptional({ description: 'Proposed data changes' })
    @IsOptional()
    @IsObject()
    proposedData?: any;

    @ApiPropertyOptional({ example: 'Need to remove inactive supplier', description: 'Reason for request' })
    @IsOptional()
    @IsString()
    reason?: string;

    @ApiPropertyOptional({ enum: ['LOW', 'NORMAL', 'HIGH', 'URGENT'], default: 'NORMAL' })
    @IsOptional()
    @IsEnum(['LOW', 'NORMAL', 'HIGH', 'URGENT'])
    priority?: string;

    @ApiPropertyOptional({ description: 'Expiry date for the request' })
    @IsOptional()
    @IsDateString()
    expiresAt?: string;
}

export class ApproveDto {
    @ApiPropertyOptional({ example: 'Approved after verification', description: 'Approval remark' })
    @IsOptional()
    @IsString()
    remark?: string;
}

export class RejectDto {
    @ApiProperty({ example: 'Invalid data provided', description: 'Rejection reason' })
    @IsString()
    remark: string;
}

export class VoidDto {
    @ApiProperty({ example: 'Found error in approved data', description: 'Void reason' })
    @IsString()
    reason: string;
}

export class ReturnDto {
    @ApiProperty({ example: 'Please provide more details', description: 'Return reason' })
    @IsString()
    remark: string;
}

export class CancelDto {
    @ApiPropertyOptional({ example: 'No longer needed', description: 'Cancellation reason' })
    @IsOptional()
    @IsString()
    reason?: string;
}
