import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/data/mock_data.dart';
import '../../core/models/models.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _touchedIndex = -1;
  String _selectedPeriod = 'Aylık'; // Haftalık, Aylık, Yıllık

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

  Color _getCategoryColor(ExpenseCategory category) {
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

  double _getCategoryPercentage(double amount, double total) {
    if (total == 0) return 0;
    return (amount / total) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    final totalSpent = MockData.categoryExpenses.values.reduce((value, element) => value + element);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Raporlar & İstatistikler',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textTertiary,
          labelStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(text: 'Harcama Analizi'),
            Tab(text: 'Son Hareketler'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExpenseAnalysisTab(currencyFormat, totalSpent),
          _buildNotificationsTab(currencyFormat),
        ],
      ),
    );
  }

  // ─── HARCAMA ANALİZİ SEKMESİ ───────────────────────────────────────────────
  Widget _buildExpenseAnalysisTab(NumberFormat currencyFormat, double totalSpent) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Periyot Seçici
          _buildPeriodSelector(),
          const SizedBox(height: 20),

          // Toplam Harcama Hero Kartı
          _buildTotalSpendCard(currencyFormat, totalSpent),
          const SizedBox(height: 20),

          // Donut Grafik Kartı
          _buildDonutChartCard(currencyFormat, totalSpent),
          const SizedBox(height: 20),

          // Aylık Trend Grafik Kartı
          _buildTrendChartCard(currencyFormat),
          const SizedBox(height: 20),

          // Kategori Listesi Başlığı
          const Text(
            'Kategori Dağılımı',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Kategori Listesi
          ...MockData.categoryExpenses.entries.map((entry) {
            final category = entry.key;
            final amount = entry.value;
            final percentage = _getCategoryPercentage(amount, totalSpent);
            final color = _getCategoryColor(category);

            return _buildCategoryItem(category, amount, percentage, color, currencyFormat);
          }),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final periods = ['Haftalık', 'Aylık', 'Yıllık'];
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: periods.map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriod = period;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.primaryGradient : null,
                  color: isSelected ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  period,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTotalSpendCard(NumberFormat currencyFormat, double totalSpent) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Toplam Harcamanız',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                currencyFormat.format(totalSpent),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.trending_up_rounded, color: Colors.white, size: 14),
                        SizedBox(width: 2),
                        Text(
                          '%12.4',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'geçen aya göre',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.analytics_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonutChartCard(NumberFormat currencyFormat, double totalSpent) {
    return Container(
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
          const Text(
            'Harcama Dağılımı',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
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
                    sectionsSpace: 4,
                    centerSpaceRadius: 65,
                    sections: _buildPieChartSections(totalSpent),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'En Çok harcanan',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Eğlence',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        currencyFormat.format(MockData.categoryExpenses[ExpenseCategory.eglence]),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(double totalSpent) {
    return MockData.categoryExpenses.entries.map((entry) {
      final category = entry.key;
      final amount = entry.value;
      final index = MockData.categoryExpenses.keys.toList().indexOf(category);
      final isTouched = index == _touchedIndex;
      final radius = isTouched ? 28.0 : 20.0;
      final color = _getCategoryColor(category);

      return PieChartSectionData(
        color: color,
        value: amount,
        title: isTouched ? '${_getCategoryPercentage(amount, totalSpent).toStringAsFixed(1)}%' : '',
        radius: radius,
        titleStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildTrendChartCard(NumberFormat currencyFormat) {
    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Aylık Trend',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Ort. ₺4.033 / ay',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.border.withOpacity(0.6),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < MockData.monthlyTotals.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              MockData.monthLabels[idx],
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                color: AppColors.textTertiary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (MockData.monthlyTotals.length - 1).toDouble(),
                minY: 2000,
                maxY: 6000,
                lineBarsData: [
                  LineChartBarData(
                    spots: MockData.monthlyTotals.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value);
                    }).toList(),
                    isCurved: true,
                    gradient: AppColors.primaryGradient,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 5,
                        color: Colors.white,
                        strokeWidth: 3,
                        strokeColor: AppColors.primary,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withOpacity(0.2),
                          AppColors.primary.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    ExpenseCategory category,
    double amount,
    double percentage,
    Color color,
    NumberFormat currencyFormat,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  category.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.label,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                currencyFormat.format(amount),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: AppColors.border.withOpacity(0.5),
              color: color,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  // ─── BİLDİRİMLER & HAREKETLER SEKMESİ ────────────────────────────────────────
  Widget _buildNotificationsTab(NumberFormat currencyFormat) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 100),
      itemCount: MockData.notifications.length,
      itemBuilder: (context, index) {
        final notification = MockData.notifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    final diff = DateTime.now().difference(notification.createdAt);
    String timeText = '';
    if (diff.inMinutes < 60) {
      timeText = '${diff.inMinutes} dk önce';
    } else if (diff.inHours < 24) {
      timeText = '${diff.inHours} saat önce';
    } else {
      timeText = '${diff.inDays} gün önce';
    }

    IconData icon;
    Color iconColor;
    Color bgColor;

    switch (notification.type) {
      case 'EXPENSE_ADDED':
        icon = Icons.add_shopping_cart_rounded;
        iconColor = AppColors.primary;
        bgColor = AppColors.primary.withOpacity(0.1);
        break;
      case 'PAYMENT_REMINDER':
        icon = Icons.notifications_active_rounded;
        iconColor = AppColors.warning;
        bgColor = AppColors.warning.withOpacity(0.1);
        break;
      case 'PAYMENT_RECEIVED':
        icon = Icons.check_circle_rounded;
        iconColor = AppColors.success;
        bgColor = AppColors.success.withOpacity(0.1);
        break;
      case 'GROUP_INVITE':
        icon = Icons.group_add_rounded;
        iconColor = AppColors.info;
        bgColor = AppColors.info.withOpacity(0.1);
        break;
      default:
        icon = Icons.info_rounded;
        iconColor = AppColors.textSecondary;
        bgColor = AppColors.textSecondary.withOpacity(0.1);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: notification.isRead
            ? null
            : Border.all(color: AppColors.primary.withOpacity(0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(notification.isRead ? 0.02 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),
              ),
              if (!notification.isRead)
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    height: 10,
                    width: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      timeText,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  notification.body,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
