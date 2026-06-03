import { PrismaService } from '../prisma/prisma.service';
export declare class ExpensesService {
    private prisma;
    constructor(prisma: PrismaService);
    create(data: {
        groupId: string;
        payerId: string;
        amount: number;
        description: string;
        category: string;
        date?: string;
        splits: {
            userId: string;
            amount: number;
        }[];
    }): Promise<{
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
    }>;
    findByGroup(groupId: string): Promise<({
        payer: {
            id: string;
            name: string;
            avatarUrl: string;
        };
        splits: ({
            user: {
                id: string;
                name: string;
            };
        } & {
            id: string;
            amount: number;
            userId: string;
            expenseId: string;
        })[];
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
    })[]>;
    findOne(id: string): Promise<{
        payer: {
            id: string;
            name: string;
        };
        splits: ({
            user: {
                id: string;
                name: string;
            };
        } & {
            id: string;
            amount: number;
            userId: string;
            expenseId: string;
        })[];
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
    }>;
    delete(id: string): Promise<{
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
    }>;
}
