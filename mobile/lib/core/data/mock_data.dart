import '../models/models.dart';

/// Mock veri sınıfı - UI geliştirme sırasında kullanılacak sahte veriler.
/// Backend entegrasyonundan önce tüm ekranların çalışmasını sağlar.
class MockData {
  MockData._();

  // ─── Kullanıcılar ───────────────────────────────

  static const currentUser = UserModel(
    id: 'u1',
    name: 'Mehmet Yılmaz',
    email: 'mehmet@email.com',
    ibanNumber: 'TR33 0006 1005 1978 6457 8413 26',
    isPremium: false,
    bankIbans: [
      BankIbanModel(
        id: 'bi1',
        bankName: 'Ziraat Bankası',
        iban: 'TR33 0001 0001 2345 6789 0123 45',
        accountHolderName: 'Mehmet Yılmaz',
        bankKey: 'ziraat',
      ),
      BankIbanModel(
        id: 'bi2',
        bankName: 'Kuveyt Türk',
        iban: 'TR55 0020 5000 1111 2222 3333 44',
        accountHolderName: 'Mehmet Yılmaz',
        bankKey: 'kuveytturk',
      ),
      BankIbanModel(
        id: 'bi3',
        bankName: 'Akbank',
        iban: 'TR44 0004 6000 7777 8888 9999 00',
        accountHolderName: 'Mehmet Yılmaz (Akbank)',
        bankKey: 'akbank',
      ),
    ],
  );

  static const users = [
    currentUser,
    UserModel(
      id: 'u2',
      name: 'Ayşe Demir',
      email: 'ayse@email.com',
      ibanNumber: 'TR76 0001 2009 4520 0016 0023 01',
      bankIbans: [
        BankIbanModel(
          id: 'bi4',
          bankName: 'Türkiye İş Bankası',
          iban: 'TR77 0006 2000 8888 9999 0000 11',
          accountHolderName: 'Ayşe Demir',
          bankKey: 'isbank',
        ),
        BankIbanModel(
          id: 'bi5',
          bankName: 'Garanti BBVA',
          iban: 'TR56 0006 2000 1234 5678 9012 34',
          accountHolderName: 'Ayşe Demir',
          bankKey: 'garanti',
        ),
      ],
    ),
    UserModel(
      id: 'u3',
      name: 'Can Öztürk',
      email: 'can@email.com',
      ibanNumber: 'TR12 0006 2000 0140 0006 5478 57',
      bankIbans: [
        BankIbanModel(
          id: 'bi6',
          bankName: 'Yapı Kredi',
          iban: 'TR66 0009 3000 4444 5555 6666 77',
          accountHolderName: 'Can Öztürk',
          bankKey: 'yapikredi',
        ),
        BankIbanModel(
          id: 'bi7',
          bankName: 'Papara',
          iban: 'TR99 0009 9000 1212 3434 5656 78',
          accountHolderName: 'Can Öztürk',
          bankKey: 'papara',
        ),
      ],
    ),
    UserModel(
      id: 'u4',
      name: 'Elif Kaya',
      email: 'elif@email.com',
      ibanNumber: 'TR98 0006 2000 0140 0006 8901 23',
    ),
    UserModel(
      id: 'u5',
      name: 'Burak Şahin',
      email: 'burak@email.com',
      ibanNumber: 'TR45 0001 0017 4500 0100 3456 78',
    ),
  ];

  // ─── Gruplar ────────────────────────────────────

  static final groups = [
    GroupModel(
      id: 'g1',
      name: 'Ev Grubu',
      description: 'Ev arkadaşlarıyla ortak giderler',
      iconEmoji: '🏠',
      members: [users[0], users[1], users[2]],
      totalExpenses: 4250.00,
      netBalance: 350.00, // Alacaklı
    ),
    GroupModel(
      id: 'g2',
      name: 'Arkadaşlar',
      description: 'Arkadaş buluşmaları',
      iconEmoji: '👫',
      members: [users[0], users[1], users[3], users[4]],
      totalExpenses: 2800.50,
      netBalance: -175.25, // Borçlu
    ),
    GroupModel(
      id: 'g3',
      name: 'Antalya Tatili',
      description: 'Yaz tatili harcamaları',
      iconEmoji: '🏖️',
      members: users,
      totalExpenses: 8750.00,
      netBalance: 520.00,
    ),
    GroupModel(
      id: 'g4',
      name: 'Ofis Yemekleri',
      description: 'İş yeri yemek paylaşımları',
      iconEmoji: '🍽️',
      members: [users[0], users[2], users[4]],
      totalExpenses: 1450.75,
      netBalance: -85.50,
    ),
  ];

