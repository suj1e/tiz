import 'package:flutter/material.dart';
import '../models/todo_item.dart';

class TodoListItem extends StatelessWidget {
  final TodoItem todo;
  final VoidCallback onTap;

  const TodoListItem({
    super.key,
    required this.todo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: todo.isDone
              ? theme.colorScheme.surface.withOpacity(0.3)
              : theme.colorScheme.surface.withOpacity(0.5),
          border: Border.all(
            color: todo.isDone
                ? Colors.transparent
                : theme.colorScheme.outline.withOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: todo.isDone
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withOpacity(0.5),
                  width: 2,
                ),
                color: todo.isDone ? theme.colorScheme.primary : null,
              ),
              child: todo.isDone
                  ? Icon(
                      Icons.check,
                      size: 12,
                      color: theme.colorScheme.onPrimary,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            // Text
            Expanded(
              child: Text(
                todo.text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  decoration:
                      todo.isDone ? TextDecoration.lineThrough : null,
                  color: todo.isDone
                      ? theme.colorScheme.onSurface.withOpacity(0.5)
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
