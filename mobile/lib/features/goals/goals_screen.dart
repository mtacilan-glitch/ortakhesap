import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 900;

    final mockGoals = [
      _GoalItem(
        title: 'Yaz Tatili (Bodrum)',
        description: 'Ortak tatil bütçesi için biriktirilen tutar',
        emoji: '🏖️',
        currentAmount: 18450.00,
        targetAmount: 30000.00,
        contributors: 4,
      ),
      _GoalItem(
        title: 'Ev İçin Yeni TV',
        description: 'Salon televizyonunu 65" 4K OLED ile yeniliyoruz',
        emoji: '📺',
        currentAmount: 22000.00,
        targetAmount: 22000.00,
        contributors: 3,
      ),
      _GoalItem(
        title: 'Can\'ın Doğum Günü Hediyesi',
        description: 'Akıllı saat hediyesi için ortak bütçe',
        emoji: '🎁',
        currentAmount: 1250.00,
        targetAmount: 4000.00,
        contributors: 5,
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
                        'Ortak Hedefler',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1D2E),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Gruplarınızla beraber biriktirdiğiniz ortak bütçeler',
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
                      'Hedef Oluştur',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Goals list
              Expanded(
                child: isWide
                    ? GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 2.0,
                        ),
                        itemCount: mockGoals.length,
                        itemBuilder: (context, index) {
                          return _buildGoalCard(mockGoals[index]);
                        },
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: mockGoals.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildGoalCard(mockGoals[index]),
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

  Widget _buildGoalCard(_GoalItem goal) {
    final progress = goal.currentAmount / goal.targetAmount;
    final percentage = (progress * 100).toInt();
    final isCompleted = goal.currentAmount >= goal.targetAmount;

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
                  color: isCompleted ? const Color(0xFFE2F9EE) : AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  goal.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1D2E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      goal.description,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2F9EE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Tamamlandı',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF34C759),
                    ),
                  ),
                )
              else
                Text(
                  '%$percentage',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Biriken: ₺${goal.currentAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'Hedef: ₺${goal.targetAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: const Color(0xFFEEEEF5),
                  color: isCompleted ? const Color(0xFF34C759) : AppColors.primary,
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalItem {
  final String title;
  final String description;
  final String emoji;
  final double currentAmount;
  final double targetAmount;
  final int contributors;

  _GoalItem({
    required this.title,
    required this.description,
    required this.emoji,
    required this.currentAmount,
    required this.targetAmount,
    required this.contributors,
  });
}
