import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final List<_TaskItem> _tasks = [
    _TaskItem(
      id: '1',
      title: 'Elektrik Faturasını Öde',
      groupName: 'Ev Grubu',
      assignedTo: 'Mehmet Yılmaz',
      dueDate: 'Yarın',
      isCompleted: false,
    ),
    _TaskItem(
      id: '2',
      title: 'Salon Temizliği',
      groupName: 'Ev Grubu',
      assignedTo: 'Can Öztürk',
      dueDate: '05 Haz 2026',
      isCompleted: false,
    ),
    _TaskItem(
      id: '3',
      title: 'Haftalık Market Alışverişi',
      groupName: 'Ev Grubu',
      assignedTo: 'Ayşe Demir',
      dueDate: 'Dün',
      isCompleted: true,
    ),
    _TaskItem(
      id: '4',
      title: 'Otel Rezervasyonu Yap',
      groupName: 'Antalya Tatili',
      assignedTo: 'Mehmet Yılmaz',
      dueDate: '10 Haz 2026',
      isCompleted: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FD),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 32 : 16,
            vertical: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ortak Görevler',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1D2E),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Gruplarınızdaki iş paylaşımını ve görevleri takip edin',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text(
                      'Görev Ekle',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Tasks list
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    final task = _tasks[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Status Checkbox
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                task.isCompleted = !task.isCompleted;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 26,
                              width: 26,
                              decoration: BoxDecoration(
                                color: task.isCompleted ? const Color(0xFFE2F9EE) : Colors.white,
                                border: Border.all(
                                  color: task.isCompleted ? const Color(0xFF34C759) : const Color(0xFFEEEEF5),
                                  width: 2,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: task.isCompleted
                                  ? const Icon(Icons.check_rounded, size: 16, color: Color(0xFF34C759))
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.title,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: task.isCompleted ? AppColors.textTertiary : const Color(0xFF1A1D2E),
                                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF0F0FA),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        task.groupName,
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Sorumlu: ${task.assignedTo}',
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Due date badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: task.dueDate == 'Dün'
                                  ? AppColors.danger.withOpacity(0.1)
                                  : task.dueDate == 'Yarın'
                                      ? AppColors.warning.withOpacity(0.1)
                                      : const Color(0xFFF8F8FD),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              task.dueDate,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: task.dueDate == 'Dün'
                                    ? AppColors.danger
                                    : task.dueDate == 'Yarın'
                                        ? AppColors.warning
                                        : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskItem {
  final String id;
  final String title;
  final String groupName;
  final String assignedTo;
  final String dueDate;
  bool isCompleted;

  _TaskItem({
    required this.id,
    required this.title,
    required this.groupName,
    required this.assignedTo,
    required this.dueDate,
    required this.isCompleted,
  });
}
