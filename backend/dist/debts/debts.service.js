"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.DebtsService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
let DebtsService = class DebtsService {
    constructor(prisma) {
        this.prisma = prisma;
    }
    async calculateDebtSummary(groupId) {
        const group = await this.prisma.group.findUniqueOrThrow({
            where: { id: groupId },
            include: {
                members: {
                    include: { user: { select: { id: true, name: true } } },
                },
                expenses: {
                    include: {
                        payer: { select: { id: true, name: true } },
                        splits: {
                            include: { user: { select: { id: true, name: true } } },
                        },
                    },
                },
                payments: {
                    where: { status: 'CONFIRMED' },
                },
            },
        });
        const totalExpenses = group.expenses.reduce((sum, exp) => sum + Number(exp.amount), 0);
        const balanceMap = new Map();
        for (const member of group.members) {
            balanceMap.set(member.user.id, {
                name: member.user.name,
                balance: 0,
            });
        }
        for (const expense of group.expenses) {
            const payerData = balanceMap.get(expense.payerId);
            if (payerData) {
                payerData.balance += Number(expense.amount);
            }
            for (const split of expense.splits) {
                const splitUserData = balanceMap.get(split.userId);
                if (splitUserData) {
                    splitUserData.balance -= Number(split.amount);
                }
            }
        }
        for (const payment of group.payments) {
            const senderData = balanceMap.get(payment.fromUserId);
            const receiverData = balanceMap.get(payment.toUserId);
            if (senderData)
                senderData.balance += Number(payment.amount);
            if (receiverData)
                receiverData.balance -= Number(payment.amount);
        }
        const balances = [];
        for (const [userId, data] of balanceMap) {
            balances.push({
                userId,
                userName: data.name,
                netBalance: Math.round(data.balance * 100) / 100,
            });
        }
        const simplifiedDebts = this.minimumCashFlow(balances);
        const originalDebtCount = this.countOriginalDebts(group.expenses);
        return {
            groupId: group.id,
            groupName: group.name,
            totalExpenses,
            balances,
            simplifiedDebts,
            originalDebtCount,
            simplifiedDebtCount: simplifiedDebts.length,
        };
    }
    minimumCashFlow(balances) {
        const transactions = [];
        const working = balances
            .map((b) => ({ ...b }))
            .filter((b) => Math.abs(b.netBalance) > 0.01);
        while (working.length > 0) {
            let minIdx = 0;
            for (let i = 1; i < working.length; i++) {
                if (working[i].netBalance < working[minIdx].netBalance) {
                    minIdx = i;
                }
            }
            let maxIdx = 0;
            for (let i = 1; i < working.length; i++) {
                if (working[i].netBalance > working[maxIdx].netBalance) {
                    maxIdx = i;
                }
            }
            if (Math.abs(working[minIdx].netBalance) < 0.01 &&
                Math.abs(working[maxIdx].netBalance) < 0.01) {
                break;
            }
            const debtor = working[minIdx];
            const creditor = working[maxIdx];
            const transferAmount = Math.round(Math.min(Math.abs(debtor.netBalance), creditor.netBalance) * 100) / 100;
            if (transferAmount < 0.01)
                break;
            transactions.push({
                fromUserId: debtor.userId,
                fromUserName: debtor.userName,
                toUserId: creditor.userId,
                toUserName: creditor.userName,
                amount: transferAmount,
            });
            debtor.netBalance += transferAmount;
            creditor.netBalance -= transferAmount;
            for (let i = working.length - 1; i >= 0; i--) {
                if (Math.abs(working[i].netBalance) < 0.01) {
                    working.splice(i, 1);
                }
            }
        }
        return transactions;
    }
    countOriginalDebts(expenses) {
        let count = 0;
        for (const expense of expenses) {
            for (const split of expense.splits) {
                if (split.userId !== expense.payerId && Number(split.amount) > 0) {
                    count++;
                }
            }
        }
        return count;
    }
};
exports.DebtsService = DebtsService;
exports.DebtsService = DebtsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], DebtsService);
//# sourceMappingURL=debts.service.js.map