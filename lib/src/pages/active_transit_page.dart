import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../common/theme/app_colors.dart';
import '../common/widgets/status_badge.dart';
import '../core/database/database.dart';
import '../core/database/transit/transit_status.dart';
import '../features/schedule/controllers/schedule_controller.dart';
import '../features/transit/controllers/active_transit_controller.dart';
import '../features/transit/controllers/transit_history_provider.dart';

enum ActiveCommuteMenuAction { adjustStartTime, reset, cancel }
enum SegmentAction { undoBoard, resetSegment, editBoardTime, editAlightTime }

class ActiveTransitPage extends ConsumerWidget {
  const ActiveTransitPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTransit = ref.watch(activeTransitProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active commute'),
        actions: [
          if (activeTransit.asData?.value != null)
            PopupMenuButton<ActiveCommuteMenuAction>(
              tooltip: 'Commute options',
              icon: const Icon(Icons.more_vert),
              onSelected: (action) {
                final log = activeTransit.asData!.value!.log;
                switch (action) {
                  case ActiveCommuteMenuAction.adjustStartTime:
                    adjustCommuteStartTime(
                      context,
                      ref,
                      log.id,
                      log.startedAt
                    );
                    break;
                  case ActiveCommuteMenuAction.reset:
                    resetCommute(context, ref, log.id);
                    break;
                  case ActiveCommuteMenuAction.cancel:
                    cancelCommute(context, ref, log.id);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: ActiveCommuteMenuAction.adjustStartTime,
                  child: ListTile(
                    leading: Icon(Icons.access_time),
                    title: Text('Adjust start time'),
                    contentPadding: EdgeInsets.zero
                  )
                ),
                const PopupMenuItem(
                  value: ActiveCommuteMenuAction.reset,
                  child: ListTile(
                    leading: Icon(Icons.restart_alt),
                    title: Text('Reset commute'),
                    contentPadding: EdgeInsets.zero
                  )
                ),
                const PopupMenuItem(
                  value: ActiveCommuteMenuAction.cancel,
                  child: ListTile(
                    leading: Icon(Icons.close),
                    title: Text('Cancel commute'),
                    contentPadding: EdgeInsets.zero
                  )
                )
              ]
            )
        ]
      ),
      body: activeTransit.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            ErrorState(message: 'Could not load commute: $error'),
        data: (transit) {
          if (transit == null) return const NoActiveCommute();
          final pendingOrInTransit = transit.segments.where(
            (segment) =>
                segment.status == SegmentLogStatus.pending ||
                segment.status == SegmentLogStatus.inTransit
          );
          final current = pendingOrInTransit.isEmpty
              ? null
              : pendingOrInTransit.first;
          final isBoarding = current?.status == SegmentLogStatus.pending;
          final isAlighting = current?.status == SegmentLogStatus.inTransit;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: [
              CommuteHeader(
                scheduleId: transit.log.scheduleId,
                startedAt: transit.log.startedAt,
                segments: transit.segments.length
              ),
              const SizedBox(height: 18),
              if (current != null) ...[
                Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          isBoarding ? 'Next segment' : 'Currently in transit',
                          style: Theme.of(context).textTheme.labelLarge
                        ),
                        const SizedBox(height: 8),
                        Text(
                          current.segmentName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700)
                        ),
                        const SizedBox(height: 4),
                        Text(
                          labelMode(current.transportMode),
                          style: Theme.of(context).textTheme.bodyMedium
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => runAction(
                            context,
                            ref,
                            isAlighting
                                ? () => ref
                                      .read(
                                        activeTransitControllerProvider
                                            .notifier,
                                      )
                                      .alightSegment(current.id)
                                : () => ref
                                      .read(
                                        activeTransitControllerProvider
                                            .notifier,
                                      )
                                      .boardSegment(current.id)
                          ),
                          icon: Icon(
                            isAlighting
                                ? Icons.flag_outlined
                                : AppColors.transportModeIcon(
                                    current.transportMode,
                                  )
                          ),
                          label: Text(
                            isAlighting
                                ? 'Alight ${labelMode(current.transportMode)}'
                                : 'Board ${labelMode(current.transportMode)}'
                          )
                        ),
                        if (isAlighting) ...[
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () => runAction(
                              context,
                              ref,
                              () => ref.read(
                                  activeTransitControllerProvider.notifier
                              ).undoBoardSegment(current.id)
                            ),
                            icon: const Icon(Icons.undo),
                            label: const Text('Undo board')
                          )
                        ],
                        if (isBoarding) ...[
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => runAction(
                              context,
                              ref,
                              () => ref.read(
                                  activeTransitControllerProvider.notifier
                              ).skipSegment(current.id)
                            ),
                            child: const Text('Skip this segment')
                          )
                        ]
                      ]
                    )
                  )
                )
              ] else ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        const Icon(Icons.check_circle_outline, size: 44),
                        const SizedBox(height: 8),
                        Text(
                          'All segments finished',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: () async {
                            final completed = await runAction(
                              context,
                              ref,
                              () => ref
                                  .read(
                                    activeTransitControllerProvider.notifier,
                                  )
                                  .completeCommute(transit.log.id),
                            );
                            if (!completed) return;
                            ref.invalidate(transitHistoryProvider);
                            if (context.mounted) context.go('/logs');
                          },
                          icon: const Icon(Icons.check),
                          label: const Text('Complete commute')
                        )
                      ]
                    )
                  )
                )
              ],
              const SizedBox(height: 20),
              Text(
                'Route progress',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700)
              ),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    children: [
                      for (
                        var index = 0;
                        index < transit.segments.length;
                        index++
                      )
                        TimelineRow(
                          segment: transit.segments[index],
                          isLast: index == transit.segments.length - 1
                        )
                    ]
                  )
                )
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => context.go('/schedules'),
                icon: const Icon(Icons.edit_road),
                label: const Text('View schedules')
              )
            ]
          );
        }
      )
    );
  }

  Future<bool> runAction(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() action,
  ) async {
    try {
      await action();
      return true;
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
      return false;
    }
  }

  Future<void> resetCommute(
    BuildContext context,
    WidgetRef ref,
    int transitLogId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset this commute?'),
        content: const Text(
          'All segment timestamps and progress will be reset to unstarted. The commute remains active.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep progress')
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset commute')
          )
        ]
      )
    );
    if (confirmed != true || !context.mounted) return;
    await runAction(
      context,
      ref,
      () => ref.read(activeTransitControllerProvider.notifier)
        .resetCommute(transitLogId)
    );
  }

  Future<void> cancelCommute(
    BuildContext context,
    WidgetRef ref,
    int transitLogId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel this commute?'),
        content: const Text(
          'The commute will be saved as cancelled. Completed segments remain in your history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep going')
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel commute')
          )
        ]
      )
    );
    if (confirmed != true || !context.mounted) return;
    await runAction(
      context,
      ref,
      () => ref
          .read(activeTransitControllerProvider.notifier)
          .cancelCommute(transitLogId),
    );
  }
}

