import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class ExpensesService {
  constructor(private prisma: PrismaService) {}

  async create(data: {
    groupId: string;
    payerId: string;
    amount: number;
    description: string;
    category: string;
    date?: string;
    splits: { userId: string; amount: number }[];
  }) {
    return this.prisma.expense.create({
      data: {
        groupId: data.groupId,
        payerId: data.payerId,
        amount: data.amount,
        description: data.description,
        category: data.category as any,
        date: data.date ? new Date(data.date) : new Date(),
        splits: {
          create: data.splits.map((s) => ({
            userId: s.userId,
            amount: s.amount,
          })),
        },
      },
      include: {
        splits: true,
        payer: { select: { id: true, name: true } },
      },
    });
  }

  async findByGroup(groupId: string) {
    return this.prisma.expense.findMany({
      where: { groupId },
      include: {
        payer: { select: { id: true, name: true, avatarUrl: true } },
        splits: {
          include: { user: { select: { id: true, name: true } } },
        },
      },
      orderBy: { date: 'desc' },
    });
  }

  async findOne(id: string) {
    return this.prisma.expense.findUniqueOrThrow({
      where: { id },
      include: {
        payer: { select: { id: true, name: true } },
        splits: {
          include: { user: { select: { id: true, name: true } } },
        },
      },
    });
  }

  async delete(id: string) {
    return this.prisma.expense.delete({ where: { id } });
  }
}
