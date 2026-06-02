import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

// ─── Tip Tanımları ───────────────────────────────────────────

export interface DebtTransaction {
  fromUserId: string;
  fromUserName: string;
  toUserId: string;
  toUserName: string;
  amount: number;
}

export interface UserBalance {
  userId: string;
  userName: string;
  netBalance: number; // Pozitif = Alacaklı, Negatif = Borçlu
}

export interface DebtSummary {
  groupId: string;
  groupName: string;
  totalExpenses: number;
  balances: UserBalance[];
  simplifiedDebts: DebtTransaction[];
  originalDebtCount: number;
  simplifiedDebtCount: number;
}

// ─── Akıllı Borç Sadeleştirme Servisi ───────────────────────

@Injectable()
export class DebtsService {
  constructor(private prisma: PrismaService) {}

  /**
   * Bir grubun tüm borç ilişkilerini analiz eder ve
   * Minimum Cash Flow algoritması ile sadeleştirir.
   *
   * Algoritma Adımları:
   * 1. Her kullanıcı için net bakiye hesapla
   *    net[u] = Σ(ödediği harcamalar) - Σ(borçlandığı paylar)
   * 2. Pozitif bakiye → Alacaklı, Negatif bakiye → Borçlu
   * 3. Greedy eşleştirme ile minimum sayıda transfer oluştur
   */
  async calculateDebtSummary(groupId: string): Promise<DebtSummary> {
    // Grup bilgisi ve üyelerini al
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

    // 1. Toplam harcamayı hesapla
    const totalExpenses = group.expenses.reduce(
      (sum, exp) => sum + Number(exp.amount),
      0,
    );

    // 2. Her kullanıcı için net bakiye hesapla
    const balanceMap = new Map<string, { name: string; balance: number }>();

    // Üyeleri başlat
    for (const member of group.members) {
      balanceMap.set(member.user.id, {
        name: member.user.name,
        balance: 0,
      });
    }

    // Harcamaları işle
    for (const expense of group.expenses) {
      // Ödeme yapan kişi: ödediği kadar alacaklı
      const payerData = balanceMap.get(expense.payerId);
      if (payerData) {
        payerData.balance += Number(expense.amount);
      }

      // Bölüşüme dahil olan kişiler: payları kadar borçlu
      for (const split of expense.splits) {
        const splitUserData = balanceMap.get(split.userId);
        if (splitUserData) {
          splitUserData.balance -= Number(split.amount);
        }
      }
    }

    // Onaylanmış ödemeleri de hesaba kat
    for (const payment of group.payments) {
      const senderData = balanceMap.get(payment.fromUserId);
      const receiverData = balanceMap.get(payment.toUserId);
      if (senderData) senderData.balance += Number(payment.amount);
      if (receiverData) receiverData.balance -= Number(payment.amount);
    }

    // 3. Bakiyeleri listele
    const balances: UserBalance[] = [];
    for (const [userId, data] of balanceMap) {
      balances.push({
        userId,
        userName: data.name,
        netBalance: Math.round(data.balance * 100) / 100,
      });
    }

    // 4. Minimum Cash Flow ile sadeleştirilmiş borçları hesapla
    const simplifiedDebts = this.minimumCashFlow(balances);

    // 5. Orijinal borç sayısını hesapla (karşılaştırma için)
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

  /**
   * ════════════════════════════════════════════════════════════
   *  MİNİMUM CASH FLOW ALGORİTMASI
   * ════════════════════════════════════════════════════════════
   *
   * Greedy yaklaşım:
   * - En büyük borçluyu ve en büyük alacaklıyı bul
   * - İkisinin arasında min(|borç|, |alacak|) kadar transfer oluştur
   * - Bakiyeleri güncelle, sıfırlanan kişiyi çıkar
   * - Kalan kişilerle tekrarla
   *
   * Zaman Karmaşıklığı: O(n²) (n = kullanıcı sayısı)
   * Bu, küçük-orta gruplar için ideal performans sunar.
   */
  private minimumCashFlow(balances: UserBalance[]): DebtTransaction[] {
    const transactions: DebtTransaction[] = [];

    // Çalışma kopyası oluştur
    const working = balances
      .map((b) => ({ ...b }))
      .filter((b) => Math.abs(b.netBalance) > 0.01); // Sıfıra yakın bakiyeleri ele

    while (working.length > 0) {
      // En büyük borçluyu bul (en negatif bakiye)
      let minIdx = 0;
      for (let i = 1; i < working.length; i++) {
        if (working[i].netBalance < working[minIdx].netBalance) {
          minIdx = i;
        }
      }

      // En büyük alacaklıyı bul (en pozitif bakiye)
      let maxIdx = 0;
      for (let i = 1; i < working.length; i++) {
        if (working[i].netBalance > working[maxIdx].netBalance) {
          maxIdx = i;
        }
      }

      // Artık borç kalmadıysa dur
      if (
        Math.abs(working[minIdx].netBalance) < 0.01 &&
        Math.abs(working[maxIdx].netBalance) < 0.01
      ) {
        break;
      }

      // Transfer miktarı = min(|borç|, alacak)
      const debtor = working[minIdx];
      const creditor = working[maxIdx];
      const transferAmount =
        Math.round(
          Math.min(Math.abs(debtor.netBalance), creditor.netBalance) * 100,
        ) / 100;

      if (transferAmount < 0.01) break;

      // Transfer oluştur
      transactions.push({
        fromUserId: debtor.userId,
        fromUserName: debtor.userName,
        toUserId: creditor.userId,
        toUserName: creditor.userName,
        amount: transferAmount,
      });

      // Bakiyeleri güncelle
      debtor.netBalance += transferAmount;
      creditor.netBalance -= transferAmount;

      // Sıfırlanan kişileri çıkar
      for (let i = working.length - 1; i >= 0; i--) {
        if (Math.abs(working[i].netBalance) < 0.01) {
          working.splice(i, 1);
        }
      }
    }

    return transactions;
  }

  /**
   * Orijinal borç sayısını hesaplar (sadeleştirme öncesi karşılaştırma için).
   * Her harcamadaki bölüşüm ayrı bir borç ilişkisi olarak sayılır.
   */
  private countOriginalDebts(expenses: any[]): number {
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
}
