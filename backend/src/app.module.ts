import { Module } from '@nestjs/common';
import { PrismaModule } from './prisma/prisma.module';
import { GroupsModule } from './groups/groups.module';
import { ExpensesModule } from './expenses/expenses.module';
import { DebtsModule } from './debts/debts.module';
import { PaymentsModule } from './payments/payments.module';
import { UsersModule } from './users/users.module';

@Module({
  imports: [
    PrismaModule,
    UsersModule,
    GroupsModule,
    ExpensesModule,
    DebtsModule,
    PaymentsModule,
  ],
})
export class AppModule {}
