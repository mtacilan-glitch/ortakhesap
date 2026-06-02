import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/data/mock_data.dart';
import '../../core/models/models.dart';
import '../../core/providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late List<BankIbanModel> _myBankIbans;
  bool _isPremiumUser = false; // local mock state
  final _addIbanFormKey = GlobalKey<FormState>();

  // Form controllers
  late TextEditingController _ibanInputController;
  late TextEditingController _holderNameController;
  String _selectedBankKey = 'ziraat';

  final List<Map<String, String>> _availableBanks = [
    {'key': 'ziraat', 'name': 'Ziraat Bankası'},
    {'key': 'kuveytturk', 'name': 'Kuveyt Türk'},
    {'key': 'isbank', 'name': 'Türkiye İş Bankası'},
    {'key': 'akbank', 'name': 'Akbank'},
    {'key': 'garanti', 'name': 'Garanti BBVA'},
    {'key': 'yapikredi', 'name': 'Yapı Kredi'},
    {'key': 'papara', 'name': 'Papara'},
    {'key': 'diger', 'name': 'Diğer Banka / Hesap'},
  ];

  @override
  void initState() {
    super.initState();
    _myBankIbans = List.from(MockData.currentUser.bankIbans);
    _ibanInputController = TextEditingController();
    _holderNameController = TextEditingController(text: MockData.currentUser.name);
  }

  @override
  void dispose() {
    _ibanInputController.dispose();
    _holderNameController.dispose();
    super.dispose();
  }

  // IBAN'ı okunaklı formatlamak için formatlayıcı
  String _formatIban(String value) {
    String clean = value.replaceAll(RegExp(r'[^A-Z0-9]'), '').toUpperCase();
    if (!clean.startsWith('TR')) {
      if (clean.startsWith('T') && clean.length == 1) {
        clean = 'TR';
      } else if (!clean.startsWith('T')) {
        clean = 'TR$clean';
      }
    }
    
    // TR sonrasını sadece rakamla sınırla
    String prefix = 'TR';
    String rest = clean.length > 2 ? clean.substring(2).replaceAll(RegExp(r'[^0-9]'), '') : '';
    clean = prefix + rest;
    if (clean.length > 26) {
      clean = clean.substring(0, 26);
    }

    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < clean.length; i++) {
      buffer.write(clean[i]);
      if ((i + 1) % 4 == 0 && i != clean.length - 1) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }

  void _addNewBankIban() {
    if (_addIbanFormKey.currentState!.validate()) {
      final bankName = _availableBanks.firstWhere((b) => b['key'] == _selectedBankKey)['name']!;
      final newAccount = BankIbanModel(
        id: 'bi_${DateTime.now().millisecondsSinceEpoch}',
        bankName: bankName,
        iban: _ibanInputController.text,
        accountHolderName: _holderNameController.text,
        bankKey: _selectedBankKey,
      );

      setState(() {
        _myBankIbans.add(newAccount);
      });

      // Formu temizle
      _ibanInputController.clear();
      _holderNameController.text = MockData.currentUser.name;

      Navigator.pop(context); // Bottom sheet'i kapat

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                '$bankName başarıyla eklendi.',
                style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _deleteBankIban(String id, String bankName) {
    setState(() {
      _myBankIbans.removeWhere((item) => item.id == id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.delete_outline_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              '$bankName hesabı silindi.',
              style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          children: [
            // Üst Header
            _buildProfileHeader(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Premium Banner
                  _buildPremiumCard(),
                  const SizedBox(height: 20),

                  // IBAN Düzenleme Kartı
                  _buildIbanCard(),
                  const SizedBox(height: 24),

                  // Ayarlar Menüsü
                  _buildSettingsMenu(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.only(top: 60, bottom: 30, left: 24, right: 24),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                height: 90,
                width: 90,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.white, width: 3),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'MY',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
              if (_isPremiumUser)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            MockData.currentUser.name,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            MockData.currentUser.email,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          if (_isPremiumUser) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'PREMIUM ÜYE',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPremiumCard() {
    if (_isPremiumUser) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.premiumGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            // Premium ekranına git
            final result = await context.push<bool>('/premium');
            if (result == true) {
              setState(() {
                _isPremiumUser = true;
              });
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'Premium\'a Yükselt',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Borç sadeleştirme, gelişmiş limitler, otomatik hatırlatıcılar ve reklamsız deneyim!',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Banka Stil Tanımları
  static const _bankStyles = {
    'ziraat': {
      'bg': LinearGradient(colors: [Color(0xFFC71F26), Color(0xFF901116)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      'color': Colors.white,
      'accent': Color(0xFFFFA0A3),
    },
    'kuveytturk': {
      'bg': LinearGradient(colors: [Color(0xFF00543F), Color(0xFF003023)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      'color': Colors.white,
      'accent': Color(0xFFC5A059),
    },
    'isbank': {
      'bg': LinearGradient(colors: [Color(0xFF003B91), Color(0xFF001A4E)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      'color': Colors.white,
      'accent': Color(0xFFFFAE00),
    },
    'akbank': {
      'bg': LinearGradient(colors: [Color(0xFFE30613), Color(0xFFAC000A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      'color': Colors.white,
      'accent': Color(0xFFFFA09E),
    },
    'garanti': {
      'bg': LinearGradient(colors: [Color(0xFF008248), Color(0xFF00502A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      'color': Colors.white,
      'accent': Color(0xFF8CE095),
    },
    'yapikredi': {
      'bg': LinearGradient(colors: [Color(0xFF002D72), Color(0xFF001438)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      'color': Colors.white,
      'accent': Color(0xFFFFAE00),
    },
    'papara': {
      'bg': LinearGradient(colors: [Color(0xFF1E1E24), Color(0xFF0F0F12)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      'color': Colors.white,
      'accent': Color(0xFF8C47FF),
    },
    'diger': {
      'bg': LinearGradient(colors: [Color(0xFF4A5568), Color(0xFF2D3748)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      'color': Colors.white,
      'accent': Color(0xFFCBD5E0),
    },
  };

  Widget _buildIbanCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Banka Hesaplarım',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (_myBankIbans.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_myBankIbans.length}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _showAddAccountBottomSheet,
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text(
                'Hesap Ekle',
                style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_myBankIbans.isEmpty)
          GestureDetector(
            onTap: _showAddAccountBottomSheet,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(Icons.add_card_rounded, size: 40, color: AppColors.textTertiary.withOpacity(0.4)),
                  const SizedBox(height: 12),
                  const Text(
                    'Kayıtlı banka hesabı bulunmuyor.',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Borçlularınızın size kolayca ödeme yapması için banka hesabınızı ekleyin.',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.textTertiary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 175,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _myBankIbans.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final account = _myBankIbans[index];
                final style = _bankStyles[account.bankKey] ?? _bankStyles['diger']!;
                
                return Container(
                  width: 290,
                  decoration: BoxDecoration(
                    gradient: style['bg'] as Gradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: (style['accent'] as Color).withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Dekoratif Cam Parlaması
                      Positioned(
                        right: -30,
                        top: -30,
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.06),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      _BankLogo(bankKey: account.bankKey, size: 24),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              account.bankName,
                                              style: const TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 13,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.white,
                                                letterSpacing: 0.3,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'ORTAK HESAP PAYLAŞIMI',
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 8,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white.withOpacity(0.6),
                                                letterSpacing: 0.8,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Silme & Kopyalama Düğmeleri
                                Row(
                                  children: [
                                    Material(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(8),
                                        onTap: () {
                                          Clipboard.setData(ClipboardData(text: account.iban.replaceAll(' ', '')));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('${account.bankName} IBAN panoya kopyalandı!'),
                                              backgroundColor: AppColors.success,
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              duration: const Duration(seconds: 2),
                                            ),
                                          );
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.all(6),
                                          child: Icon(Icons.copy_rounded, color: Colors.white, size: 14),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Material(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(8),
                                        onTap: () => _deleteBankIban(account.id, account.bankName),
                                        child: const Padding(
                                          padding: EdgeInsets.all(6),
                                          child: Icon(Icons.delete_outline_rounded, color: Colors.white, size: 14),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Spacer(),
                            // IBAN Bölümü
                            Text(
                              account.iban,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 1.1,
                              ),
                            ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'HESAP SAHİBİ',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 7,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white.withOpacity(0.5),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      account.accountHolderName.toUpperCase(),
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(
                                  account.bankKey == 'papara' ? Icons.wallet_membership_rounded : Icons.account_balance_rounded,
                                  color: Colors.white.withOpacity(0.2),
                                  size: 32,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  void _showAddAccountBottomSheet() {
    setState(() {
      _ibanInputController.clear();
      _holderNameController.text = MockData.currentUser.name;
      _selectedBankKey = 'ziraat';
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _addIbanFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Yeni Banka Hesabı Ekle',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded, color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Banka Seçici Grid/List
                    const Text(
                      'Banka Seçimi',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 48,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _availableBanks.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final bank = _availableBanks[index];
                          final isSelected = _selectedBankKey == bank['key']!;
                          final style = _bankStyles[bank['key']!] ?? _bankStyles['diger']!;
                          
                          return ChoiceChip(
                            label: Text(
                              bank['name']!,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setModalState(() {
                                  _selectedBankKey = bank['key']!;
                                });
                              }
                            },
                            selectedColor: (style['bg'] as LinearGradient).colors[0],
                            backgroundColor: AppColors.background,
                            checkmarkColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: isSelected ? Colors.transparent : AppColors.border),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Hesap Sahibi Girişi
                    TextFormField(
                      controller: _holderNameController,
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        labelText: 'Alıcı Adı Soyadı',
                        labelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.textTertiary),
                        prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                        filled: true,
                        fillColor: AppColors.background.withOpacity(0.4),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Ad Soyadı boş bırakılamaz';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // IBAN Girişi
                    TextFormField(
                      controller: _ibanInputController,
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: 'TR ile Başlayan IBAN Numarası',
                        labelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.textTertiary),
                        prefixIcon: const Icon(Icons.credit_card_rounded, color: AppColors.primary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                        filled: true,
                        fillColor: AppColors.background.withOpacity(0.4),
                        hintText: 'TR00 0000 0000 0000 0000 0000 00',
                        hintStyle: TextStyle(color: AppColors.textTertiary.withOpacity(0.4), fontSize: 12),
                      ),
                      onChanged: (val) {
                        final formatted = _formatIban(val);
                        if (formatted != val) {
                          _ibanInputController.value = TextEditingValue(
                            text: formatted,
                            selection: TextSelection.collapsed(offset: formatted.length),
                          );
                        }
                      },
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'IBAN alanı boş bırakılamaz';
                        }
                        String clean = val.replaceAll(' ', '');
                        if (!clean.startsWith('TR')) {
                          return 'IBAN "TR" ile başlamalıdır';
                        }
                        if (clean.length != 26) {
                          return 'IBAN 26 karakter olmalıdır (Giriş: ${clean.length})';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Ekle Butonu
                    Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: _addNewBankIban,
                          child: const Center(
                            child: Text(
                              'Hesabı Ekle',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSettingsMenu() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsItem(
            icon: Icons.bar_chart_rounded,
            color: Colors.purple,
            title: 'Raporlar & İstatistikler',
            onTap: () => context.push('/statistics'),
          ),
          _buildDivider(),
          _buildSettingsItem(
            icon: Icons.notifications_none_rounded,
            color: Colors.amber[700]!,
            title: 'Bildirim Ayarları',
            trailing: Switch.adaptive(
              value: true,
              activeColor: AppColors.primary,
              onChanged: (val) {},
            ),
          ),
          _buildDivider(),
          _buildSettingsItem(
            icon: Icons.translate_rounded,
            color: Colors.blue,
            title: 'Dil Seçimi',
            subtitle: 'Türkçe',
            onTap: () {},
          ),
          _buildDivider(),
          _buildSettingsItem(
            icon: Icons.shield_outlined,
            color: Colors.teal,
            title: 'Güvenlik & PIN Kilidi',
            onTap: () {},
          ),
          _buildDivider(),
          _buildSettingsItem(
            icon: Icons.help_outline_rounded,
            color: Colors.grey[600]!,
            title: 'Yardım & Destek',
            onTap: () {},
          ),
          _buildDivider(),
          _buildSettingsItem(
            icon: Icons.logout_rounded,
            color: Colors.red,
            title: 'Çıkış Yap',
            textColor: Colors.red,
            onTap: _showLogoutDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required Color color,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        height: 36,
        width: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textColor ?? AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: AppColors.textTertiary,
              ),
            )
          : null,
      trailing: trailing ??
          (onTap != null
              ? const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textTertiary, size: 14)
              : null),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 20,
      endIndent: 20,
      color: AppColors.divider,
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Oturumu Kapat',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Çıkış yapmak istediğinize emin misiniz?',
          style: TextStyle(fontFamily: 'Inter', color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Vazgeç',
              style: TextStyle(fontFamily: 'Inter', color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
            },
            child: const Text(
              'Çıkış Yap',
              style: TextStyle(fontFamily: 'Inter', color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Banka Logosu Yüksek Çözünürlüklü Vektör Tasarımı ─────────
class _BankLogo extends StatelessWidget {
  final String bankKey;
  final double size;

  const _BankLogo({required this.bankKey, this.size = 24});

  @override
  Widget build(BuildContext context) {
    switch (bankKey) {
      case 'ziraat':
        return Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            'Z',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: size * 0.6,
              fontWeight: FontWeight.w900,
              color: const Color(0xFFC71F26),
            ),
          ),
        );
      case 'kuveytturk':
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFFC5A059),
            borderRadius: BorderRadius.circular(size * 0.3),
          ),
          alignment: Alignment.center,
          child: Text(
            'KT',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: size * 0.45,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF00543F),
            ),
          ),
        );
      case 'isbank':
        return Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            'İş',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: size * 0.55,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              color: const Color(0xFF003B91),
            ),
          ),
        );
      case 'akbank':
        return Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            'a',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: size * 0.6,
              fontWeight: FontWeight.w900,
              color: const Color(0xFFE30613),
            ),
          ),
        );
      case 'garanti':
        return Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            'G',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: size * 0.55,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF008248),
            ),
          ),
        );
      case 'yapikredi':
        return Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: Color(0xFFFFAE00),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            'YK',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: size * 0.5,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF002D72),
            ),
          ),
        );
      case 'papara':
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF8C47FF), width: 1),
          ),
          alignment: Alignment.center,
          child: Text(
            'P',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: size * 0.55,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF8C47FF),
            ),
          ),
        );
      default:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(Icons.credit_card_rounded, color: Colors.white, size: size * 0.55),
          ),
        );
    }
  }
}
