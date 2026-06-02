import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 900;

    final mockSubscriptions = [
      _SubscriptionItem(
        name: 'Netflix Premium',
        emoji: '🎬',
        totalPrice: 199.90,
        memberCount: 4,
        nextBillDate: '15 Haz 2026',
        color: const Color(0xFFE50914),
      ),
      _SubscriptionItem(
        name: 'Spotify Aile',
        emoji: '🎵',
        totalPrice: 99.90,
        memberCount: 6,
        nextBillDate: '20 Haz 2026',
        color: const Color(0xFF1DB954),
      ),
      _SubscriptionItem(
        name: 'YouTube Premium',
        emoji: '📺',
        totalPrice: 79.90,
        memberCount: 5,
        nextBillDate: '28 Haz 2026',
        color: const Color(0xFFFF0000),
      ),
      _SubscriptionItem(
        name: 'MacFit Gym',
        emoji: '💪',
        totalPrice: 799.00,
        memberCount: 2,
        nextBillDate: '01 Tem 2026',
        color: const Color(0xFFFFB800),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FD),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 32 : 16,
            vertical: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ortak Abonelikler',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1D2E),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Düzenli yinelenen faturaları takip edin ve paylaşın',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text(
                      'Abonelik Ekle',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Subscriptions list
              Expanded(
                child: isWide
                    ? GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 2.2,
                        ),
                        itemCount: mockSubscriptions.length,
                        itemBuilder: (context, index) {
                          return _buildSubscriptionCard(mockSubscriptions[index]);
                        },
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: mockSubscriptions.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildSubscriptionCard(mockSubscriptions[index]),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(_SubscriptionItem sub) {
    final personalShare = sub.totalPrice / sub.memberCount;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: sub.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  sub.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sub.name,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1D2E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sonraki Fatura: ${sub.nextBillDate}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${sub.memberCount} Üye',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF2F2F7)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Toplam Fatura',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₺${sub.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Senin Payın',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₺${personalShare.toStringAsFixed(2)}/ay',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SubscriptionItem {
  final String name;
  final String emoji;
  final double totalPrice;
  final int memberCount;
  final String nextBillDate;
  final Color color;

  _SubscriptionItem({
    required this.name,
    required this.emoji,
    required this.totalPrice,
    required this.memberCount,
    required this.nextBillDate,
    required this.color,
  });
}
