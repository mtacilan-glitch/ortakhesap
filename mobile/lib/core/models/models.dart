/// Ortak Hesap - Veri Modelleri
/// Backend API'deki şemaya karşılık gelen Dart model sınıfları.

// ─── Kategori Enum ──────────────────────────────────────────

enum ExpenseCategory {
  market('Market', '🛒'),
  ulasim('Ulaşım', '🚌'),
  yemek('Yemek', '🍕'),
  eglence('Eğlence', '🎉'),
  fatura('Fatura', '📄'),
  saglik('Sağlık', '💊'),
  diger('Diğer', '📦');

  const ExpenseCategory(this.label, this.emoji);
  final String label;
  final String emoji;
}

enum PaymentStatus { pending, confirmed, rejected }

// ─── Banka IBAN Modeli ────────────────────────────────────────

class BankIbanModel {
  final String id;
  final String bankName;
  final String iban;
  final String accountHolderName;
  final String bankKey; // 'ziraat', 'kuveytturk', 'isbank', 'akbank', 'garanti', 'yapikredi', 'papara', 'diger'

  const BankIbanModel({
    required this.id,
    required this.bankName,
    required this.iban,
    required this.accountHolderName,
    required this.bankKey,
  });

  factory BankIbanModel.fromJson(Map<String, dynamic> json) {
    return BankIbanModel(
      id: json['id']?.toString() ?? '',
      bankName: json['bankName']?.toString() ?? '',
      iban: json['iban']?.toString() ?? '',
      accountHolderName: json['accountHolderName']?.toString() ?? '',
      bankKey: json['bankKey']?.toString() ?? 'diger',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bankName': bankName,
      'iban': iban,
      'accountHolderName': accountHolderName,
      'bankKey': bankKey,
    };
  }
}

// ─── Kullanıcı ──────────────────────────────────────────────

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? ibanNumber;
  final bool isPremium;
  final List<BankIbanModel> bankIbans;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.ibanNumber,
    this.isPremium = false,
    this.bankIbans = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString(),
      ibanNumber: json['ibanNumber']?.toString(),
      isPremium: json['isPremium'] == true,
      bankIbans: (json['bankIbans'] as List<dynamic>?)
              ?.map((e) => BankIbanModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

// ─── Grup ───────────────────────────────────────────────────

class GroupModel {
  final String id;
  final String name;
  final String? description;
  final String iconEmoji;
  final List<UserModel> members;
  final double totalExpenses;
  final double netBalance; // Mevcut kullanıcı için

  const GroupModel({
    required this.id,
    required this.name,
    this.description,
    required this.iconEmoji,
    required this.members,
    this.totalExpenses = 0,
    this.netBalance = 0,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      iconEmoji: json['iconEmoji']?.toString() ?? '🏠',
      members: (json['members'] as List<dynamic>?)
              ?.map((e) => UserModel.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
      totalExpenses: (json['totalExpenses'] as num?)?.toDouble() ?? 0.0,
      netBalance: (json['netBalance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// ─── Harcama ────────────────────────────────────────────────

class ExpenseModel {
  final String id;
  final String groupId;
  final String description;
  final double amount;
  final ExpenseCategory category;
  final UserModel payer;
  final DateTime date;
  final List<ExpenseSplitModel> splits;

  const ExpenseModel({
    required this.id,
    required this.groupId,
    required this.description,
    required this.amount,
    required this.category,
    required this.payer,
    required this.date,
    required this.splits,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id']?.toString() ?? '',
      groupId: json['groupId']?.toString() ?? '',
      description: json['description']?.toString() ?? json['title']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      category: ExpenseCategory.values.firstWhere(
        (c) => c.name == json['category']?.toString(),
        orElse: () => ExpenseCategory.diger,
      ),
      payer: UserModel.fromJson(json['payer'] ?? {}),
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      splits: (json['splits'] as List<dynamic>?)
              ?.map((e) => ExpenseSplitModel.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
    );
  }
}

class ExpenseSplitModel {
  final String userId;
  final String userName;
  final double amount;

  const ExpenseSplitModel({
    required this.userId,
    required this.userName,
    required this.amount,
  });

  factory ExpenseSplitModel.fromJson(Map<String, dynamic> json) {
    return ExpenseSplitModel(
      userId: json['userId']?.toString() ?? '',
      userName: json['userName']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// ─── Borç İşlemi (Sadeleştirilmiş) ─────────────────────────

class DebtTransactionModel {
  final String fromUserId;
  final String fromUserName;
  final String toUserId;
  final String toUserName;
  final double amount;

  const DebtTransactionModel({
    required this.fromUserId,
    required this.fromUserName,
    required this.toUserId,
    required this.toUserName,
    required this.amount,
  });
}

// ─── Ödeme ──────────────────────────────────────────────────

class PaymentModel {
  final String id;
  final UserModel fromUser;
  final UserModel toUser;
  final String groupName;
  final double amount;
  final double paidAmount;
  final PaymentStatus status;
  final DateTime createdAt;

  const PaymentModel({
    required this.id,
    required this.fromUser,
    required this.toUser,
    required this.groupName,
    required this.amount,
    this.paidAmount = 0.0,
    required this.status,
    required this.createdAt,
  });

  /// Kalan borç tutarı
  double get remainingAmount => amount - paidAmount;

  /// Ödeme yüzdesi (0.0 - 1.0)
  double get paymentProgress => amount > 0 ? (paidAmount / amount).clamp(0.0, 1.0) : 0.0;

  /// Tamamlanmış mı?
  bool get isFullyPaid => remainingAmount <= 0.01;

  /// Kısmi ödeme ile güncelleme
  PaymentModel copyWithPayment(double newPayment) {
    final totalPaid = paidAmount + newPayment;
    return PaymentModel(
      id: id,
      fromUser: fromUser,
      toUser: toUser,
      groupName: groupName,
      amount: amount,
      paidAmount: totalPaid.clamp(0.0, amount),
      status: totalPaid >= amount ? PaymentStatus.confirmed : status,
      createdAt: createdAt,
    );
  }
}

// ─── Bildirim ───────────────────────────────────────────────

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.isRead = false,
    required this.createdAt,
  });
}

// ─── Kullanıcı Bakiyesi ─────────────────────────────────────

class UserBalanceModel {
  final String userId;
  final String userName;
  final double netBalance;

  const UserBalanceModel({
    required this.userId,
    required this.userName,
    required this.netBalance,
  });

  bool get isCreditor => netBalance > 0;
  bool get isDebtor => netBalance < 0;
}
