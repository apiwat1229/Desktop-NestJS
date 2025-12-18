import { CreatePostDto, UpdatePostDto } from '@my-app/types';
import {
    Body,
    Controller,
    Delete,
    Get,
    Param,
    Patch,
    Post,
    Query,
    Request,
    UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { PostsService } from './posts.service';

@Controller('posts')
export class PostsController {
    constructor(private readonly postsService: PostsService) { }

    @Post()
    @UseGuards(JwtAuthGuard)
    create(@Body() createPostDto: CreatePostDto, @Request() req) {
        return this.postsService.create(createPostDto, req.user.userId);
    }

    @Get()
    findAll(@Query('published') published?: string) {
        const isPublished = published === 'true' ? true : published === 'false' ? false : undefined;
        return this.postsService.findAll(isPublished);
    }

    @Get(':id')
    findOne(@Param('id') id: string) {
        return this.postsService.findOne(id);
    }

    @Patch(':id')
    @UseGuards(JwtAuthGuard)
    update(@Param('id') id: string, @Body() updatePostDto: UpdatePostDto, @Request() req) {
        return this.postsService.update(id, updatePostDto, req.user.userId, req.user.role);
    }

    @Delete(':id')
    @UseGuards(JwtAuthGuard)
    remove(@Param('id') id: string, @Request() req) {
        return this.postsService.remove(id, req.user.userId, req.user.role);
    }
}