class CommuteHeader extends ConsumerWidget {
  const CommuteHeader({
    super.key,
    required this.scheduleId,
    required this.startedAt,
    required this.segments
  });

  final int? scheduleId;
  final DateTime startedAt;
  final int segments;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedule = scheduleId == null
        ? null
        : ref.watch(scheduleByIdProvider(scheduleId!));
    final scheduleName = schedule?.asData?.value?.name ?? 'Commute';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          scheduleName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700)
        ),
        const SizedBox(height: 6),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            TimeBadge(
              label: 'Started ${formatTime(startedAt)}',
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer
            ),
            Text(
              '· $segments ${segments == 1 ? 'segment' : 'segments'}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant
              )
            )
          ]
        )
      ]
    );
  }
}

Future<void> adjustCommuteStartTime(
  BuildContext context,
  WidgetRef ref,
  int transitLogId,
  DateTime currentStartedAt
) async {
  final initialTime = TimeOfDay.fromDateTime(currentStartedAt);
  final picked = await showTimePicker(
    context: context,
    initialTime: initialTime,
  );
  if (picked == null || !context.mounted) return;

  final newDateTime = DateTime(
    currentStartedAt.year,
    currentStartedAt.month,
    currentStartedAt.day,
    picked.hour,
    picked.minute
  );

  try {
    await ref
        .read(activeTransitControllerProvider.notifier)
        .updateCommuteStartedAt(transitLogId, newDateTime);
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString()))
      );
    }
  }
}

class TimelineRow extends ConsumerWidget {
  const TimelineRow({
    super.key,
    required this.segment,
    required this.isLast
  });

  final TransitSegmentLog segment;
  final bool isLast;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = segment.status;
    final mode = segment.transportMode;
    final name = segment.segmentName;
    final boardedAt = segment.boardedAt;
    final alightedAt = segment.alightedAt;
    final isDone = status == SegmentLogStatus.completed;
    final isSkipped = status == SegmentLogStatus.skipped;
    final isInTransit = status == SegmentLogStatus.inTransit;
    final colorScheme = Theme.of(context).colorScheme;
    final modeColor = AppColors.transportModeColor(mode);
    final statusText = switch (status) {
      SegmentLogStatus.completed => 'Completed',
      SegmentLogStatus.inTransit => 'In transit',
      SegmentLogStatus.skipped => 'Skipped',
      _ => 'Upcoming',
    };

