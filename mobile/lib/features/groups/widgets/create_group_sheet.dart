import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/groups_provider.dart';
import '../../../core/providers/auth_provider.dart';
class CreateGroupSheet extends ConsumerStatefulWidget {
  const CreateGroupSheet({super.key});

  @override
  ConsumerState<CreateGroupSheet> createState() => _CreateGroupSheetState();
}

class _CreateGroupSheetState extends ConsumerState<CreateGroupSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  
  String _selectedEmoji = '🏠';
  final List<String> _emojis = ['🏠', '👫', '🏖️', '🍽️', '✈️', '🎮', '🚗', '🍕', '🏢', '🎓', '💵', '🛒'];
  final List<UserModel> _selectedMembers = [];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _toggleMember(UserModel user) {
    setState(() {
      if (_selectedMembers.any((m) => m.id == user.id)) {
        _selectedMembers.removeWhere((m) => m.id == user.id);
      } else {
        _selectedMembers.add(user);
      }
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    ref.read(groupsProvider.notifier).createGroup(
      name: _nameController.text.trim(),
      description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      iconEmoji: _selectedEmoji,
      members: _selectedMembers,
    );

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${_nameController.text}" grubu başarıyla oluşturuldu!'),
        backgroundColor: AppColors.credit,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final contacts = ref.watch(contactsProvider);
    final currentUser = ref.watch(currentUserProvider);
    // exclude current user from selection list
    final selectableContacts = contacts.where((c) => c.id != currentUser?.id).toList();

    final viewInsets = MediaQuery.of(context).viewInsets;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.textTertiary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Yeni Grup Oluştur',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          const Divider(height: 24, thickness: 1),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Group name input with select emoji prefix
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Emoji Picker trigger / indicator
                        GestureDetector(
                          onTap: () {
                            // FocusScope.of(context).unfocus();
                          },
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                            ),
                            child: Center(
                              child: Text(
                                _selectedEmoji,
                                style: const TextStyle(fontSize: 30),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _nameController,
                            autofocus: true,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Grup Adı',
                              hintText: 'Örn: Ev Giderleri, Yaz Tatili',
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Lütfen bir grup adı girin';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Description input
                    TextFormField(
                      controller: _descController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Açıklama (İsteğe Bağlı)',
                        hintText: 'Grup amacı hakkında kısa bir not...',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Horizontal Emoji selector
                    const Text(
                      'Grup Emojisi',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 52,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _emojis.length,
                        itemBuilder: (context, index) {
                          final emoji = _emojis[index];
                          final isSelected = _selectedEmoji == emoji;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(
                                emoji,
                                style: const TextStyle(fontSize: 20),
                              ),
                              selected: isSelected,
                              selectedColor: AppColors.primary.withOpacity(0.15),
                              backgroundColor: AppColors.surfaceVariant,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isSelected ? AppColors.primary : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              onSelected: (_) {
                                setState(() {
                                  _selectedEmoji = emoji;
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Selected Members summary row (if any)
                    if (_selectedMembers.isNotEmpty) ...[
                      const Text(
                        'Seçilen Üyeler',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 50,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: _selectedMembers.length,
                          itemBuilder: (context, index) {
                            final user = _selectedMembers[index];
                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 10,
                                    backgroundColor: AppColors.primary,
                                    child: Text(
                                      user.name[0].toUpperCase(),
                                      style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    user.name.split(' ')[0],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () => _toggleMember(user),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      size: 14,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Contacts List title
                    const Text(
                      'Gruba Arkadaş Ekle',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Contacts list
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: selectableContacts.length,
                      itemBuilder: (context, index) {
                        final user = selectableContacts[index];
                        final isSelected = _selectedMembers.any((m) => m.id == user.id);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary.withOpacity(0.04) : AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? AppColors.primary.withOpacity(0.2) : Colors.transparent,
                            ),
                          ),
                          child: CheckboxListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                            value: isSelected,
                            onChanged: (_) => _toggleMember(user),
                            activeColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            checkboxShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            secondary: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary.withOpacity(0.15) : AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  user.name[0].toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              user.name,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            subtitle: Text(
                              user.email,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Action Button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _submit,
                  child: const Center(
                    child: Text(
                      'Grup Oluştur',
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
          ),
        ],
      ),
    );
  }
}
