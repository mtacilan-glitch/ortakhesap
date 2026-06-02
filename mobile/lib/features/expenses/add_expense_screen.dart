import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/data/mock_data.dart';
import '../../core/models/models.dart';
import '../../core/providers/groups_provider.dart';

/// Harcama Ekleme Ekranı
/// - Tutar girme alanı
/// - Açıklama, Kategori, Ödeyen, Tarih, Grup seçimi
/// - Eşit bölüşüm / Özel bölüşüm toggle
class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  ExpenseCategory _selectedCategory = ExpenseCategory.diger;
  String? _selectedGroupId;
  String _selectedPayerId = MockData.currentUser.id;
  bool _equalSplit = true;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final groupsAsync = ref.read(groupsProvider);
    final groups = groupsAsync.value ?? [];
    if (groups.isNotEmpty) {
      _selectedGroupId = groups[0].id;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Harcama Ekle',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Tutar ────────────────────────────────
            Center(
              child: Column(
                children: [
                  const Text(
                    'Tutar',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text(
                          '₺',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IntrinsicWidth(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -2,
                          ),
                          decoration: const InputDecoration(
                            hintText: '0',
                            hintStyle: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 48,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textTertiary,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            filled: false,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ─── Açıklama ─────────────────────────────
            _SectionLabel(label: 'Açıklama'),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: 'Harcama açıklaması yazın...',
                prefixIcon: const Icon(Icons.edit_rounded, color: AppColors.textTertiary, size: 20),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ─── Kategori ─────────────────────────────
            _SectionLabel(label: 'Kategori'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ExpenseCategory.values.map((category) {
                final isSelected = category == _selectedCategory;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = category),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(category.emoji, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          category.label,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // ─── Grup Seçimi ──────────────────────────
            _SectionLabel(label: 'Grup'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedGroupId,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  prefixIcon: Icon(Icons.group_rounded, color: AppColors.textTertiary, size: 20),
                ),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textTertiary),
                items: (ref.watch(groupsProvider).value ?? []).map((group) {
                  return DropdownMenuItem(
                    value: group.id,
                    child: Text(
                      '${group.iconEmoji} ${group.name}',
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 15),
                    ),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedGroupId = value),
              ),
            ),
            const SizedBox(height: 20),

            // ─── Ödeyen Kişi ──────────────────────────
            _SectionLabel(label: 'Ödeyen Kişi'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedPayerId,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  prefixIcon: Icon(Icons.person_rounded, color: AppColors.textTertiary, size: 20),
                ),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textTertiary),
                items: MockData.users.map((user) {
                  return DropdownMenuItem(
                    value: user.id,
                    child: Text(
                      user.name,
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 15),
                    ),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedPayerId = value!),
              ),
            ),
            const SizedBox(height: 20),

            // ─── Tarih ────────────────────────────────
            _SectionLabel(label: 'Tarih'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2024),
                  lastDate: DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(primary: AppColors.primary),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, color: AppColors.textTertiary, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      '${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}',
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 15, color: AppColors.textPrimary),
                    ),
                    const Spacer(),
                    const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textTertiary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ─── Bölüşüm Toggle ───────────────────────
            _SectionLabel(label: 'Bölüşüm'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _equalSplit = true),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _equalSplit ? AppColors.surface : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: _equalSplit
                              ? [BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: const Offset(0, 2))]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            'Eşit Bölüştür',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _equalSplit ? AppColors.primary : AppColors.textTertiary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _equalSplit = false),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_equalSplit ? AppColors.surface : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: !_equalSplit
                              ? [BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: const Offset(0, 2))]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            'Özel Bölüştür',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: !_equalSplit ? AppColors.primary : AppColors.textTertiary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ─── Kaydet Butonu ────────────────────────
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
                  onTap: () {
                    // Kaydet aksiyonu
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Harcama başarıyla eklendi!'),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                    context.pop();
                  },
                  child: const Center(
                    child: Text(
                      'Harcamayı Kaydet',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }
}
