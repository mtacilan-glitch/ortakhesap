import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/data/mock_data.dart';
import '../../core/models/models.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  String _searchQuery = '';
  ExpenseCategory? _selectedCategory;
  final _currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

  @override
  Widget build(BuildContext context) {
    final filteredExpenses = MockData.expenses.where((expense) {
      final matchesSearch = expense.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          expense.payer.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == null || expense.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 900;

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
                        'Harcamalar',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1D2E),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tüm gruplardaki harcama geçmişiniz',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/add-expense'),
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
                      'Harcama Ekle',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Filters Row
              Row(
                children: [
                  // Search Bar
                  Expanded(
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEEEEF5)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded, color: AppColors.textTertiary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              onChanged: (val) => setState(() => _searchQuery = val),
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                color: Color(0xFF1A1D2E),
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Açıklama veya ödeyen kişi ara...',
                                hintStyle: TextStyle(
                                  fontFamily: 'Inter',
                                  color: AppColors.textTertiary,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Category Filter Dropdown
                  Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEEEEF5)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<ExpenseCategory?>(
                        value: _selectedCategory,
                        hint: const Text(
                          'Kategori Seç',
                          style: TextStyle(fontFamily: 'Inter', color: AppColors.textTertiary, fontSize: 14),
                        ),
                        items: [
                          const DropdownMenuItem<ExpenseCategory?>(
                            value: null,
                            child: Text('Tüm Kategoriler', style: TextStyle(fontFamily: 'Inter', fontSize: 14)),
                          ),
                          ...ExpenseCategory.values.map(
                            (cat) => DropdownMenuItem<ExpenseCategory?>(
                              value: cat,
                              child: Text('${cat.emoji} ${cat.label}', style: const TextStyle(fontFamily: 'Inter', fontSize: 14)),
                            ),
                          ),
                        ],
                        onChanged: (cat) => setState(() => _selectedCategory = cat),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Expenses List
              Expanded(
                child: filteredExpenses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.05),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.receipt_long_rounded,
                                color: AppColors.primary,
                                size: 36,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Harcama Bulunamadı',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1D2E),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Arama kriterlerinizi değiştirmeyi deneyin.',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: filteredExpenses.length,
                        itemBuilder: (context, index) {
                          final expense = filteredExpenses[index];
                          return _buildExpenseCard(expense);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseCard(ExpenseModel expense) {
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
      child: Row(
        children: [
          // Emoji
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: getCategoryColor(expense.category).withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              expense.category.emoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(width: 16),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.description,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1D2E),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Ödeyen: ',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: AppColors.textTertiary.withOpacity(0.8),
                      ),
                    ),
                    Text(
                      expense.payer.name,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 4,
                      width: 4,
                      decoration: const BoxDecoration(
                        color: AppColors.textTertiary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('dd.MM.yyyy').format(expense.date),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _currencyFormat.format(expense.amount),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1D2E),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${expense.splits.length} kişi paylaştı',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
