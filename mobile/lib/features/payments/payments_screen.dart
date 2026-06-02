import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/data/mock_data.dart';
import '../../core/models/models.dart';

/// Ödemeler Listesi Ekranı
/// Bekleyen ve tamamlanmış ödemelerin listesi.
class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
              child: Text(
                'Ödemeler',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),

            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
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
                    BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: const Offset(0, 2)),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.all(3),
                dividerColor: Colors.transparent,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textTertiary,
                labelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(text: 'Bekleyen'),
                  Tab(text: 'Tamamlanan'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _PaymentsList(
                    payments: MockData.upcomingPayments,
                    emptyMessage: 'Bekleyen ödeme yok 🎉',
                  ),
                  _PaymentsList(
                    payments: [], // Mock olarak boş
                    emptyMessage: 'Henüz tamamlanan ödeme yok',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentsList extends StatelessWidget {
  final List<PaymentModel> payments;
  final String emptyMessage;

  const _PaymentsList({required this.payments, required this.emptyMessage});

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 64, color: AppColors.textTertiary.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: const TextStyle(fontFamily: 'Inter', fontSize: 16, color: AppColors.textTertiary),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: payments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final payment = payments[index];
        final isOutgoing = payment.fromUser.id == MockData.currentUser.id;

        return GestureDetector(
          onTap: () => context.push('/payment/${payment.id}'),
          child: Container(
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
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: isOutgoing
                        ? const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)])
                        : const LinearGradient(colors: [Color(0xFF30D158), Color(0xFF4AE39D)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Icon(
                      isOutgoing ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isOutgoing ? payment.toUser.name : payment.fromUser.name,
                        style: const TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Bekliyor',
                              style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFE6A800)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            payment.groupName,
                            style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.textTertiary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  '${isOutgoing ? '-' : '+'}₺${payment.amount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isOutgoing ? AppColors.debit : AppColors.credit,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
