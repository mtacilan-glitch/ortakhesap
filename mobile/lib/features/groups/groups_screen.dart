import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/groups_provider.dart';
import 'widgets/create_group_sheet.dart';

/// Gruplar Listesi Ekranı
/// Kullanıcının tüm gruplarını gösterir.
class GroupsScreen extends ConsumerWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(groupsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Gruplarım',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              useRootNavigator: true,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => const CreateGroupSheet(),
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(Icons.add_rounded, color: Colors.white, size: 22),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            groupsAsync.when(
              data: (groups) {
                if (groups.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: Text(
                          'Henüz bir gruba üye değilsiniz.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final group = groups[index];
                      final isPositive = group.netBalance >= 0;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                        child: GestureDetector(
                          onTap: () => context.push('/groups/${group.id}'),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.shadow,
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: Text(group.iconEmoji, style: const TextStyle(fontSize: 28)),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        group.name,
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${group.members.length} üye • ₺${group.totalExpenses.toStringAsFixed(0)} toplam',
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 13,
                                          color: AppColors.textTertiary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isPositive
                                        ? AppColors.credit.withOpacity(0.1)
                                        : AppColors.debit.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${isPositive ? '+' : '-'}₺${group.netBalance.abs().toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: isPositive ? AppColors.credit : AppColors.debit,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: groups.length,
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => SliverToBoxAdapter(
                child: Center(child: Text('Hata: $err')),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}
