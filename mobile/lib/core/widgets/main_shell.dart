import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../providers/auth_provider.dart';
import 'search_overlay.dart';
import 'notification_sheet.dart';

/// Ana kabuk widget — Responsive Layout
/// - Geniş ekran (≥ 900px): Sol Sidebar + Üst Header
/// - Dar ekran (< 900px): Alt Navigation Bar + FAB
class MainShell extends ConsumerStatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  bool _sidebarCollapsed = false;

  String _getCurrentPath(BuildContext context) {
    return GoRouterState.of(context).uri.path;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 900;
    final currentPath = _getCurrentPath(context);
    final currentUser = ref.watch(currentUserProvider);

    if (isWide) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F8FD),
        body: Row(
          children: [
            // ─── Sol Sidebar ─────────────────────────────
            _Sidebar(
              currentPath: currentPath,
              collapsed: _sidebarCollapsed,
              onToggle: () => setState(() => _sidebarCollapsed = !_sidebarCollapsed),
              currentUser: currentUser,
            ),
            // ─── Ana İçerik ──────────────────────────────
            Expanded(
              child: Column(
                children: [
                  // Üst Header
                  _TopHeader(currentUser: currentUser),
                  // Sayfa İçeriği
                  Expanded(child: widget.child),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // ─── Mobil Layout ────────────────────────────────────
    return Scaffold(
      backgroundColor: AppColors.background,
      body: widget.child,
      extendBody: true,
      floatingActionButton: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => context.push('/add-expense'),
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add_rounded, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _MobileBottomNav(currentPath: currentPath),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  SOL SIDEBAR
// ═══════════════════════════════════════════════════════════

class _Sidebar extends StatelessWidget {
  final String currentPath;
  final bool collapsed;
  final VoidCallback onToggle;
  final dynamic currentUser;

  const _Sidebar({
    required this.currentPath,
    required this.collapsed,
    required this.onToggle,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    final width = collapsed ? 72.0 : 240.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: width,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 20,
            offset: Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Logo + Toggle ───────────────────────
          Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text('O', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                  ),
                ),
                if (!collapsed) ...[
                  const SizedBox(width: 12),
                  const Text(
                    'ortak.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1D2E),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onToggle,
                    child: const Icon(Icons.menu_rounded, color: AppColors.textTertiary, size: 22),
                  ),
                ],
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, color: Color(0xFFF2F2F7)),
          const SizedBox(height: 12),

          // ─── Menü Öğeleri ─────────────────────────
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (!collapsed)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Text(
                        'MENÜ',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textTertiary.withOpacity(0.6),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  _SidebarItem(icon: Icons.home_rounded, label: 'Ana Sayfa', path: '/', currentPath: currentPath, collapsed: collapsed),
                  _SidebarItem(icon: Icons.group_rounded, label: 'Gruplar', path: '/groups', currentPath: currentPath, collapsed: collapsed),
                  _SidebarItem(icon: Icons.receipt_long_rounded, label: 'Harcamalar', path: '/expenses', currentPath: currentPath, collapsed: collapsed),
                  _SidebarItem(icon: Icons.account_balance_wallet_rounded, label: 'Borçlar', path: '/payments', currentPath: currentPath, collapsed: collapsed),
                  _SidebarItem(icon: Icons.bar_chart_rounded, label: 'Analiz', path: '/statistics', currentPath: currentPath, collapsed: collapsed),

                  const SizedBox(height: 16),
                  if (!collapsed)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Text(
                        'DİĞER',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textTertiary.withOpacity(0.6),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  _SidebarItem(icon: Icons.subscriptions_rounded, label: 'Abonelikler', path: '/subscriptions', currentPath: currentPath, collapsed: collapsed),
                  _SidebarItem(icon: Icons.flag_rounded, label: 'Hedefler', path: '/goals', currentPath: currentPath, collapsed: collapsed),
                  _SidebarItem(icon: Icons.task_alt_rounded, label: 'Görevler', path: '/tasks', currentPath: currentPath, collapsed: collapsed, badge: 3),
                  _SidebarItem(icon: Icons.settings_rounded, label: 'Ayarlar', path: '/settings', currentPath: currentPath, collapsed: collapsed),
                ],
              ),
            ),
          ),
          // ─── Kullanıcı Profili (Alt) ───────────────
          const Divider(height: 1, thickness: 1, color: Color(0xFFF2F2F7)),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.go('/profile'),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          (currentUser?.name ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                      ),
                    ),
                    if (!collapsed) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentUser?.name ?? 'Kullanıcı',
                              style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1D2E)),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              currentUser?.isPremium == true ? 'Premium Üye' : 'Ücretsiz',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                color: currentUser?.isPremium == true ? const Color(0xFFFFB800) : AppColors.textTertiary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textTertiary, size: 18),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String path;
  final String currentPath;
  final bool collapsed;
  final int? badge;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.path,
    required this.currentPath,
    required this.collapsed,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = path == '/' ? currentPath == '/' : currentPath.startsWith(path);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.go(path),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: collapsed ? 12 : 12, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      icon,
                      size: 22,
                      color: isSelected ? AppColors.primary : AppColors.textTertiary,
                    ),
                    if (badge != null)
                      Positioned(
                        right: -6,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: AppColors.danger,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$badge',
                            style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                  ],
                ),
                if (!collapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? AppColors.primary : const Color(0xFF6B7085),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  ÜST HEADER
// ═══════════════════════════════════════════════════════════

class _TopHeader extends StatelessWidget {
  final dynamic currentUser;

  const _TopHeader({required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF2F2F7), width: 1)),
      ),
      child: Row(
        children: [
          // Selamlama
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Merhaba, ${currentUser?.name?.split(' ').first ?? 'Kullanıcı'} 👋',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1D2E),
                ),
              ),
              const Text(
                'Ortak finansal hayatını kolaylaştırıyoruz.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const Spacer(),

          // Arama
          GestureDetector(
            onTap: () => SearchOverlay.show(context),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                width: 200,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8FD),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFEEEEF5)),
                ),
                child: const Row(
                  children: [
                    SizedBox(width: 12),
                    Icon(Icons.search_rounded, size: 18, color: AppColors.textTertiary),
                    SizedBox(width: 8),
                    Text('Ara...', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.textTertiary)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Bildirim
          GestureDetector(
            onTap: () => NotificationSheet.show(context),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8FD),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFEEEEF5)),
                    ),
                    child: const Icon(Icons.notifications_outlined, size: 20, color: AppColors.textSecondary),
                  ),
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: AppColors.danger,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('3', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Harcama Ekle Butonu
          GestureDetector(
            onTap: () => context.push('/add-expense'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.add_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Harcama Ekle',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  MOBİL BOTTOM NAV
// ═══════════════════════════════════════════════════════════

class _MobileBottomNav extends StatelessWidget {
  final String currentPath;

  const _MobileBottomNav({required this.currentPath});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MobileNavItem(
                icon: Icons.home_rounded,
                label: 'Ana Sayfa',
                path: '/',
                currentPath: currentPath,
              ),
              _MobileNavItem(
                icon: Icons.group_rounded,
                label: 'Gruplar',
                path: '/groups',
                currentPath: currentPath,
              ),
              const SizedBox(width: 60),
              _MobileNavItem(
                icon: Icons.payment_rounded,
                label: 'Ödemeler',
                path: '/payments',
                currentPath: currentPath,
              ),
              _MobileNavItem(
                icon: Icons.person_rounded,
                label: 'Profil',
                path: '/profile',
                currentPath: currentPath,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String path;
  final String currentPath;

  const _MobileNavItem({
    required this.icon,
    required this.label,
    required this.path,
    required this.currentPath,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = path == '/' ? currentPath == '/' : currentPath.startsWith(path);

    return GestureDetector(
      onTap: () => context.go(path),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 22, color: isSelected ? AppColors.primary : AppColors.textTertiary),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
