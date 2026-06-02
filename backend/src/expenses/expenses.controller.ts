import { Controller, Get, Post, Delete, Body, Param } from '@nestjs/common';
import { ExpensesService } from './expenses.service';

@Controller('expenses')
export class ExpensesController {
  constructor(private readonly expensesService: ExpensesService) {}

  @Post()
  create(
    @Body()
    body: {
      groupId: string;
      payerId: string;
      amount: number;
      description: string;
      category: string;
      date?: string;
      splits: { userId: string; amount: number }[];
    },
  ) {
    return this.expensesService.create(body);
  }

  @Get('group/:groupId')
  findByGroup(@Param('groupId') groupId: string) {
    return this.expensesService.findByGroup(groupId);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.expensesService.findOne(id);
  }

  @Delete(':id')
  delete(@Param('id') id: string) {
    return this.expensesService.delete(id);
  }
}
