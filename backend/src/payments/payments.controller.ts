import { Controller, Get, Post, Patch, Body, Param } from '@nestjs/common';
import { PaymentsService } from './payments.service';

@Controller('payments')
export class PaymentsController {
  constructor(private readonly paymentsService: PaymentsService) {}

  @Post()
  create(
    @Body()
    body: {
      fromUserId: string;
      toUserId: string;
      groupId: string;
      amount: number;
      note?: string;
    },
  ) {
    return this.paymentsService.createPayment(body);
  }

  @Patch(':id/confirm')
  confirm(@Param('id') id: string) {
    return this.paymentsService.confirmPayment(id);
  }

  @Patch(':id/reject')
  reject(@Param('id') id: string) {
    return this.paymentsService.rejectPayment(id);
  }

  @Get('user/:userId')
  findByUser(@Param('userId') userId: string) {
    return this.paymentsService.findByUser(userId);
  }
}