  // ─── Harcamalar ─────────────────────────────────

  static final expenses = [
    ExpenseModel(
      id: 'e1',
      groupId: 'g1',
      description: 'Haftalık market alışverişi',
      amount: 850.00,
      category: ExpenseCategory.market,
      payer: users[0],
      date: DateTime.now().subtract(const Duration(hours: 3)),
      splits: [
        ExpenseSplitModel(userId: 'u1', userName: 'Mehmet Yılmaz', amount: 283.33),
        ExpenseSplitModel(userId: 'u2', userName: 'Ayşe Demir', amount: 283.33),
        ExpenseSplitModel(userId: 'u3', userName: 'Can Öztürk', amount: 283.34),
      ],
    ),
    ExpenseModel(
      id: 'e2',
      groupId: 'g1',
      description: 'Elektrik faturası - Haziran',
      amount: 420.00,
      category: ExpenseCategory.fatura,
      payer: users[1],
      date: DateTime.now().subtract(const Duration(days: 2)),
      splits: [
        ExpenseSplitModel(userId: 'u1', userName: 'Mehmet Yılmaz', amount: 140.00),
        ExpenseSplitModel(userId: 'u2', userName: 'Ayşe Demir', amount: 140.00),
        ExpenseSplitModel(userId: 'u3', userName: 'Can Öztürk', amount: 140.00),
      ],
    ),
    ExpenseModel(
      id: 'e3',
      groupId: 'g2',
      description: 'Akşam yemeği - Nusret',
      amount: 1200.00,
      category: ExpenseCategory.yemek,
      payer: users[3],
      date: DateTime.now().subtract(const Duration(days: 5)),
      splits: [
        ExpenseSplitModel(userId: 'u1', userName: 'Mehmet Yılmaz', amount: 300.00),
        ExpenseSplitModel(userId: 'u2', userName: 'Ayşe Demir', amount: 300.00),
        ExpenseSplitModel(userId: 'u4', userName: 'Elif Kaya', amount: 300.00),
        ExpenseSplitModel(userId: 'u5', userName: 'Burak Şahin', amount: 300.00),
      ],
    ),
    ExpenseModel(
      id: 'e4',
      groupId: 'g3',
      description: 'Otel konaklama (3 gece)',
      amount: 4500.00,
      category: ExpenseCategory.eglence,
      payer: users[0],
      date: DateTime.now().subtract(const Duration(days: 10)),
      splits: [
        ExpenseSplitModel(userId: 'u1', userName: 'Mehmet Yılmaz', amount: 900.00),
        ExpenseSplitModel(userId: 'u2', userName: 'Ayşe Demir', amount: 900.00),
        ExpenseSplitModel(userId: 'u3', userName: 'Can Öztürk', amount: 900.00),
        ExpenseSplitModel(userId: 'u4', userName: 'Elif Kaya', amount: 900.00),
        ExpenseSplitModel(userId: 'u5', userName: 'Burak Şahin', amount: 900.00),
      ],
    ),
    ExpenseModel(
      id: 'e5',
      groupId: 'g1',
      description: 'İnternet faturası',
      amount: 250.00,
      category: ExpenseCategory.fatura,
      payer: users[2],
      date: DateTime.now().subtract(const Duration(days: 1)),
      splits: [
        ExpenseSplitModel(userId: 'u1', userName: 'Mehmet Yılmaz', amount: 83.33),
        ExpenseSplitModel(userId: 'u2', userName: 'Ayşe Demir', amount: 83.33),
        ExpenseSplitModel(userId: 'u3', userName: 'Can Öztürk', amount: 83.34),
      ],
    ),
  ];

