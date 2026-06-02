import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/data/mock_data.dart';
import '../../core/models/models.dart';

/// Ödeme Detay Ekranı (Seç, Kopyala & Öde)
/// - Alacaklı kişi ve miktar özeti
/// - Çoklu banka kartı listesi arasından seçim yapabilme
/// - Hızlı panoya kopyalama ve görsel geri bildirim
/// - Popüler Türk bankacılık uygulamalarına hızlı geçiş bottom sheet desteği
/// - "Ödeme Yaptım" bildirimi ve başarı ekranına yönlendirme
class PaymentDetailScreen extends StatefulWidget {
  final String paymentId;

  const PaymentDetailScreen({super.key, required this.paymentId});

  @override
  State<PaymentDetailScreen> createState() => _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends State<PaymentDetailScreen> {
  late PaymentModel _payment;
  late UserModel _targetUser;
  late List<BankIbanModel> _bankAccounts;
  BankIbanModel? _selectedAccount;

  // Kısmi ödeme
  final TextEditingController _amountController = TextEditingController();
  double _paymentAmount = 0.0;
  bool _isCustomAmount = false;

  // Banka Renk ve Stil Eşleşmesi
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

  @override
  void initState() {
    super.initState();
    _payment = MockData.upcomingPayments.firstWhere(
      (p) => p.id == widget.paymentId,
      orElse: () => MockData.upcomingPayments[0],
    );

    final isOutgoing = _payment.fromUser.id == MockData.currentUser.id;
    _targetUser = isOutgoing ? _payment.toUser : _payment.fromUser;

    // Alıcının banka hesap listesi. Boş ise varsayılan tekli IBAN ile tek bir mock kart oluştur.
    if (_targetUser.bankIbans.isNotEmpty) {
      _bankAccounts = List.from(_targetUser.bankIbans);
    } else {
      _bankAccounts = [
        BankIbanModel(
          id: 'default_fallback',
          bankName: 'Varsayılan Hesap',
          iban: _targetUser.ibanNumber ?? 'TR00 0000 0000 0000 0000 0000 00',
          accountHolderName: _targetUser.name,
          bankKey: 'diger',
        )
      ];
    }
    
    // İlk banka hesabını varsayılan seç
    _selectedAccount = _bankAccounts.isNotEmpty ? _bankAccounts[0] : null;

    // Kısmi ödeme: varsayılan olarak kalan borcun tamamını öde
    _paymentAmount = _payment.remainingAmount;
    _amountController.text = _paymentAmount.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Ödeme Detayı',
          style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            // ─── Alacaklı Kişi Kartı ──────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
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
                children: [
                  // Avatar
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        _targetUser.name[0].toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _targetUser.name,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_payment.groupName} Ortak Harcaması',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Tutar - Toplam Borç
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.debit.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '₺${_payment.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: AppColors.debit,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Toplam Borç',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Daha önce ödeme varsa göster
                  if (_payment.paidAmount > 0) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                'Ödenen: ₺${_payment.paidAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.debit.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.schedule_rounded, color: AppColors.debit, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                'Kalan: ₺${_payment.remainingAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.debit,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // İlerleme çubuğu
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: _payment.paymentProgress,
                              backgroundColor: AppColors.border.withOpacity(0.3),
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '%${(_payment.paymentProgress * 100).toStringAsFixed(0)} ödendi',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ─── Ödeme Tutarı Giriş Alanı ─────────────
            Container(
              width: double.infinity,
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
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.payments_rounded, color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ödeme Tutarı',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Ne kadar ödeme yapmak istiyorsunuz?',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Hızlı seçim butonları
                  Row(
                    children: [
                      _buildQuickAmountButton('Tamamı', _payment.remainingAmount),
                      const SizedBox(width: 8),
                      _buildQuickAmountButton('Yarısı', _payment.remainingAmount / 2),
                      const SizedBox(width: 8),
                      _buildQuickAmountButton('¼', _payment.remainingAmount / 4),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isCustomAmount = true;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _isCustomAmount
                                  ? AppColors.primary.withOpacity(0.1)
                                  : AppColors.background,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _isCustomAmount
                                    ? AppColors.primary
                                    : AppColors.border.withOpacity(0.3),
                                width: _isCustomAmount ? 1.5 : 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Özel',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _isCustomAmount
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Tutar giriş alanı
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.background.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _isCustomAmount
                            ? AppColors.primary.withOpacity(0.4)
                            : AppColors.border.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.06),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(14),
                              bottomLeft: Radius.circular(14),
                            ),
                          ),
                          child: const Text(
                            '₺',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              hintText: '0.00',
                              hintStyle: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textTertiary.withOpacity(0.3),
                              ),
                            ),
                            onChanged: (value) {
                              final parsed = double.tryParse(value.replaceAll(',', '.'));
                              if (parsed != null) {
                                setState(() {
                                  _paymentAmount = parsed.clamp(0, _payment.remainingAmount);
                                  _isCustomAmount = true;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Slider
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: AppColors.border.withOpacity(0.2),
                      thumbColor: AppColors.primary,
                      overlayColor: AppColors.primary.withOpacity(0.1),
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                    ),
                    child: Slider(
                      value: _paymentAmount.clamp(0, _payment.remainingAmount),
                      min: 0,
                      max: _payment.remainingAmount > 0 ? _payment.remainingAmount : 1,
                      onChanged: (value) {
                        setState(() {
                          _paymentAmount = double.parse(value.toStringAsFixed(2));
                          _amountController.text = _paymentAmount.toStringAsFixed(2);
                          _isCustomAmount = true;
                        });
                      },
                    ),
                  ),

                  // Min - Max label
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₺0.00',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        Text(
                          'Maks: ₺${_payment.remainingAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ─── Çoklu Banka Seçim Listesi ─────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Alıcının Hesapları (Ödemek İstediğinizi Seçin)',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${_bankAccounts.length} Kayıtlı',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            
            SizedBox(
              height: 155,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _bankAccounts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final account = _bankAccounts[index];
                  final isSelected = _selectedAccount?.id == account.id;
                  final style = _bankStyles[account.bankKey] ?? _bankStyles['diger']!;
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedAccount = account;
                      });
                      // Otomatik panoya kopyala
                      Clipboard.setData(ClipboardData(text: account.iban.replaceAll(' ', '')));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${account.bankName} IBAN kopyalandı!'),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 250,
                      decoration: BoxDecoration(
                        gradient: style['bg'] as Gradient,
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected 
                            ? Border.all(color: Colors.amber, width: 3) 
                            : Border.all(color: Colors.transparent),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected 
                                ? Colors.amber.withOpacity(0.3) 
                                : (style['accent'] as Color).withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          if (isSelected)
                            const Positioned(
                              top: 10,
                              right: 10,
                              child: Icon(Icons.check_circle_rounded, color: Colors.amber, size: 22),
                            ),
                           Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    _BankLogo(bankKey: account.bankKey, size: 22),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            account.bankName,
                                            style: const TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                              letterSpacing: 0.3,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'HESAP DETAYI',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 8,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white.withOpacity(0.5),
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Text(
                                  account.iban,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const Spacer(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'ALICI HESAP SAHİBİ',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 7,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white.withOpacity(0.5),
                                            ),
                                          ),
                                          Text(
                                            account.accountHolderName.toUpperCase(),
                                            style: const TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      account.bankKey == 'papara' ? Icons.wallet_membership_rounded : Icons.account_balance_rounded,
                                      color: Colors.white.withOpacity(0.2),
                                      size: 24,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),

            // ─── Aktif IBAN Kopyalama Paneli ───────────
            if (_selectedAccount != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _selectedAccount!.bankKey == 'papara' ? Icons.account_balance_wallet_rounded : Icons.account_balance_rounded, 
                              color: AppColors.primary, 
                              size: 16
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Seçili IBAN: ${_selectedAccount!.bankName}',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          ),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _selectedAccount!.iban.replaceAll(' ', '')));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('IBAN panoya kopyalandı!'),
                                backgroundColor: AppColors.success,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy_rounded, size: 12),
                          label: const Text(
                            'Kopyala',
                            style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.background.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border.withOpacity(0.5)),
                      ),
                      child: SelectableText(
                        _selectedAccount!.iban,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Alıcı Adı: ${_selectedAccount!.accountHolderName.toUpperCase()}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),

            // ─── Mobil Bankacılık Yönlendirme ────────
            Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    if (_selectedAccount != null) {
                      Clipboard.setData(ClipboardData(text: _selectedAccount!.iban.replaceAll(' ', '')));
                    }
                    _showBankLauncherSheet(context);
                  },
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.account_balance_rounded, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Banka Uygulamasında Aç & Öde',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ─── Ödeme Yaptım Butonu ──────────────────
            Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                gradient: AppColors.successGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _paymentAmount > 0
                      ? () {
                          context.push(
                            '/payment-success',
                            extra: {
                              'amount': _paymentAmount,
                              'recipientName': _targetUser.name,
                              'totalDebt': _payment.amount,
                              'remainingAfter': (_payment.remainingAmount - _paymentAmount).clamp(0.0, _payment.amount),
                              'isPartial': _paymentAmount < _payment.remainingAmount,
                            },
                          );
                        }
                      : null,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          _paymentAmount > 0
                              ? '₺${_paymentAmount.toStringAsFixed(2)} Ödeme Yaptım'
                              : 'Tutar Girin',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAmountButton(String label, double amount) {
    final isActive = !_isCustomAmount && (_paymentAmount - amount).abs() < 0.01;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _paymentAmount = double.parse(amount.toStringAsFixed(2));
            _amountController.text = _paymentAmount.toStringAsFixed(2);
            _isCustomAmount = false;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withOpacity(0.1)
                : AppColors.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive
                  ? AppColors.primary
                  : AppColors.border.withOpacity(0.3),
              width: isActive ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isActive
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showBankLauncherSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Bankacılık Uygulamaları',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
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
              const SizedBox(height: 6),
              Text(
                '${_selectedAccount?.bankName} IBAN kopyalandı. Hangi banka uygulamasına geçmek istersiniz?',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 180,
                child: GridView.count(
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    _buildBankAppItem('Ziraat', const Color(0xFFC71F26), 'Ziraat'),
                    _buildBankAppItem('Kuveyt', const Color(0xFF00543F), 'Kuveyt T.'),
                    _buildBankAppItem('İşCep', const Color(0xFF003B91), 'İşCep'),
                    _buildBankAppItem('Akbank', const Color(0xFFE30613), 'Akbank'),
                    _buildBankAppItem('Garanti', const Color(0xFF008248), 'Garanti'),
                    _buildBankAppItem('YKB', const Color(0xFF002D72), 'YKB'),
                    _buildBankAppItem('Papara', const Color(0xFF8C47FF), 'Papara'),
                    _buildBankAppItem('Diğer', const Color(0xFF4A5568), 'Diğer'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBankAppItem(String key, Color color, String name) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.pop(context); // Bottom sheet'i kapat
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.launch_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  '$name uygulaması açılıyor...',
                  style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500),
                ),
              ],
            ),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.2), width: 1),
            ),
            alignment: Alignment.center,
            child: Text(
              key[0],
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
