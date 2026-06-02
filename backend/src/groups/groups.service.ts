import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class GroupsService {
  constructor(private prisma: PrismaService) {}

  async findAll(userId: string) {
    return this.prisma.group.findMany({
      where: { members: { some: { userId } } },
      include: {
        members: {
          include: { user: { select: { id: true, name: true, avatarUrl: true } } },
        },
        _count: { select: { expenses: true } },
      },
      orderBy: { updatedAt: 'desc' },
    });
  }

  async findOne(id: string) {
    return this.prisma.group.findUniqueOrThrow({
      where: { id },
      include: {
        members: {
          include: { user: { select: { id: true, name: true, avatarUrl: true, ibanNumber: true } } },
        },
        expenses: {
          include: {
            payer: { select: { id: true, name: true } },
            splits: true,
          },
          orderBy: { date: 'desc' },
        },
      },
    });
  }

  async create(data: { name: string; description?: string; iconEmoji?: string; createdById: string; memberIds: string[] }) {
    return this.prisma.group.create({
      data: {
        name: data.name,
        description: data.description,
        iconEmoji: data.iconEmoji || '👥',
        createdById: data.createdById,
        members: {
          create: [
            { userId: data.createdById, role: 'ADMIN' },
            ...data.memberIds
              .filter((id) => id !== data.createdById)
              .map((userId) => ({ userId, role: 'MEMBER' as const })),
          ],
        },
      },
    });
  }
}
