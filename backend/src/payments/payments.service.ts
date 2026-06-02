import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class PaymentsService {
  constructor(private prisma: PrismaService) {}

  async createPayment(data: {
    fromUserId: string;
    toUserId: string;
    groupId: string;
    amount: number;
    note?: string;
  }) {
    // Alacaklının IBAN bilgisini yakala
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

  async confirmPayment(paymentId: string) {
    return this.prisma.payment.update({
      where: { id: paymentId },
      data: {
        status: 'CONFIRMED',
        confirmedAt: new Date(),
      },
    });
  }

  async rejectPayment(paymentId: string) {
    return this.prisma.payment.update({
      where: { id: paymentId },
      data: { status: 'REJECTED' },
    });
  }

  async findByUser(userId: string) {
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
}
