import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/theme/app_colors.dart';
import '../common/widgets/status_badge.dart';
import '../core/database/database.dart';
import '../core/database/transit/transit_status.dart';
import '../features/transit/controllers/transit_history_provider.dart';

enum CommuteHistoryAction { adjustStartTime, deleteCommute }
enum HistorySegmentAction { editBoardTime, editAlightTime }

class TransitLogsPage extends ConsumerWidget {
  const TransitLogsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(transitHistoryProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Commute history'),
        actions: [
          IconButton(
            tooltip: 'Refresh history',
            onPressed: () => ref.invalidate(transitHistoryProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: history.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => HistoryError(
          message: 'Could not load commute history: $error',
          onRetry: () => ref.invalidate(transitHistoryProvider)
        ),
        data: (entries) {
          if (entries.isEmpty) return const NoHistory();
          final groups = _groupByDate(entries);
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(transitHistoryProvider),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final group in groups.entries)
                  DateGroup(date: group.key, entries: group.value)
              ]
            )
          );
        }
      )
    );
  }

  static Map<DateTime, List<TransitHistoryEntry>> _groupByDate(
    List<TransitHistoryEntry> entries,
  ) {
    final grouped = <DateTime, List<TransitHistoryEntry>>{};
    for (final entry in entries) {
      final date = entry.log.startedAt;
      final key = DateTime(date.year, date.month, date.day);
      grouped.putIfAbsent(key, () => []).add(entry);
    }
    return grouped;
  }
}

class DateGroup extends StatelessWidget {
  const DateGroup({super.key, required this.date, required this.entries});

  final DateTime date;
  final List<TransitHistoryEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: ExpansionTile(
          initiallyExpanded: true,
          title: Text(
            formatDate(date),
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            '${entries.length} ${entries.length == 1 ? 'commute' : 'commutes'}'
          ),
          children: [
            for (final entry in entries) CommuteHistoryTile(entry: entry)
          ]
        )
      )
    );
  }
}

class CommuteHistoryTile extends ConsumerWidget {
  const CommuteHistoryTile({super.key, required this.entry});

  final TransitHistoryEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final log = entry.log;
    final statusColor = log.status == 'completed'
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.error;
    return ExpansionTile(
      leading: Icon(
        log.status == 'completed' ? Icons.check_circle_outline : Icons.cancel,
        color: statusColor,
      ),
      title: Text(
        entry.scheduleName ?? 'Deleted schedule',
        maxLines: 1,
        overflow: TextOverflow.ellipsis
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 4,
          children: [
            TimeBadge(
              label: 'Started ${formatTime(log.startedAt)}',
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer
            ),
            Text(
              '· ${labelStatus(log.status)}'
              '${log.totalDurationMinutes == null ? '' : ' · ${log.totalDurationMinutes} min'}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            )
          ]
        )
      ),
      trailing: PopupMenuButton<CommuteHistoryAction>(
        icon: const Icon(Icons.more_vert, size: 20),
        tooltip: 'Commute options',
        padding: EdgeInsets.zero,
        onSelected: (action) {
          switch (action) {
            case CommuteHistoryAction.adjustStartTime:
              adjustCommuteStartTime(
                context: context,
                ref: ref,
                log: log
              );
              break;
            case CommuteHistoryAction.deleteCommute:
              confirmDeleteCommute(
                context: context,
                ref: ref,
                entry: entry
              );
              break;
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: CommuteHistoryAction.adjustStartTime,
            child: ListTile(
              leading: Icon(Icons.access_time),
              title: Text('Adjust start time'),
              contentPadding: EdgeInsets.zero
            )
          ),
          PopupMenuItem(
            value: CommuteHistoryAction.deleteCommute,
            child: ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'Delete commute',
                style: TextStyle(color: Theme.of(context).colorScheme.error)
              ),
              contentPadding: EdgeInsets.zero
            )
          )
        ]
      ),
      children: entry.segments.isEmpty
          ? const [
              Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('No segment details were saved.')
                )
              )
            ]
          : [
              for (final segment in entry.segments)
                HistorySegmentRow(segment: segment)
            ]
    );
  }

  Future<void> adjustCommuteStartTime({
    required BuildContext context,
    required WidgetRef ref,
    required TransitLog log
  }) async {
    final initialDateTime = log.startedAt;
    final initialTime = TimeOfDay.fromDateTime(initialDateTime);

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime
    );
    if (picked == null || !context.mounted) return;

    final newDateTime = DateTime(
      initialDateTime.year,
      initialDateTime.month,
      initialDateTime.day,
      picked.hour,
      picked.minute
    );

    try {
      await ref
          .read(transitHistoryControllerProvider.notifier)
          .updateCommuteStartedAt(log.id, newDateTime);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString()))
        );
      }
    }
  }

  Future<void> confirmDeleteCommute({
    required BuildContext context,
    required WidgetRef ref,
    required TransitHistoryEntry entry,
  }) async {
    final scheduleName = entry.scheduleName ?? 'this commute';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete commute history?'),
        content: Text(
          'Delete the history for "$scheduleName" on ${formatDate(entry.log.startedAt)}? This action cannot be undone.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel')
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete')
          )
        ]
      )
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ref
          .read(transitHistoryControllerProvider.notifier)
          .deleteCommute(entry.log.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Commute history deleted'))
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString()))
        );
      }
    }
  }
}

