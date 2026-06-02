import { Controller, Get, Param } from '@nestjs/common';
import { DebtsService } from './debts.service';

@Controller('debts')
export class DebtsController {
  constructor(private readonly debtsService: DebtsService) {}

  /**
   * Bir grubun borç analizini döndürür.
   * Minimum Cash Flow algoritması ile sadeleştirilmiş borçlar dahil.
   */
  @Get('group/:groupId/summary')
  async getDebtSummary(@Param('groupId') groupId: string) {
    return this.debtsService.calculateDebtSummary(groupId);
  }
}
