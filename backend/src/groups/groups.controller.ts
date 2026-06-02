import { Controller, Get, Post, Body, Param } from '@nestjs/common';
import { GroupsService } from './groups.service';

@Controller('groups')
export class GroupsController {
  constructor(private readonly groupsService: GroupsService) {}

  @Get('user/:userId')
  findAll(@Param('userId') userId: string) {
    return this.groupsService.findAll(userId);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.groupsService.findOne(id);
  }

  @Post()
  create(@Body() body: { name: string; description?: string; iconEmoji?: string; createdById: string; memberIds: string[] }) {
    return this.groupsService.create(body);
  }
}