class HistorySegmentRow extends ConsumerWidget {
  const HistorySegmentRow({
    super.key,
    required this.segment
  });

  final TransitHistorySegment segment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final log = segment.log;
    final actual = log.actualDurationMinutes;
    final estimate = segment.estimatedDurationMinutes;
    final comparison = actual == null || estimate == null
        ? null
        : actual - estimate;
    final boardedAt = log.boardedAt;
    final alightedAt = log.alightedAt;
    final hasMenu = boardedAt != null || alightedAt != null;
    final colorScheme = Theme.of(context).colorScheme;

    final circleColor = switch (log.status) {
      SegmentLogStatus.completed => colorScheme.primary,
      SegmentLogStatus.inTransit => colorScheme.tertiary,
      SegmentLogStatus.skipped => colorScheme.outline,
      _ => colorScheme.outlineVariant
    };

    String durationText;
    if (actual != null && estimate != null) {
      durationText = 'Actual $actual min · Estimated $estimate min';
    } else if (actual != null) {
      durationText = 'Actual $actual min';
    } else if (estimate != null) {
      durationText = 'Estimated $estimate min';
    } else {
      durationText = 'No duration recorded';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 6, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1 Col 1: circle color {base on transit status}
          SizedBox(
            height: 24,
            child: Center(
              child: Icon(
                Icons.circle,
                size: 9,
                color: circleColor
              )
            )
          ),
          const SizedBox(width: 10),
          // Col 2: Content details across 4 rows
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1 Col 2: segment icon based on segment type, segment name & Row 1 Col 3: action/menu button (3 dots vertical)
                SizedBox(
                  height: 24,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        AppColors.transportModeIcon(log.transportMode),
                        size: 16,
                        color: AppColors.transportModeColor(log.transportMode)
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          log.segmentName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600)
                        )
                      ),
                      if (hasMenu)
                        PopupMenuButton<HistorySegmentAction>(
                          tooltip: 'Segment options',
                          padding: EdgeInsets.zero,
                          child: const Icon(Icons.more_vert, size: 20),
                          onSelected: (action) {
                            switch (action) {
                              case HistorySegmentAction.editBoardTime:
                                adjustTimestamp(
                                  context: context,
                                  ref: ref,
                                  segmentLog: log,
                                  isBoard: true
                                );
                                break;
                              case HistorySegmentAction.editAlightTime:
                                adjustTimestamp(
                                  context: context,
                                  ref: ref,
                                  segmentLog: log,
                                  isBoard: false
                                );
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            if (boardedAt != null)
                              const PopupMenuItem(
                                value: HistorySegmentAction.editBoardTime,
                                child: ListTile(
                                  leading: Icon(Icons.access_time),
                                  title: Text('Adjust board time'),
                                  contentPadding: EdgeInsets.zero
                                )
                              ),
                            if (alightedAt != null)
                              const PopupMenuItem(
                                value: HistorySegmentAction.editAlightTime,
                                child: ListTile(
                                  leading: Icon(Icons.access_time_filled),
                                  title: Text('Adjust alight time'),
                                  contentPadding: EdgeInsets.zero
                                )
                              )
                          ]
                        )
                    ]
                  )
                ),
                const SizedBox(height: 3),
                // Row 2 Col 2: transit status word, transit type
                Text(
                  '${labelStatus(log.status)} · ${labelMode(log.transportMode)}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant
                  )
                ),
                const SizedBox(height: 3),
                // Row 3 Col 2: actual time, estimated time
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        durationText,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant
                        )
                      )
                    ),
                    if (comparison != null)
                      Text(
                        comparison == 0
                            ? 'On time'
                            : '${comparison > 0 ? '+' : ''}$comparison min',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: comparison <= 0
                              ? colorScheme.primary
                              : colorScheme.error,
                          fontWeight: FontWeight.w600
                        )
                      )
                  ]
                ),
                // Row 4 Col 2: board and alighted time in a single badge
                if (boardedAt != null || alightedAt != null) ...[
                  const SizedBox(height: 6),
                  TimeBadge(
                    label: formatBoardAlight(boardedAt, alightedAt)
                  )
                ]
              ]
            )
          )
        ]
      )
    );
  }

  Future<void> adjustTimestamp({
    required BuildContext context,
    required WidgetRef ref,
    required TransitSegmentLog segmentLog,
    required bool isBoard
  }) async {
    final current = isBoard ? segmentLog.boardedAt : segmentLog.alightedAt;
    final initialDateTime = current ?? DateTime.now();
    final initialTime = TimeOfDay.fromDateTime(initialDateTime);

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime
    );
    if (picked == null || !context.mounted) return;

    final newDateTime = DateTime(
      initialDateTime.year,
      initialDateTime.month,
      initialDateTime.day,
      picked.hour,
      picked.minute
    );

    try {
      await ref
          .read(transitHistoryControllerProvider.notifier)
          .updateSegmentTimestamps(
            segmentLog.id,
            boardedAt: isBoard ? newDateTime : null,
            alightedAt: !isBoard ? newDateTime : null
          );
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString()))
        );
      }
    }
  }
}