  // ─── Sadeleştirilmiş Borçlar ────────────────────

  static const simplifiedDebts = [
    DebtTransactionModel(
      fromUserId: 'u1',
      fromUserName: 'Mehmet Yılmaz',
      toUserId: 'u2',
      toUserName: 'Ayşe Demir',
      amount: 140.00,
    ),
    DebtTransactionModel(
      fromUserId: 'u3',
      fromUserName: 'Can Öztürk',
      toUserId: 'u1',
      toUserName: 'Mehmet Yılmaz',
      amount: 490.00,
    ),
    DebtTransactionModel(
      fromUserId: 'u3',
      fromUserName: 'Can Öztürk',
      toUserId: 'u2',
      toUserName: 'Ayşe Demir',
      amount: 76.67,
    ),
  ];

  // ─── Bakiyeler ──────────────────────────────────

  static const balances = [
    UserBalanceModel(userId: 'u1', userName: 'Mehmet Yılmaz', netBalance: 350.00),
    UserBalanceModel(userId: 'u2', userName: 'Ayşe Demir', netBalance: 216.67),
    UserBalanceModel(userId: 'u3', userName: 'Can Öztürk', netBalance: -566.67),
  ];

  // ─── Yaklaşan Ödemeler ──────────────────────────

  static final upcomingPayments = [
    PaymentModel(
      id: 'p1',
      fromUser: users[0],
      toUser: users[1],
      groupName: 'Ev Grubu',
      amount: 140.00,
      status: PaymentStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    PaymentModel(
      id: 'p2',
      fromUser: users[2],
      toUser: users[0],
      groupName: 'Ev Grubu',
      amount: 490.00,
      status: PaymentStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  // ─── Bildirimler ────────────────────────────────

  static final notifications = [
    NotificationModel(
      id: 'n1',
      title: 'Yeni Harcama Eklendi',
      body: 'Can Öztürk "İnternet faturası" harcamasını ekledi - ₺250.00',
      type: 'EXPENSE_ADDED',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    NotificationModel(
      id: 'n2',
      title: 'Ödeme Hatırlatması',
      body: 'Ayşe Demir sana ₺140.00 ödeme hatırlatması gönderdi',
      type: 'PAYMENT_REMINDER',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    NotificationModel(
      id: 'n3',
      title: 'Ödeme Alındı',
      body: 'Can Öztürk ₺490.00 ödeme yaptı (Ev Grubu)',
      type: 'PAYMENT_RECEIVED',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    NotificationModel(
      id: 'n4',
      title: 'Yeni Harcama Eklendi',
      body: 'Elif Kaya "Akşam yemeği - Nusret" harcamasını ekledi - ₺1,200.00',
      type: 'EXPENSE_ADDED',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    NotificationModel(
      id: 'n5',
      title: 'Gruba Davet',
      body: 'Burak Şahin seni "Ofis Yemekleri" grubuna davet etti',
      type: 'GROUP_INVITE',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  // ─── İstatistik Verileri ────────────────────────

  static const categoryExpenses = {
    ExpenseCategory.market: 2150.00,
    ExpenseCategory.yemek: 1800.50,
    ExpenseCategory.fatura: 1670.00,
    ExpenseCategory.eglence: 4500.00,
    ExpenseCategory.ulasim: 580.00,
    ExpenseCategory.saglik: 250.00,
    ExpenseCategory.diger: 300.25,
  };

  static const monthlyTotals = [
    3200.0, 2800.0, 4100.0, 3600.0, 5200.0, 4750.0,
  ];

  static const monthLabels = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz'];

  // Net bakiye
  static double get totalNetBalance =>
      groups.fold(0.0, (sum, g) => sum + g.netBalance);

  static double get totalCredit =>
      groups.where((g) => g.netBalance > 0).fold(0.0, (sum, g) => sum + g.netBalance);

  static double get totalDebt =>
      groups.where((g) => g.netBalance < 0).fold(0.0, (sum, g) => sum + g.netBalance.abs());
}
