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
exports.PaymentsService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
let PaymentsService = class PaymentsService {
    constructor(prisma) {
        this.prisma = prisma;
    }
    async createPayment(data) {
        const toUser = await this.prisma.user.findUniqueOrThrow({
            where: { id: data.toUserId },
            select: { ibanNumber: true },
        });
        return this.prisma.payment.create({
            data: {
                fromUserId: data.fromUserId,
                toUserId: data.toUserId,
                groupId: data.groupId,
                amount: data.amount,
                note: data.note,
                ibanSnapshot: toUser.ibanNumber,
                status: 'PENDING',
            },
            include: {
                fromUser: { select: { id: true, name: true } },
                toUser: { select: { id: true, name: true, ibanNumber: true } },
            },
        });
    }
    async confirmPayment(paymentId) {
        return this.prisma.payment.update({
            where: { id: paymentId },
            data: {
                status: 'CONFIRMED',
                confirmedAt: new Date(),
            },
        });
    }
    async rejectPayment(paymentId) {
        return this.prisma.payment.update({
            where: { id: paymentId },
            data: { status: 'REJECTED' },
        });
    }
    async findByUser(userId) {
        return this.prisma.payment.findMany({
            where: {
                OR: [{ fromUserId: userId }, { toUserId: userId }],
            },
            include: {
                fromUser: { select: { id: true, name: true } },
                toUser: { select: { id: true, name: true } },
                group: { select: { id: true, name: true } },
            },
            orderBy: { createdAt: 'desc' },
        });
    }
};
exports.PaymentsService = PaymentsService;
exports.PaymentsService = PaymentsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], PaymentsService);
//# sourceMappingURL=payments.service.js.map