class NoHistory extends StatelessWidget {
  const NoHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history, size: 56),
            const SizedBox(height: 12),
            Text(
              'No commute history yet',
              style: Theme.of(context).textTheme.titleLarge
            ),
            const SizedBox(height: 8),
            const Text('Completed and cancelled commutes will appear here.')
          ]
        )
      )
    );
  }
}

class HistoryError extends StatelessWidget {
  const HistoryError({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry'))
          ]
        )
      )
    );
  }
}

String labelMode(String mode) => mode.isEmpty ? 'Other' : '${mode[0].toUpperCase()}${mode.substring(1)}';

String labelStatus(String status) {
  if (status.isEmpty) return 'Unknown';
  return '${status[0].toUpperCase()}${status.substring(1)}';
}

String formatTime(DateTime time) {
  final local = time.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  return '$hour:${local.minute.toString().padLeft(2, '0')} '
      '${local.hour < 12 ? 'AM' : 'PM'}';
}

String formatBoardAlight(DateTime? boardedAt, DateTime? alightedAt) {
  if (boardedAt != null && alightedAt != null) {
    return 'Boarded ${formatTime(boardedAt)} · Alighted ${formatTime(alightedAt)}';
  } else if (boardedAt != null) {
    return 'Boarded ${formatTime(boardedAt)}';
  } else if (alightedAt != null) {
    return 'Alighted ${formatTime(alightedAt)}';
  }
  return '';
}

String formatDate(DateTime date) {
  const weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);
  if (date == todayDate) return 'Today';
  if (date == todayDate.subtract(const Duration(days: 1))) return 'Yesterday';
  return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
}
