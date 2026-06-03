import { PrismaService } from '../prisma/prisma.service';
export interface DebtTransaction {
    fromUserId: string;
    fromUserName: string;
    toUserId: string;
    toUserName: string;
    amount: number;
}
export interface UserBalance {
    userId: string;
    userName: string;
    netBalance: number;
}
export interface DebtSummary {
    groupId: string;
    groupName: string;
    totalExpenses: number;
    balances: UserBalance[];
    simplifiedDebts: DebtTransaction[];
    originalDebtCount: number;
    simplifiedDebtCount: number;
}
export declare class DebtsService {
    private prisma;
    constructor(prisma: PrismaService);
    calculateDebtSummary(groupId: string): Promise<DebtSummary>;
    private minimumCashFlow;
    private countOriginalDebts;
}
