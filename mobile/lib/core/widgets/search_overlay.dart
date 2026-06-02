import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';

/// Global Arama Modalı
class SearchOverlay extends StatefulWidget {
  const SearchOverlay({super.key});

  static Future<void> show(BuildContext context) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Arama Kapat',
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return const SearchOverlay();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1.0).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends State<SearchOverlay> {
  final _searchController = TextEditingController();
  String _query = '';
  String _selectedFilter = 'Tümü'; // 'Tümü', 'Gruplar', 'Harcamalar', 'Kullanıcılar'

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width >= 900;

    // Search logic
    final queryLower = _query.toLowerCase();
    
    // Groups
    final matchedGroups = MockData.groups.where((g) {
      return g.name.toLowerCase().contains(queryLower) ||
          (g.description?.toLowerCase().contains(queryLower) ?? false);
    }).toList();

    // Expenses
    final matchedExpenses = MockData.expenses.where((e) {
      return e.description.toLowerCase().contains(queryLower) ||
          e.payer.name.toLowerCase().contains(queryLower);
    }).toList();

    // Users
    final matchedUsers = MockData.users.where((u) {
      return u.name.toLowerCase().contains(queryLower) ||
          u.email.toLowerCase().contains(queryLower);
    }).toList();

    final hasResults = _query.isNotEmpty &&
        (matchedGroups.isNotEmpty || matchedExpenses.isNotEmpty || matchedUsers.isNotEmpty);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Prevent click propagation
            child: Container(
              width: isDesktop ? 650 : screenSize.width * 0.92,
              height: screenSize.height * 0.75,
              constraints: const BoxConstraints(maxHeight: 600),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // ─── Arama Giriş Barı ───────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F5F8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          const Icon(Icons.search_rounded, color: AppColors.textTertiary, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              autofocus: true,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Grup, harcama veya kişi arayın...',
                                hintStyle: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 15,
                                  color: AppColors.textTertiary,
                                  fontWeight: FontWeight.w400,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                          if (_query.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.close_rounded, color: AppColors.textTertiary),
                              onPressed: () => _searchController.clear(),
                            ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ),

                  // ─── Filtre Seçenekleri ─────────────────
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: ['Tümü', 'Gruplar', 'Harcamalar', 'Kullanıcılar'].map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(
                              filter,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? Colors.white : AppColors.textSecondary,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: AppColors.primary,
                            backgroundColor: const Color(0xFFF4F5F8),
                            onSelected: (val) {
                              if (val) {
                                setState(() => _selectedFilter = filter);
                              }
                            },
                            checkmarkColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide.none,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFEEEEF6)),

                  // ─── Sonuç Listesi ──────────────────────
                  Expanded(
                    child: _query.isEmpty
                        ? _buildRecentSearches()
                        : !hasResults
                            ? _buildEmptyState()
                            : ListView(
                                padding: const EdgeInsets.all(20),
                                children: [
                                  if ((_selectedFilter == 'Tümü' || _selectedFilter == 'Gruplar') &&
                                      matchedGroups.isNotEmpty) ...[
                                    _buildSectionTitle('Gruplar'),
                                    const SizedBox(height: 8),
                                    ...matchedGroups.map((g) => _buildGroupTile(context, g)),
                                    const SizedBox(height: 16),
                                  ],
                                  if ((_selectedFilter == 'Tümü' || _selectedFilter == 'Harcamalar') &&
                                      matchedExpenses.isNotEmpty) ...[
                                    _buildSectionTitle('Harcamalar'),
                                    const SizedBox(height: 8),
                                    ...matchedExpenses.map((e) => _buildExpenseTile(context, e)),
                                    const SizedBox(height: 16),
                                  ],
                                  if ((_selectedFilter == 'Tümü' || _selectedFilter == 'Kullanıcılar') &&
                                      matchedUsers.isNotEmpty) ...[
                                    _buildSectionTitle('Kişiler'),
                                    const SizedBox(height: 8),
                                    ...matchedUsers.map((u) => _buildUserTile(context, u)),
                                  ],
                                ],
                              ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: AppColors.textTertiary,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildGroupTile(BuildContext context, GroupModel group) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            group.iconEmoji ?? '👥',
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
      title: Text(
        group.name,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        group.description ?? '${group.members.length} Üye',
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          color: AppColors.textTertiary,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textTertiary),
      onTap: () {
        Navigator.of(context).pop();
        context.push('/groups/${group.id}');
      },
    );
  }

  Widget _buildExpenseTile(BuildContext context, ExpenseModel expense) {
    final groupName = MockData.groups.firstWhere((g) => g.id == expense.groupId).name;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.debit.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(Icons.receipt_long_rounded, color: AppColors.debit, size: 20),
        ),
      ),
      title: Text(
        expense.description,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        '$groupName • ${expense.payer.name}',
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          color: AppColors.textTertiary,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        '₺${expense.amount.toStringAsFixed(2)}',
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: AppColors.debit,
        ),
      ),
      onTap: () {
        Navigator.of(context).pop();
        context.push('/groups/${expense.groupId}');
      },
    );
  }

  Widget _buildUserTile(BuildContext context, UserModel user) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: AppColors.primary.withOpacity(0.1),
        child: Text(
          user.name.substring(0, 1).toUpperCase(),
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
      title: Text(
        user.name,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        user.email,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          color: AppColors.textTertiary,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textTertiary),
      onTap: () {
        Navigator.of(context).pop();
        context.push('/profile');
      },
    );
  }

  Widget _buildRecentSearches() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_rounded, size: 48, color: AppColors.textTertiary.withOpacity(0.5)),
          const SizedBox(height: 12),
          const Text(
            'Hızlı Arama Yapın',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Harcananlar, gruplar ve arkadaşlar burada.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 48, color: AppColors.textTertiary.withOpacity(0.5)),
          const SizedBox(height: 12),
          const Text(
            'Sonuç Bulunamadı',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '"$_query" ile eşleşen bir kayıt bulunmuyor.',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
