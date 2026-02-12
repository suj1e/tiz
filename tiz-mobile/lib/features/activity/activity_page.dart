import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../activity/providers/activity_provider.dart';
import '../../activity/widgets/widgets.dart';
import '../../widgets/common/app_card.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  @override
  void initState() {
    super.initState();
    // Initialize activity provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Consumer<ActivityProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '动态',
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '记录成长的每一步',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Want to do section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('💭', style: TextStyle(fontSize: 18)),
                              const SizedBox(width: 10),
                              Text(
                                '最近想做',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Todo list
                          ...provider.todos.map((todo) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: TodoListItem(
                                  todo: todo,
                                  onTap: () => provider.toggleTodo(todo.id),
                                ),
                              )),
                          const SizedBox(height: 8),
                          // Add button
                          _buildAddButton(context, provider),
                        ],
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // Activity feed
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        // Achievement card at top
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: AchievementCardWidget(
                              stats: provider.todayStats,
                              streakDays: provider.streakDays,
                            ),
                          );
                        }

                        // Activity cards
                        final activityIndex = index - 1;
                        if (activityIndex < provider.activities.length) {
                          final activity = provider.activities[activityIndex];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ActivityCardWidget(activity: activity),
                          );
                        }

                        return null;
                      },
                      childCount: provider.activities.length + 1,
                    ),
                  ),
                ),

                // Bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, ActivityProvider provider) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _showAddTodoDialog(context, provider),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.3),
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              size: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 8),
            Text(
              '添加想做的事',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTodoDialog(BuildContext context, ActivityProvider provider) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加想做的事'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '输入你想做的事情...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                provider.addTodo(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }
}
