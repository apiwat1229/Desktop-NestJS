import { Body, Controller, Delete, Get, Param, Patch, Post, Query } from '@nestjs/common';
import { BookingsService } from './bookings.service';

@Controller('bookings')
export class BookingsController {
    constructor(private readonly bookingsService: BookingsService) { }

    @Post()
    create(@Body() createDto: any) {
        return this.bookingsService.create(createDto);
    }

    @Get()
    findAll(@Query('date') date?: string, @Query('slot') slot?: string) {
        return this.bookingsService.findAll(date, slot);
    }

    @Get('stats/:date')
    getStats(@Param('date') date: string) {
        return this.bookingsService.getStats(date);
    }

    @Get(':id')
    findOne(@Param('id') id: string) {
        return this.bookingsService.findOne(id);
    }

    @Patch(':id')
    update(@Param('id') id: string, @Body() updateDto: any) {
        return this.bookingsService.update(id, updateDto);
    }

    @Delete(':id')
    remove(@Param('id') id: string) {
        return this.bookingsService.remove(id);
    }
}
