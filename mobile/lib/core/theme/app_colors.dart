import 'package:flutter/material.dart';

/// Ortak Hesap Renk Paleti
/// Modern mor/mavi gradient ağırlıklı, temiz ve şık.
class AppColors {
  AppColors._();

  // ─── Ana Renkler ─────────────────────────────────
  static const Color primary = Color(0xFF5E5CE6);
  static const Color primaryLight = Color(0xFF7B79F7);
  static const Color primaryDark = Color(0xFF4A48C4);
  static const Color secondary = Color(0xFF30D158);

  // ─── Gradient ────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5E5CE6), Color(0xFF7B79F7), Color(0xFF9B8CFF)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5E5CE6), Color(0xFF8B5CF6)],
  );

  static const LinearGradient premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD700), Color(0xFFFF8C00), Color(0xFFFF6347)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF30D158), Color(0xFF34C759)],
  );

  // ─── Arka Plan ───────────────────────────────────
  static const Color background = Color(0xFFF5F5FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0EEFF);

  // ─── Metin ───────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1D2E);
  static const Color textSecondary = Color(0xFF6B7085);
  static const Color textTertiary = Color(0xFF9DA3B7);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ─── Durum Renkleri ──────────────────────────────
  static const Color success = Color(0xFF30D158);
  static const Color warning = Color(0xFFFFCC00);
  static const Color danger = Color(0xFFFF3B30);
  static const Color info = Color(0xFF007AFF);

  // ─── Alacak/Borç ─────────────────────────────────
  static const Color credit = Color(0xFF30D158);    // Alacak - Yeşil
  static const Color debit = Color(0xFFFF3B30);     // Borç - Kırmızı

  // ─── Diğer ───────────────────────────────────────
  static const Color border = Color(0xFFE8E8ED);
  static const Color divider = Color(0xFFF2F2F7);
  static const Color shimmerBase = Color(0xFFE8E8ED);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
  static const Color shadow = Color(0x1A5E5CE6);

  // ─── Kategori Renkleri ───────────────────────────
  static const Color categoryMarket = Color(0xFF30D158);
  static const Color categoryUlasim = Color(0xFF007AFF);
  static const Color categoryYemek = Color(0xFFFF9500);
  static const Color categoryEglence = Color(0xFFFF2D55);
  static const Color categoryFatura = Color(0xFFAF52DE);
  static const Color categorySaglik = Color(0xFF5AC8FA);
  static const Color categoryDiger = Color(0xFF8E8E93);
}
