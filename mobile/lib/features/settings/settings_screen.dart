import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _autoSplit = true;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 900;
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FD),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 32 : 16,
              vertical: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Ayarlar',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1D2E),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Hesap ayarlarınızı ve tercihlerinizi yönetin',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 32),

                // Settings Cards
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: isWide ? 2 : 1,
                      child: Column(
                        children: [
                          // Profile Section
                          _buildCard(
                            title: 'Profil Bilgileri',
                            child: Row(
                              children: [
                                Container(
                                  height: 60,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    (currentUser?.name ?? 'U')[0].toUpperCase(),
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        currentUser?.name ?? 'Kullanıcı',
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1A1D2E),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        currentUser?.email ?? 'email@email.com',
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 14,
                                          color: AppColors.textTertiary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: currentUser?.isPremium == true
                                        ? const Color(0xFFFFF8E6)
                                        : const Color(0xFFF0F0FA),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    currentUser?.isPremium == true ? 'Premium' : 'Standart',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: currentUser?.isPremium == true
                                          ? const Color(0xFFFFB800)
                                          : AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Notification Tercihleri
                          _buildCard(
                            title: 'Bildirim Tercihleri',
                            child: Column(
                              children: [
                                _buildSwitchTile(
                                  title: 'Mobil Bildirimleri',
                                  subtitle: 'Harcama eklendiğinde ve ödeme hatırlatıldığında bildirim al',
                                  value: _pushNotifications,
                                  onChanged: (val) => setState(() => _pushNotifications = val),
                                ),
                                const Divider(height: 24, color: Color(0xFFF2F2F7)),
                                _buildSwitchTile(
                                  title: 'E-posta Bildirimleri',
                                  subtitle: 'Haftalık özet raporları e-posta ile al',
                                  value: _emailNotifications,
                                  onChanged: (val) => setState(() => _emailNotifications = val),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Kolaylık Ayarları
                          _buildCard(
                            title: 'Genel Ayarlar',
                            child: Column(
                              children: [
                                _buildSwitchTile(
                                  title: 'Otomatik Borç Sadeleştirme',
                                  subtitle: 'Grup içindeki borçları otomatik olarak en az transfere indirge',
                                  value: _autoSplit,
                                  onChanged: (val) => setState(() => _autoSplit = val),
                                ),
                                const Divider(height: 24, color: Color(0xFFF2F2F7)),
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text(
                                    'IBAN Numarası',
                                    style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A1D2E)),
                                  ),
                                  subtitle: Text(
                                    currentUser?.ibanNumber ?? 'IBAN Girilmemiş',
                                    style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.textTertiary),
                                  ),
                                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
                                  onTap: () => context.push('/profile'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isWide) ...[
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 1,
                        child: _buildCard(
                          title: 'Oturum İşlemleri',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Hesabınızdan güvenli bir şekilde çıkış yapabilir veya şifrenizi güncelleyebilirsiniz.',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  color: AppColors.textTertiary,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: () {
                                  ref.read(authProvider.notifier).logout();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFEBEB),
                                  foregroundColor: AppColors.danger,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Çıkış Yap',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (!isWide) ...[
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(authProvider.notifier).logout();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFEBEB),
                      foregroundColor: AppColors.danger,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Çıkış Yap',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
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

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1D2E),
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1D2E),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          color: AppColors.textTertiary,
        ),
      ),
      value: value,
      activeColor: AppColors.primary,
      onChanged: onChanged,
    );
  }
}
