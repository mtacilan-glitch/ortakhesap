import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/groups_provider.dart';

class AddMemberSheet extends ConsumerStatefulWidget {
  final String groupId;
  final List<UserModel> currentMembers;

  const AddMemberSheet({
    super.key,
    required this.groupId,
    required this.currentMembers,
  });

  @override
  ConsumerState<AddMemberSheet> createState() => _AddMemberSheetState();
}

class _AddMemberSheetState extends ConsumerState<AddMemberSheet> {
  final _searchController = TextEditingController();
  final _newNameController = TextEditingController();
  final _newEmailController = TextEditingController();
  
  String _searchQuery = '';
  bool _isCreatingNewContact = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _newNameController.dispose();
    _newEmailController.dispose();
    super.dispose();
  }

  void _addExistingMember(UserModel user) {
    ref.read(groupsProvider.notifier).addMember(widget.groupId, user);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${user.name} gruba eklendi!'),
        backgroundColor: AppColors.credit,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _createNewContactAndAdd() {
    if (!_formKey.currentState!.validate()) return;

    final name = _newNameController.text.trim();
    final email = _newEmailController.text.trim();

    // 1. Create contact
    final newUser = ref.read(contactsProvider.notifier).addContact(name: name, email: email);

    // 2. Add to group
    ref.read(groupsProvider.notifier).addMember(widget.groupId, newUser);

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name oluşturuldu ve gruba eklendi!'),
        backgroundColor: AppColors.credit,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final contacts = ref.watch(contactsProvider);
    
    // Exclude users already in the group
    final nonMembers = contacts.where((contact) {
      return !widget.currentMembers.any((member) => member.id == contact.id);
    }).toList();

    // Filter by search query
    final filteredContacts = nonMembers.where((contact) {
      return contact.name.toLowerCase().contains(_searchQuery) ||
             contact.email.toLowerCase().contains(_searchQuery);
    }).toList();

    // Check if the search query looks like a search with no results
    final hasNoResults = filteredContacts.isEmpty && _searchQuery.isNotEmpty;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
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
                    _isCreatingNewContact ? 'Yeni Arkadaş Ekle' : 'Gruba Üye Ekle',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: AppColors.textTertiary),
                  ),
                ],
              ),
            ),
            const Divider(height: 16, thickness: 1),

            if (_isCreatingNewContact)
              // FORM TO CREATE NEW CONTACT
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rehberinizde bulunmayan yeni bir arkadaşınızı ekleyin. Bu kişi hem rehberinize hem de gruba eklenecektir.',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _newNameController,
                          autofocus: true,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Ad Soyad',
                            hintText: 'Örn: Ahmet Yılmaz',
                            prefixIcon: const Icon(Icons.person_outline_rounded),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Lütfen bir isim girin';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _newEmailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'E-posta Adresi',
                            hintText: 'ahmet@email.com',
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Lütfen e-posta girin';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                              return 'Geçerli bir e-posta adresi girin';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _isCreatingNewContact = false;
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text('Geri Dön'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(14),
                                    onTap: _createNewContactAndAdd,
                                    child: const Center(
                                      child: Text(
                                        'Oluştur ve Ekle',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
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
                      ],
                    ),
                  ),
                ),
              )
            else ...[
              // SEARCH & SELECT EXISTING CONTACT LIST
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'İsim veya e-posta ile ara...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              
              Expanded(
                child: filteredContacts.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                hasNoResults ? Icons.person_search_rounded : Icons.people_outline_rounded,
                                size: 56,
                                color: AppColors.textTertiary.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                hasNoResults
                                    ? '"$_searchQuery" için sonuç bulunamadı'
                                    : 'Gruba eklenebilecek arkadaş kalmadı',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 15,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    if (hasNoResults && _searchQuery.contains('@')) {
                                      _newEmailController.text = _searchController.text;
                                    } else if (hasNoResults) {
                                      _newNameController.text = _searchController.text;
                                    }
                                    _isCreatingNewContact = true;
                                  });
                                },
                                icon: const Icon(Icons.person_add_rounded, size: 18),
                                label: const Text('Yeni Arkadaş Oluştur'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: filteredContacts.length,
                        itemBuilder: (context, index) {
                          final user = filteredContacts[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    user.name[0].toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
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
                              trailing: IconButton(
                                icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 24),
                                onPressed: () => _addExistingMember(user),
                              ),
                              onTap: () => _addExistingMember(user),
                            ),
                          );
                        },
                      ),
              ),
              
              if (!hasNoResults)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _isCreatingNewContact = true;
                      });
                    },
                    icon: const Icon(Icons.person_add_rounded, size: 18),
                    label: const Text('Listede Yok mu? Yeni Arkadaş Oluştur'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
