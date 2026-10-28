import 'package:flutter/material.dart';

import '../utils/common_utilities.dart';
import '../../core/database/schedule/dao/schedule_dao.dart';

enum ScheduleCardAction { edit, activate, deactivate, delete }

class ScheduleCard extends StatelessWidget {
  const ScheduleCard({
    required this.schedule,
    required this.variance,
    required this.onCommutePressed,
    required this.onActionSelected,
    this.isCurrentCommute = false,
    super.key,
  });

  final ScheduleWithSegments schedule;
  final DurationVariance variance;
  final bool isCurrentCommute;
  final ValueChanged<int> onCommutePressed;
  final ValueChanged<ScheduleCardAction> onActionSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final data = schedule.schedule;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _ScheduleStatusBadge(isActive: data.isActive),
                const Spacer(),
                PopupMenuButton<ScheduleCardAction>(
                  tooltip: 'Schedule options',
                  onSelected: onActionSelected,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: ScheduleCardAction.edit,
                      child: Text('Edit schedule'),
                    ),
                    PopupMenuItem(
                      value: data.isActive
                          ? ScheduleCardAction.deactivate
                          : ScheduleCardAction.activate,
                      child: Text(
                        data.isActive
                            ? 'Deactivate schedule'
                            : 'Activate schedule',
                      ),
                    ),
                    PopupMenuItem(
                      value: ScheduleCardAction.delete,
                      child: Text(
                        'Delete schedule',
                        style: TextStyle(color: colors.error),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12, top: 2),
                    child: Text(
                      data.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                _CommuteSummary(variance: variance),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.schedule, size: 18, color: colors.primary),
                const SizedBox(width: 8),
                Text(
                  '${_formatTime(data.targetStartTime)}  →  '
                  '${_formatTime(data.targetArrivalTime)}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _dayLabels(data.daysOfWeek)
                  .map((day) => _DayBadge(label: day))
                  .toList(),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: data.isActive || isCurrentCommute
                  ? () => onCommutePressed(data.id)
                  : null,
              icon: Icon(
                isCurrentCommute ? Icons.play_arrow : Icons.directions_transit,
              ),
              label: Text(
                isCurrentCommute ? 'Resume Active Commute' : 'Start Commute',
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatTime(String time) {
    return CommonUtilities.formatMinutesFromMidnight(
      CommonUtilities.parseHHmmToMinutes(time),
    );
  }

  static List<String> _dayLabels(List<int> days) {
    const labels = ['Mn', 'Tu', 'Wd', 'Th', 'Fr', 'Sa', 'Su'];
    return [
      for (var day = 1; day <= labels.length; day++)
        if (days.contains(day)) labels[day - 1],
    ];
  }
}

class _ScheduleStatusBadge extends StatelessWidget {
  const _ScheduleStatusBadge({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final background = isActive
        ? colors.primaryContainer
        : colors.surfaceContainerHighest;
    final foreground = isActive
        ? colors.onPrimaryContainer
        : colors.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: foreground, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _CommuteSummary extends StatelessWidget {
  const _CommuteSummary({required this.variance});

  final DurationVariance variance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final average = variance.averageMinutes;
    final averageText = average == null
        ? 'No average yet'
        : 'Avg. ${_formatDuration(average.round())}';
    final varianceText = variance.summary;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 150),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            averageText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Tooltip(
            message: varianceText,
            child: Text(
              varianceText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: theme.textTheme.labelSmall?.copyWith(
                color: average == null
                    ? colors.onSurfaceVariant
                    : colors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (hours == 0) return '$remainingMinutes min';
    if (remainingMinutes == 0) return '${hours}h';
    return '${hours}h ${remainingMinutes}m';
  }
}

class _DayBadge extends StatelessWidget {
  const _DayBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minWidth: 34),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: colors.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
