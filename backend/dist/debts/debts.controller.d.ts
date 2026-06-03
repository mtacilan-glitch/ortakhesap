import { DebtsService } from './debts.service';
export declare class DebtsController {
    private readonly debtsService;
    constructor(debtsService: DebtsService);
    getDebtSummary(groupId: string): Promise<import("./debts.service").DebtSummary>;
}
