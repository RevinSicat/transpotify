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
            // Row 1: Active badge, Schedule card menu
            Row(
              children: [
                // Active badge
                ScheduleStatusBadge(isActive: data.isActive),
                const Spacer(),
                // Schedule card menu
                PopupMenuButton<ScheduleCardAction>(
                  tooltip: 'Schedule options',
                  onSelected: onActionSelected,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: ScheduleCardAction.edit,
                      child: Text('Edit schedule')
                    ),
                    PopupMenuItem(
                      value: data.isActive
                          ? ScheduleCardAction.deactivate
                          : ScheduleCardAction.activate,
                      child: Text(
                        data.isActive
                            ? 'Deactivate schedule'
                            : 'Activate schedule',
                      )
                    ),
                    PopupMenuItem(
                      value: ScheduleCardAction.delete,
                      child: Text(
                        'Delete schedule',
                        style: TextStyle(color: colors.error)
                      )
                    )
                  ]
                )
              ]
            ),
            const SizedBox(height: 8),
            // Row 2: Schedule title, Commute summary
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Schedule title
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12, top: 2),
                    child: Text(
                      data.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700
                      )
                    )
                  )
                ),
                // Commute summary
                CommuteSummary(variance: variance)
              ]
            ),
            const SizedBox(height: 16),
            // Row 3: Schedule start and end time
            Row(
              children: [
                // Schedule start and end time
                Icon(Icons.schedule, size: 18, color: colors.primary),
                const SizedBox(width: 8),
                Text(
                  '${formatTime(data.targetStartTime)}  →  '
                  '${formatTime(data.targetArrivalTime)}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600
                  )
                )
              ]
            ),
            const SizedBox(height: 12),
            // Row 4: Schedule day labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // Schedule for each day labels
              children: dayLabels(data.daysOfWeek)
                  .map(
                    (day) => DayBadge(
                      label: day.label,
                      isScheduled: day.isScheduled
                    ),
                  )
                  .toList()
            ),
            const SizedBox(height: 8),
            // Row 5: Schedule Action Button
            FilledButton.icon(
              onPressed: data.isActive || isCurrentCommute
                  ? () => onCommutePressed(data.id)
                  : null,
              icon: Icon(
                isCurrentCommute ? Icons.play_arrow : Icons.directions_transit
              ),
              label: Text(
                isCurrentCommute ? 'Resume Active Commute' : 'Start Commute'
              )
            )
          ]
        )
      )
    );
  }

  static String formatTime(String time) {
    return CommonUtilities.formatMinutesFromMidnight(
      CommonUtilities.parseHHmmToMinutes(time)
    );
  }

  static List<({String label, bool isScheduled})> dayLabels(List<int> days) {
    const labels = ['Mn', 'Tu', 'Wd', 'Th', 'Fr', 'Sa', 'Su'];
    return [
      for (var day = 1; day <= labels.length; day++)
        (label: labels[day - 1], isScheduled: days.contains(day)),
    ];
  }
}

// Schedule Status Badge ==========================================================================
class ScheduleStatusBadge extends StatelessWidget {
  const ScheduleStatusBadge({required this.isActive});

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
        borderRadius: BorderRadius.circular(20)
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: foreground, fontWeight: FontWeight.w600)
      )
    );
  }
}

// Commute Summary ================================================================================
class CommuteSummary extends StatelessWidget {
  const CommuteSummary({required this.variance});

  final DurationVariance variance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final average = variance.averageMinutes;
    final averageText = average == null
        ? 'No average yet'
        : 'Avg. ${formatDuration(average.round())}';
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
              fontWeight: FontWeight.w700
            )
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
                    : colors.primary
              )
            )
          )
        ]
      )
    );
  }

  static String formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (hours == 0) return '$remainingMinutes min';
    if (remainingMinutes == 0) return '${hours}h';
    return '${hours}h ${remainingMinutes}m';
  }
}

// Day Badge ======================================================================================
class DayBadge extends StatelessWidget {
  const DayBadge({required this.label, required this.isScheduled});

  final String label;
  final bool isScheduled;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minWidth: 32),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: isScheduled
            ? colors.primaryContainer
            : colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12)
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: isScheduled
              ? colors.onPrimaryContainer
              : colors.onSurfaceVariant,
          fontWeight: FontWeight.bold
        )
      )
    );
  }
}
