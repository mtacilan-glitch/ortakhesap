import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/data/mock_data.dart';
import '../../core/models/models.dart';
import '../../core/providers/groups_provider.dart';
import 'widgets/add_member_sheet.dart';

/// Grup Detay ve Borç Analizi Ekranı
/// - Grubun toplam harcama özeti
/// - Alacaklılar / Borçlular listesi
/// - "Hesapla" butonu ile akıllı analiz
/// - Hatırlatma gönder fonksiyonu
class GroupDetailScreen extends ConsumerStatefulWidget {
  final String groupId;

  const GroupDetailScreen({super.key, required this.groupId});

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showSimplified = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupsAsync = ref.watch(groupsProvider);
    final groups = groupsAsync.value ?? [];
    final group = groups.firstWhere(
      (g) => g.id == widget.groupId,
      orElse: () => groups[0],
    );
    final expenses = MockData.expenses.where((e) => e.groupId == widget.groupId).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── Gradient AppBar ─────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_rounded, color: Colors.white),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.cardGradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Text(group.iconEmoji, style: const TextStyle(fontSize: 40)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    group.name,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${group.members.length} üye • ${group.description ?? ""}',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Toplam harcama
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Toplam Harcama',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '₺${group.totalExpenses.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ─── Tab Bar ─────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.all(3),
                dividerColor: Colors.transparent,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textTertiary,
                labelStyle: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                tabs: const [
                  Tab(text: 'Harcamalar'),
                  Tab(text: 'Bakiyeler'),
                  Tab(text: 'Üyeler'),
                ],
              ),
            ),
          ),

          // ─── Tab İçerikleri ──────────────────────
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Harcamalar
                _ExpensesTab(expenses: expenses),
                // Tab 2: Bakiyeler ve Borç Analizi
                _BalancesTab(
                  showSimplified: _showSimplified,
                  onCalculate: () => setState(() => _showSimplified = true),
                ),
                // Tab 3: Üyeler
                _MembersTab(groupId: group.id, members: group.members),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  HARCAMALAR TAB
// ═══════════════════════════════════════════════════════════

class _ExpensesTab extends StatelessWidget {
  final List<ExpenseModel> expenses;

  const _ExpensesTab({required this.expenses});

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_rounded, size: 64, color: AppColors.textTertiary.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text(
              'Henüz harcama yok',
              style: TextStyle(fontFamily: 'Inter', fontSize: 16, color: AppColors.textTertiary),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: expenses.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(child: Text(expense.category.emoji, style: const TextStyle(fontSize: 22))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.description,
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${expense.payer.name} ödedi',
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
              Text(
                '₺${expense.amount.toStringAsFixed(0)}',
                style: const TextStyle(fontFamily: 'Inter', fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  BAKİYELER TAB — Borç Analizi
// ═══════════════════════════════════════════════════════════

class _BalancesTab extends StatelessWidget {
  final bool showSimplified;
  final VoidCallback onCalculate;

  const _BalancesTab({required this.showSimplified, required this.onCalculate});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Alacaklılar
        const Text(
          'Alacaklılar',
          style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.credit),
        ),
        const SizedBox(height: 12),
        ...MockData.balances.where((b) => b.isCreditor).map(
          (b) => _BalanceRow(balance: b),
        ),
        const SizedBox(height: 24),

        // Borçlular
        const Text(
          'Borçlular',
          style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.debit),
        ),
        const SizedBox(height: 12),
        ...MockData.balances.where((b) => b.isDebtor).map(
          (b) => _BalanceRow(balance: b),
        ),
        const SizedBox(height: 28),

        // Hesapla butonu
        if (!showSimplified) ...[
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: onCalculate,
                child: const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_fix_high_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'Akıllı Hesapla',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],

        // Sadeleştirilmiş borçlar
        if (showSimplified) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.auto_fix_high_rounded, color: AppColors.primary, size: 18),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Akıllı Borç Sadeleştirme',
                            style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          ),
                          Text(
                            'En az işlem ile herkes eşitleniyor',
                            style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.textTertiary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...MockData.simplifiedDebts.map(
                  (debt) => _DebtTransactionRow(debt: debt),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _BalanceRow extends StatelessWidget {
  final UserBalanceModel balance;

  const _BalanceRow({required this.balance});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: balance.isCreditor
                  ? AppColors.credit.withOpacity(0.1)
                  : AppColors.debit.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                balance.userName[0],
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: balance.isCreditor ? AppColors.credit : AppColors.debit,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              balance.userName,
              style: const TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
            ),
          ),
          Text(
            '${balance.isCreditor ? '+' : '-'}₺${balance.netBalance.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: balance.isCreditor ? AppColors.credit : AppColors.debit,
            ),
          ),
        ],
      ),
    );
  }
}

class _DebtTransactionRow extends StatelessWidget {
  final DebtTransactionModel debt;

  const _DebtTransactionRow({required this.debt});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Gönderen
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.debit.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                debt.fromUserName[0],
                style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.debit),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              debt.fromUserName.split(' ')[0],
              style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Ok ikonu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                const Icon(Icons.arrow_forward_rounded, color: AppColors.primary, size: 16),
                Text(
                  '₺${debt.amount.toStringAsFixed(0)}',
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              debt.toUserName.split(' ')[0],
              style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          // Alacaklı
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.credit.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                debt.toUserName[0],
                style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.credit),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Hatırlat butonu
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${debt.fromUserName}\'a hatırlatma gönderildi!'),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.notifications_active_rounded, color: Color(0xFFE6A800), size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  ÜYELER TAB
// ═══════════════════════════════════════════════════════════

class _MembersTab extends StatelessWidget {
  final String groupId;
  final List<UserModel> members;

  const _MembersTab({required this.groupId, required this.members});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: members.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.15)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary),
              ),
              title: const Text(
                'Arkadaş Ekle / Davet Et',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              subtitle: const Text(
                'Gruba yeni bir kişi ekleyin',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  useRootNavigator: true,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => AddMemberSheet(
                    groupId: groupId,
                    currentMembers: members,
                  ),
                );
              },
            ),
          );
        }

        final member = members[index - 1];
        final isCurrentUser = member.id == MockData.currentUser.id;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isCurrentUser ? AppColors.primary.withOpacity(0.05) : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: isCurrentUser ? Border.all(color: AppColors.primary.withOpacity(0.2)) : null,
            boxShadow: [
              BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    member.name[0],
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          member.name,
                          style: const TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                        if (isCurrentUser) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('Sen', style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      member.email,
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
