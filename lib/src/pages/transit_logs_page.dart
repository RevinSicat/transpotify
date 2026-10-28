import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/transit/controllers/transit_history_provider.dart';

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
        error: (error, _) => _HistoryError(
          message: 'Could not load commute history: $error',
          onRetry: () => ref.invalidate(transitHistoryProvider),
        ),
        data: (entries) {
          if (entries.isEmpty) return const _NoHistory();
          final groups = _groupByDate(entries);
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(transitHistoryProvider),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final group in groups.entries)
                  _DateGroup(date: group.key, entries: group.value),
              ],
            ),
          );
        },
      ),
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

class _DateGroup extends StatelessWidget {
  const _DateGroup({required this.date, required this.entries});

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
            _formatDate(date),
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            '${entries.length} ${entries.length == 1 ? 'commute' : 'commutes'}',
          ),
          children: [
            for (final entry in entries) _CommuteHistoryTile(entry: entry),
          ],
        ),
      ),
    );
  }
}

class _CommuteHistoryTile extends StatelessWidget {
  const _CommuteHistoryTile({required this.entry});

  final TransitHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
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
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${_formatTime(log.startedAt)} · ${_labelStatus(log.status)}'
        '${log.totalDurationMinutes == null ? '' : ' · ${log.totalDurationMinutes} min'}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      children: entry.segments.isEmpty
          ? const [
              Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('No segment details were saved.'),
                ),
              ),
            ]
          : [
              for (final segment in entry.segments)
                _HistorySegmentRow(segment: segment),
            ],
    );
  }
}

class _HistorySegmentRow extends StatelessWidget {
  const _HistorySegmentRow({required this.segment});

  final TransitHistorySegment segment;

  @override
  Widget build(BuildContext context) {
    final log = segment.log;
    final actual = log.actualDurationMinutes;
    final estimate = segment.estimatedDurationMinutes;
    final duration = actual == null
        ? _labelStatus(log.status)
        : 'Actual $actual min'
              '${estimate == null ? '' : ' · Estimated $estimate min'}';
    final comparison = actual == null || estimate == null
        ? null
        : actual - estimate;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 20, 12),
      child: Row(
        children: [
          Icon(
            Icons.circle,
            size: 9,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.segmentName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text(
                  '${_labelMode(log.transportMode)} · $duration',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
          if (comparison != null)
            Text(
              comparison == 0
                  ? 'On time'
                  : '${comparison > 0 ? '+' : ''}$comparison min',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: comparison <= 0
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}

class _NoHistory extends StatelessWidget {
  const _NoHistory();

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
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text('Completed and cancelled commutes will appear here.'),
          ],
        ),
      ),
    );
  }
}

class _HistoryError extends StatelessWidget {
  const _HistoryError({required this.message, required this.onRetry});

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
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

String _labelMode(String mode) =>
    mode.isEmpty ? 'Other' : '${mode[0].toUpperCase()}${mode.substring(1)}';

String _labelStatus(String status) {
  if (status.isEmpty) return 'Unknown';
  return '${status[0].toUpperCase()}${status.substring(1)}';
}

String _formatTime(DateTime time) {
  final local = time.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  return '$hour:${local.minute.toString().padLeft(2, '0')} '
      '${local.hour < 12 ? 'AM' : 'PM'}';
}

String _formatDate(DateTime date) {
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
