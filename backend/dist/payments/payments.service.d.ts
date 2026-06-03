import { PrismaService } from '../prisma/prisma.service';
export declare class PaymentsService {
    private prisma;
    constructor(prisma: PrismaService);
    createPayment(data: {
        fromUserId: string;
        toUserId: string;
        groupId: string;
        amount: number;
        note?: string;
    }): Promise<{
        fromUser: {
            id: string;
            name: string;
        };
        toUser: {
            id: string;
            name: string;
            ibanNumber: string;
        };
    } & {
        id: string;
        createdAt: Date;
        amount: number;
        groupId: string;
        status: string;
        ibanSnapshot: string | null;
        note: string | null;
        confirmedAt: Date | null;
        fromUserId: string;
        toUserId: string;
    }>;
    confirmPayment(paymentId: string): Promise<{
        id: string;
        createdAt: Date;
        amount: number;
        groupId: string;
        status: string;
        ibanSnapshot: string | null;
        note: string | null;
        confirmedAt: Date | null;
        fromUserId: string;
        toUserId: string;
    }>;
    rejectPayment(paymentId: string): Promise<{
        id: string;
        createdAt: Date;
        amount: number;
        groupId: string;
        status: string;
        ibanSnapshot: string | null;
        note: string | null;
        confirmedAt: Date | null;
        fromUserId: string;
        toUserId: string;
    }>;
    findByUser(userId: string): Promise<({
        group: {
            id: string;
            name: string;
        };
        fromUser: {
            id: string;
            name: string;
        };
        toUser: {
            id: string;
            name: string;
        };
    } & {
        id: string;
        createdAt: Date;
        amount: number;
        groupId: string;
        status: string;
        ibanSnapshot: string | null;
        note: string | null;
        confirmedAt: Date | null;
        fromUserId: string;
        toUserId: string;
    })[]>;
}
