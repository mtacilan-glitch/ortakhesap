import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

/// Ödeme Başarı Ekranı
/// - Yeşil ✓ animasyonu
/// - "Başarıyla Ödendi" mesajı
/// - Bakiyeden düşüm animasyonu (AnimatedCounter)
/// - Kısmi ödeme bilgi gösterimi
class PaymentSuccessScreen extends StatefulWidget {
  final double amount;
  final String recipientName;
  final double totalDebt;
  final double remainingAfter;
  final bool isPartial;

  const PaymentSuccessScreen({
    super.key,
    required this.amount,
    required this.recipientName,
    this.totalDebt = 0.0,
    this.remainingAfter = 0.0,
    this.isPartial = false,
  });

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkController;
  late AnimationController _fadeController;
  late AnimationController _counterController;
  late Animation<double> _checkScale;
  late Animation<double> _fadeIn;
  late Animation<double> _counterValue;

  @override
  void initState() {
    super.initState();

    // Check mark animasyonu
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _checkScale = CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    );

    // Fade-in animasyonu
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    // Counter animasyonu
    _counterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _counterValue = Tween<double>(begin: 0, end: widget.amount).animate(
      CurvedAnimation(
        parent: _counterController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Animasyonları başlat
    Future.delayed(const Duration(milliseconds: 200), () {
      _checkController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _fadeController.forward();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      _counterController.forward();
    });
  }

  @override
  void dispose() {
    _checkController.dispose();
    _fadeController.dispose();
    _counterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const SizedBox(height: 24),

              // ─── Yeşil Tik Animasyonu ────────────────
              ScaleTransition(
                scale: _checkScale,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: AppColors.successGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withOpacity(0.35),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ─── Başarı Mesajı ───────────────────────
              FadeTransition(
                opacity: _fadeIn,
                child: Column(
                  children: [
                    Text(
                      widget.isPartial ? 'Kısmi Ödeme Yapıldı!' : 'Başarıyla Ödendi!',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${widget.recipientName} kişisine ödeme yapıldı',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // ─── Animasyonlu Tutar ───────────────────
              AnimatedBuilder(
                animation: _counterValue,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.success.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.remove_circle_rounded, color: AppColors.success, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          '₺${_counterValue.value.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: AppColors.success,
                            letterSpacing: -1,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              FadeTransition(
                opacity: _fadeIn,
                child: const Text(
                  'Bakiyenizden düşüldü',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),

              // ─── Kısmi Ödeme Bilgi Kartı ─────────────
              if (widget.isPartial && widget.totalDebt > 0) ...[
                const SizedBox(height: 24),
                FadeTransition(
                  opacity: _fadeIn,
                  child: Container(
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
                      children: [
                        const Text(
                          'Ödeme Özeti',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Toplam Borç
                        _buildSummaryRow(
                          'Toplam Borç',
                          '₺${widget.totalDebt.toStringAsFixed(2)}',
                          AppColors.textSecondary,
                        ),
                        const SizedBox(height: 8),

                        // Bu Ödeme
                        _buildSummaryRow(
                          'Bu Ödeme',
                          '- ₺${widget.amount.toStringAsFixed(2)}',
                          AppColors.success,
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Divider(
                            color: AppColors.border.withOpacity(0.3),
                            height: 1,
                          ),
                        ),

                        // Kalan Borç
                        _buildSummaryRow(
                          'Kalan Borç',
                          '₺${widget.remainingAfter.toStringAsFixed(2)}',
                          AppColors.debit,
                          isBold: true,
                        ),

                        const SizedBox(height: 12),

                        // İlerleme çubuğu
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: widget.totalDebt > 0
                                ? ((widget.totalDebt - widget.remainingAfter) / widget.totalDebt).clamp(0.0, 1.0)
                                : 0.0,
                            backgroundColor: AppColors.border.withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.remainingAfter > 0.01
                              ? '₺${widget.remainingAfter.toStringAsFixed(2)} daha ödemeniz kaldı'
                              : 'Borcunuz tamamen kapandı! 🎉',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: widget.remainingAfter > 0.01
                                ? AppColors.textTertiary
                                : AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Tam ödeme bilgi satırı
              if (!widget.isPartial && widget.totalDebt > 0) ...[
                const SizedBox(height: 20),
                FadeTransition(
                  opacity: _fadeIn,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.success.withOpacity(0.2)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.celebration_rounded, color: AppColors.success, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Borcunuz tamamen kapandı! 🎉',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 40),

              // ─── Ana Sayfaya Dön Butonu ──────────────
              FadeTransition(
                opacity: _fadeIn,
                child: Container(
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
                      onTap: () => context.go('/'),
                      child: const Center(
                        child: Text(
                          'Ana Sayfaya Dön',
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
        ),
      ),
    ),
  );
}

  Widget _buildSummaryRow(String label, String value, Color valueColor, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
