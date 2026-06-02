import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/data/mock_data.dart';
import '../../core/models/models.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/widgets/search_overlay.dart';
import '../../core/widgets/notification_sheet.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _touchedIndex = -1;
  final _currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 900;
    final currentUser = ref.watch(currentUserProvider);

    final double totalSpent = MockData.categoryExpenses.values.fold(0, (sum, val) => sum + val);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FD),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 32 : 16,
            vertical: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mobile Header
              if (!isWide) ...[
                _buildMobileHeader(currentUser),
                const SizedBox(height: 24),
              ],

              // ─── Phase 1: 4 Summary Cards ──────────────────
              _buildSummaryCards(isWide),
              const SizedBox(height: 24),

              // ─── Phase 2: Middle Row (Chart + AI) ───────────
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildDonutChartCard(totalSpent),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 2,
                      child: _buildAiRecommendationsCard(),
                    ),
                  ],
                )
              else ...[
                _buildDonutChartCard(totalSpent),
                const SizedBox(height: 24),
                _buildAiRecommendationsCard(),
              ],
              const SizedBox(height: 24),

              // ─── Phase 3: Bottom Row (Payments, Expenses, OCR)
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildUpcomingPaymentsCard(),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildRecentExpensesCard(),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildOcrAndPremiumCard(currentUser),
                    ),
                  ],
                )
              else ...[
                _buildUpcomingPaymentsCard(),
                const SizedBox(height: 24),
                _buildRecentExpensesCard(),
                const SizedBox(height: 24),
                _buildOcrAndPremiumCard(currentUser),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ─── MOBILE HEADER ────────────────────────────────────────────────────────
  Widget _buildMobileHeader(UserModel? user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Merhaba, ${user?.name.split(' ').first ?? 'Mehmet'} 👋',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Ortak Hesap',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1D2E),
              ),
            ),
          ],
        ),
        // Arama & Bildirim Butonları
        Row(
          children: [
            GestureDetector(
              onTap: () => SearchOverlay.show(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF1A1D2E),
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => NotificationSheet.show(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    const Icon(
                      Icons.notifications_rounded,
                      color: Color(0xFF1A1D2E),
                      size: 24,
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.danger,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── 4 SUMMARY CARDS ──────────────────────────────────────────────────────
  Widget _buildSummaryCards(bool isWide) {
    final netBalance = MockData.totalNetBalance;
    final totalSpent = MockData.categoryExpenses.values.fold(0.0, (sum, val) => sum + val);

    final cards = [
      _SummaryCardData(
        title: 'Toplam Bakiye',
        amount: netBalance,
        subtitle: 'Bu ay net durumun',
        icon: Icons.account_balance_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        isPrimary: true,
      ),
      _SummaryCardData(
        title: 'Sana Borçlu',
        amount: MockData.totalCredit,
        subtitle: '3 kişiden alacaklısın',
        icon: Icons.arrow_downward_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        isPrimary: false,
      ),
      _SummaryCardData(
        title: 'Sen Borçlusun',
        amount: MockData.totalDebt,
        subtitle: '2 kişiye borcun var',
        icon: Icons.arrow_upward_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        isPrimary: false,
      ),
      _SummaryCardData(
        title: 'Bu Ay Harcama',
        amount: totalSpent,
        subtitle: 'Geçen aya göre %18 ↑',
        icon: Icons.shopping_bag_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        isPrimary: false,
      ),
    ];

    if (isWide) {
      return Row(
        children: cards.map((card) => Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _buildSingleSummaryCard(card),
          ),
        )).toList(),
      );
    } else {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.45,
        ),
        itemCount: cards.length,
        itemBuilder: (context, index) {
          return _buildSingleSummaryCard(cards[index]);
        },
      );
    }
  }

  Widget _buildSingleSummaryCard(_SummaryCardData data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: data.gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: data.gradient.colors.first.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                data.title,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
              Icon(data.icon, color: Colors.white, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _currencyFormat.format(data.amount.abs()),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data.subtitle,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: Colors.white.withOpacity(0.75),
            ),
          ),
        ],
      ),
    );
  }

  // ─── MIDDLE ROW: DONUT CHART ──────────────────────────────────────────────
  Widget _buildDonutChartCard(double totalSpent) {
    Color getCategoryColor(ExpenseCategory category) {
      switch (category) {
        case ExpenseCategory.market:
          return AppColors.categoryMarket;
        case ExpenseCategory.ulasim:
          return AppColors.categoryUlasim;
        case ExpenseCategory.yemek:
          return AppColors.categoryYemek;
        case ExpenseCategory.eglence:
          return AppColors.categoryEglence;
        case ExpenseCategory.fatura:
          return AppColors.categoryFatura;
        case ExpenseCategory.saglik:
          return AppColors.categorySaglik;
        case ExpenseCategory.diger:
          return AppColors.categoryDiger;
      }
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Harcama Dağılımı',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1D2E),
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/statistics'),
                child: const Text(
                  'Detaylar',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 180,
                  child: Stack(
                    children: [
                      PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback: (FlTouchEvent event, pieTouchResponse) {
                              setState(() {
                                if (!event.isInterestedForInteractions ||
                                    pieTouchResponse == null ||
                                    pieTouchResponse.touchedSection == null) {
                                  _touchedIndex = -1;
                                  return;
                                }
                                _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                              });
                            },
                          ),
                          borderData: FlBorderData(show: false),
                          sectionsSpace: 3,
                          centerSpaceRadius: 55,
                          sections: MockData.categoryExpenses.entries.map((entry) {
                            final category = entry.key;
                            final amount = entry.value;
                            final index = MockData.categoryExpenses.keys.toList().indexOf(category);
                            final isTouched = index == _touchedIndex;
                            final radius = isTouched ? 22.0 : 16.0;

                            return PieChartSectionData(
                              color: getCategoryColor(category),
                              value: amount,
                              title: '',
                              radius: radius,
                            );
                          }).toList(),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Toplam',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                color: AppColors.textTertiary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _currencyFormat.format(totalSpent),
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1D2E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: MockData.categoryExpenses.entries.take(4).map((entry) {
                    final category = entry.key;
                    final amount = entry.value;
                    final pct = (amount / totalSpent) * 100;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            height: 10,
                            width: 10,
                            decoration: BoxDecoration(
                              color: getCategoryColor(category),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              category.label,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '%${pct.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1D2E),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── MIDDLE ROW: AI RECOMMENDATIONS ────────────────────────────────────────
  Widget _buildAiRecommendationsCard() {
    final suggestions = [
      _AiSuggestion(
        text: 'Market harcamalarınız geçen aya göre %12 arttı, ortak alışveriş listesi yapmayı deneyebilirsiniz.',
        icon: Icons.shopping_cart_rounded,
        color: const Color(0xFF6366F1),
      ),
      _AiSuggestion(
        text: 'Netflix faturası yarın çekilecek. Can Öztürk\'e hatırlatma göndermek ister misiniz?',
        icon: Icons.notifications_active_rounded,
        color: const Color(0xFFEF4444),
      ),
      _AiSuggestion(
        text: 'Bu ayki tasarruf hedefinize %61 yaklaştınız! Böyle devam edin. 🚀',
        icon: Icons.trending_up_rounded,
        color: const Color(0xFF10B981),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.psychology_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'AI Finansal Öneriler',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1D2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            children: suggestions.map((sug) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    height: 22,
                    width: 22,
                    decoration: BoxDecoration(
                      color: sug.color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(sug.icon, size: 13, color: sug.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      sug.text,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  // ─── BOTTOM ROW: UPCOMING PAYMENTS ─────────────────────────────────────────
  Widget _buildUpcomingPaymentsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Yaklaşan Ödemeler',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1D2E),
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/payments'),
                child: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textTertiary, size: 14),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (MockData.upcomingPayments.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('Yaklaşan ödeme yok.', style: TextStyle(fontFamily: 'Inter', color: AppColors.textTertiary)),
              ),
            )
          else
            Column(
              children: MockData.upcomingPayments.map((payment) {
                final isOutgoing = payment.fromUser.id == MockData.currentUser.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        height: 38,
                        width: 38,
                        decoration: BoxDecoration(
                          color: isOutgoing ? const Color(0xFFFFECEC) : const Color(0xFFE2F9EE),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          isOutgoing ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                          color: isOutgoing ? AppColors.danger : const Color(0xFF34C759),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isOutgoing ? payment.toUser.name : payment.fromUser.name,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1D2E),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              payment.groupName,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _currencyFormat.format(payment.amount),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: isOutgoing ? AppColors.danger : const Color(0xFF34C759),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // ─── BOTTOM ROW: RECENT EXPENSES ───────────────────────────────────────────
  Widget _buildRecentExpensesCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Son Harcamalar',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1D2E),
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/expenses'),
                child: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textTertiary, size: 14),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            children: MockData.expenses.take(3).map((expense) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      height: 38,
                      width: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        expense.category.emoji,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            expense.description,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1D2E),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            expense.payer.name,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _currencyFormat.format(expense.amount),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1D2E),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ─── BOTTOM ROW: OCR AND PREMIUM BANNER ─────────────────────────────────────
  Widget _buildOcrAndPremiumCard(UserModel? user) {
    final isPremium = user?.isPremium == true;

    return Column(
      children: [
        // AI Fiş Okuyucu Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.document_scanner_rounded, color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'AI Fiş Okuyucu',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1D2E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Fişinizin fotoğrafını yükleyin, harcamayı yapay zeka ile otomatik analiz edelim ve bölelim.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppColors.textTertiary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  if (isPremium) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Kamera izni gerekiyor (Mock)')),
                    );
                  } else {
                    context.push('/premium');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.camera_alt_rounded, size: 16),
                label: Text(
                  isPremium ? 'Fiş Fotoğrafı Çek' : 'Premium\'a Geç ve Tara',
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Premium Banner
        if (!isPremium)
          GestureDetector(
            onTap: () => context.push('/premium'),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFB800), Color(0xFFFF9500)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFB800).withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'SINIRSIZ HİZMET',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Ortak Premium',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Yapay zeka asistanı, sınırsız grup ve reklam kapatma.',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.85),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _SummaryCardData {
  final String title;
  final double amount;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final bool isPrimary;

  _SummaryCardData({
    required this.title,
    required this.amount,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.isPrimary,
  });
}

class _AiSuggestion {
  final String text;
  final IconData icon;
  final Color color;

  _AiSuggestion({
    required this.text,
    required this.icon,
    required this.color,
  });
}