    final hasMenu = isInTransit || isDone || isSkipped;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 36,
            child: Column(
              children: [
                SizedBox(
                  height: 24,
                  child: Center(
                    child: Icon(
                      isDone
                          ? Icons.check_circle
                          : isSkipped
                          ? Icons.skip_next
                          : AppColors.transportModeIcon(mode),
                      color: isSkipped
                          ? colorScheme.outline
                          : isDone
                          ? colorScheme.primary
                          : modeColor
                    )
                  )
                ),
                if (!isLast)
                  Container(
                    height: 36,
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: colorScheme.outlineVariant
                  )
              ]
            )
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 16 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 24,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600)
                          )
                        ),
                        if (hasMenu)
                          PopupMenuButton<SegmentAction>(
                            tooltip: 'Segment options',
                            padding: EdgeInsets.zero,
                            child: const Icon(Icons.more_vert, size: 20),
                            onSelected: (action) {
                              switch (action) {
                                case SegmentAction.undoBoard:
                                  ref
                                      .read(activeTransitControllerProvider.notifier)
                                      .undoBoardSegment(segment.id);
                                  break;
                                case SegmentAction.resetSegment:
                                  _confirmResetSegment(context, ref, segment.id);
                                  break;
                                case SegmentAction.editBoardTime:
                                  _adjustTimestamp(
                                    context: context,
                                    ref: ref,
                                    segment: segment,
                                    isBoard: true
                                  );
                                  break;
                                case SegmentAction.editAlightTime:
                                  _adjustTimestamp(
                                    context: context,
                                    ref: ref,
                                    segment: segment,
                                    isBoard: false
                                  );
                                  break;
                              }
                            },
                            itemBuilder: (context) => [
                              if (isInTransit)
                                const PopupMenuItem(
                                  value: SegmentAction.undoBoard,
                                  child: ListTile(
                                    leading: Icon(Icons.undo),
                                    title: Text('Undo board'),
                                    contentPadding: EdgeInsets.zero
                                  )
                                ),
                              if (isDone || isSkipped)
                                const PopupMenuItem(
                                  value: SegmentAction.resetSegment,
                                  child: ListTile(
                                    leading: Icon(Icons.restart_alt),
                                    title: Text('Reset segment'),
                                    contentPadding: EdgeInsets.zero
                                  )
                                ),
                              if (boardedAt != null)
                                const PopupMenuItem(
                                  value: SegmentAction.editBoardTime,
                                  child: ListTile(
                                    leading: Icon(Icons.access_time),
                                    title: Text('Adjust board time'),
                                    contentPadding: EdgeInsets.zero
                                  )
                                ),
                              if (alightedAt != null)
                                const PopupMenuItem(
                                  value: SegmentAction.editAlightTime,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        statusText,
                        style: Theme.of(context).textTheme.labelSmall
                            ?.copyWith(color: colorScheme.onSurfaceVariant)
                      ),
                      if (segment.actualDurationMinutes != null)
                        Text(
                          '${segment.actualDurationMinutes} min',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant)
                        )
                    ]
                  ),
                  if (boardedAt != null || alightedAt != null) ...[
                    const SizedBox(height: 6),
                    TimeBadge(
                      label: formatBoardAlight(boardedAt, alightedAt)
                    )
                  ]
                ]
              )
            )
          )
        ]
      )
    );
  }

  Future<void> _adjustTimestamp({
    required BuildContext context,
    required WidgetRef ref,
    required TransitSegmentLog segment,
    required bool isBoard
  }) async {
    final current = isBoard ? segment.boardedAt : segment.alightedAt;
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
          .read(activeTransitControllerProvider.notifier)
          .updateSegmentTimestamps(
            segment.id,
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

  Future<void> _confirmResetSegment(
    BuildContext context,
    WidgetRef ref,
    int segmentId
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset segment?'),
        content: const Text(
          'This will clear this segment\'s progress and timestamps.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel')
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset')
          )
        ]
      )
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref
          .read(activeTransitControllerProvider.notifier)
          .resetSegment(segmentId);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString()))
        );
      }
    }
  }
}

class NoActiveCommute extends StatelessWidget {
  const NoActiveCommute({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.directions_transit_outlined, size: 56),
            const SizedBox(height: 12),
            Text(
              'No active commute',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text('Choose a schedule to start your next trip.'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go('/'),
              child: const Text('Choose schedule'),
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}

String labelMode(String mode) {
  if (mode.isEmpty) return 'Transit';
  return '${mode[0].toUpperCase()}${mode.substring(1)}';
}

String formatTime(DateTime time) {
  final local = time.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour < 12 ? 'AM' : 'PM';
  return '$hour:$minute $period';
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
