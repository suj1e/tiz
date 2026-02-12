import 'package:flutter/material.dart';
import '../models/activity_card.dart';

class ActivityCardWidget extends StatelessWidget {
  final ActivityCard activity;

  const ActivityCardWidget({
    super.key,
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAchievement = activity.type == ActivityType.achievement;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isAchievement
            ? LinearGradient(
                colors: [
                  theme.colorScheme.primary.withOpacity(0.15),
                  theme.colorScheme.secondary.withOpacity(0.1),
                ],
              )
            : null,
        color: isAchievement
            ? null
            : theme.colorScheme.surface.withOpacity(0.5),
        border: Border.all(
          color: isAchievement
              ? theme.colorScheme.secondary.withOpacity(0.3)
              : theme.colorScheme.outline.withOpacity(0.1),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                activity.icon,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  activity.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (activity.description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              activity.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
          const SizedBox(height: 10),
          // Time
          Text(
            activity.timeAgo,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget for achievement card showing daily stats
class AchievementCardWidget extends StatelessWidget {
  final Map<String, int> stats;
  final int streakDays;

  const AchievementCardWidget({
    super.key,
    required this.stats,
    required this.streakDays,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.15),
            theme.colorScheme.secondary.withOpacity(0.1),
          ],
        ),
        border: Border.all(
          color: theme.colorScheme.secondary.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('✨', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Text(
                '今日小成就',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              if ((stats['translations'] ?? 0) > 0)
                _buildStatItem('📝', '翻译${stats['translations']}次'),
              if ((stats['chats'] ?? 0) > 0)
                _buildStatItem('💬', '对话${stats['chats']}次'),
              if ((stats['goalsCompleted'] ?? 0) > 0)
                _buildStatItem('🎯', '完成${stats['goalsCompleted']}个'),
              if (streakDays > 0)
                _buildStatItem('🔥', '连续${streakDays}天'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String emoji, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
