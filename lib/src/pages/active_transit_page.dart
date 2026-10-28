import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../common/theme/app_colors.dart';
import '../core/database/database.dart';
import '../core/database/transit/transit_status.dart';
import '../features/schedule/controllers/schedule_controller.dart';
import '../features/transit/controllers/active_transit_controller.dart';
import '../features/transit/controllers/transit_history_provider.dart';

class ActiveTransitPage extends ConsumerWidget {
  const ActiveTransitPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTransit = ref.watch(activeTransitProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active commute'),
        actions: [
          activeTransit.asData?.value == null
              ? const SizedBox.shrink()
              : IconButton(
                  tooltip: 'Cancel commute',
                  onPressed: () => _cancelCommute(
                    context,
                    ref,
                    activeTransit.asData!.value!.log.id,
                  ),
                  icon: const Icon(Icons.close),
                ),
        ],
      ),
      body: activeTransit.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            _ErrorState(message: 'Could not load commute: $error'),
        data: (transit) {
          if (transit == null) return const _NoActiveCommute();
          final pendingOrInTransit = transit.segments.where(
            (segment) =>
                segment.status == SegmentLogStatus.pending ||
                segment.status == SegmentLogStatus.inTransit,
          );
          final current = pendingOrInTransit.isEmpty
              ? null
              : pendingOrInTransit.first;
          final isBoarding = current?.status == SegmentLogStatus.pending;
          final isAlighting = current?.status == SegmentLogStatus.inTransit;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: [
              _CommuteHeader(
                scheduleId: transit.log.scheduleId,
                startedAt: transit.log.startedAt,
                segments: transit.segments.length,
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
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          current.segmentName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _labelMode(current.transportMode),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => _runAction(
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
                                      .boardSegment(current.id),
                          ),
                          icon: Icon(
                            isAlighting
                                ? Icons.flag_outlined
                                : AppColors.transportModeIcon(
                                    current.transportMode,
                                  ),
                          ),
                          label: Text(
                            isAlighting
                                ? 'Alight ${_labelMode(current.transportMode)}'
                                : 'Board ${_labelMode(current.transportMode)}',
                          ),
                        ),
                        if (isBoarding) ...[
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => _runAction(
                              context,
                              ref,
                              () => ref
                                  .read(
                                    activeTransitControllerProvider.notifier,
                                  )
                                  .skipSegment(current.id),
                            ),
                            child: const Text('Skip this segment'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
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
                            final completed = await _runAction(
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
                          label: const Text('Complete commute'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Text(
                'Route progress',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
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
                        _TimelineRow(
                          segment: transit.segments[index],
                          isLast: index == transit.segments.length - 1,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => context.go('/schedules'),
                icon: const Icon(Icons.edit_road),
                label: const Text('View schedules'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<bool> _runAction(
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

  Future<void> _cancelCommute(
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
            child: const Text('Keep going'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel commute'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await _runAction(
      context,
      ref,
      () => ref
          .read(activeTransitControllerProvider.notifier)
          .cancelCommute(transitLogId),
    );
  }
}

class _CommuteHeader extends ConsumerWidget {
  const _CommuteHeader({
    required this.scheduleId,
    required this.startedAt,
    required this.segments,
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
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'Started ${_formatTime(startedAt)} · $segments '
          '${segments == 1 ? 'segment' : 'segments'}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.segment, required this.isLast});

  final TransitSegmentLog segment;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final status = segment.status;
    final mode = segment.transportMode;
    final name = segment.segmentName;
    final boardedAt = segment.boardedAt;
    final alightedAt = segment.alightedAt;
    final isDone = status == SegmentLogStatus.completed;
    final isSkipped = status == SegmentLogStatus.skipped;
    final colorScheme = Theme.of(context).colorScheme;
    final modeColor = AppColors.transportModeColor(mode);
    final statusText = switch (status) {
      SegmentLogStatus.completed => 'Completed',
      SegmentLogStatus.inTransit => 'In transit',
      SegmentLogStatus.skipped => 'Skipped',
      _ => 'Upcoming',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 36,
            child: Column(
              children: [
                Icon(
                  isDone
                      ? Icons.check_circle
                      : isSkipped
                      ? Icons.skip_next
                      : AppColors.transportModeIcon(mode),
                  color: isSkipped
                      ? colorScheme.outline
                      : isDone
                      ? colorScheme.primary
                      : modeColor,
                ),
                if (!isLast)
                  Container(
                    height: 36,
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: colorScheme.outlineVariant,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 16 : 12, top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    [
                      statusText,
                      if (boardedAt != null)
                        'Boarded ${_formatTime(boardedAt)}',
                      if (alightedAt != null)
                        'Alighted ${_formatTime(alightedAt)}',
                      if (segment.actualDurationMinutes != null)
                        '${segment.actualDurationMinutes} min',
                    ].join(' · '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoActiveCommute extends StatelessWidget {
  const _NoActiveCommute();

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

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

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

String _labelMode(String mode) {
  if (mode.isEmpty) return 'Transit';
  return '${mode[0].toUpperCase()}${mode.substring(1)}';
}

String _formatTime(DateTime time) {
  final local = time.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour < 12 ? 'AM' : 'PM';
  return '$hour:$minute $period';
}
