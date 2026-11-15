import 'package:material_ui/material_ui.dart';

/// صفحه خالی: وقتی چیزی برای نمایش نیست، یک آیکون و پیام نشان می‌دهد.
/// اگر actionLabel و onAction داده شوند، یک دکمه هم نمایش داده می‌شود.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final label = actionLabel;
    final action = onAction;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (label != null && action != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: action,
                icon: const Icon(Icons.person_add_alt_1),
                label: Text(label),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
