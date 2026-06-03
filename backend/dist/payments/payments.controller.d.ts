import { PaymentsService } from './payments.service';
export declare class PaymentsController {
    private readonly paymentsService;
    constructor(paymentsService: PaymentsService);
    create(body: {
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
    confirm(id: string): Promise<{
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
    reject(id: string): Promise<{
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
