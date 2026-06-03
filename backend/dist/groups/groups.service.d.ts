import { PrismaService } from '../prisma/prisma.service';
export declare class GroupsService {
    private prisma;
    constructor(prisma: PrismaService);
    findAll(userId: string): Promise<({
        members: ({
            user: {
                id: string;
                name: string;
                avatarUrl: string;
            };
        } & {
            id: string;
            groupId: string;
            role: string;
            joinedAt: Date;
            userId: string;
        })[];
        _count: {
            expenses: number;
        };
    } & {
        id: string;
        name: string;
        description: string | null;
        iconEmoji: string;
        createdAt: Date;
        updatedAt: Date;
        createdById: string;
    })[]>;
    findOne(id: string): Promise<{
        members: ({
            user: {
                id: string;
                name: string;
                ibanNumber: string;
                avatarUrl: string;
            };
        } & {
            id: string;
            groupId: string;
            role: string;
            joinedAt: Date;
            userId: string;
        })[];
        expenses: ({
            payer: {
                id: string;
                name: string;
            };
            splits: {
                id: string;
                amount: number;
                userId: string;
                expenseId: string;
            }[];
        } & {
            id: string;
            description: string;
            createdAt: Date;
            updatedAt: Date;
            date: Date;
            amount: number;
            category: string;
            splitType: string;
            groupId: string;
            payerId: string;
        })[];
    } & {
        id: string;
        name: string;
        description: string | null;
        iconEmoji: string;
        createdAt: Date;
        updatedAt: Date;
        createdById: string;
    }>;
    create(data: {
        name: string;
        description?: string;
        iconEmoji?: string;
        createdById: string;
        memberIds: string[];
    }): Promise<{
        id: string;
        name: string;
        description: string | null;
        iconEmoji: string;
        createdAt: Date;
        updatedAt: Date;
        createdById: string;
    }>;
}
