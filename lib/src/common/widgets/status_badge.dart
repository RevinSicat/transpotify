import 'package:flutter/material.dart';

class TimeBadge extends StatelessWidget {
  const TimeBadge({
    required this.label,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    super.key
  });

  final String label;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final bg = backgroundColor ?? colors.surfaceContainerHighest;
    final fg = foregroundColor ?? colors.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12)
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4)
          ],
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600
            )
          )
        ]
      )
    );
  }
}
