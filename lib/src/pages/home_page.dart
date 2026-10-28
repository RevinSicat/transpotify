import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../common/utils/common_utilities.dart';
import '../common/widgets/schedule_card.dart';
import '../common/widgets/segment_accordion.dart';
import '../core/database/schedule/dao/schedule_dao.dart';
import '../features/schedule/controllers/schedule_controller.dart';
import '../features/transit/controllers/active_transit_controller.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late final PageController _pageController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.94);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final schedules = ref.watch(schedulesProvider);
    final activeTransit = ref.watch(activeTransitProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transpotify'),
        actions: [
          IconButton(
            tooltip: 'Commute history',
            onPressed: () => context.go('/logs'),
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: schedules.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _LoadError(
          message: 'Could not load schedules: $error',
          onRetry: () => ref.invalidate(schedulesProvider),
        ),
        data: (items) {
          if (items.isEmpty) return const _NoSchedules();
          final index = _selectedIndex.clamp(0, items.length - 1);
          final selected = items[index];
          final activeLog = activeTransit.asData?.value?.log;

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(schedulesProvider);
              ref.invalidate(activeTransitProvider);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              children: [
                Text(
                  CommonUtilities.getGreeting(),
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose a schedule to plan your commute.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: items.length,
                    onPageChanged: (value) {
                      setState(() => _selectedIndex = value);
                    },
                    itemBuilder: (context, cardIndex) {
                      final item = items[cardIndex];
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: _HomeScheduleCard(
                          schedule: item,
                          isCurrentCommute:
                              activeLog?.scheduleId == item.schedule.id,
                          onCommutePressed: () =>
                              _startOrResume(item.schedule.id, activeLog?.id),
                        ),
                      );
                    },
                  ),
                ),
                if (items.length > 1) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var dot = 0; dot < items.length; dot++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: dot == index ? 18 : 7,
                          height: 7,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: dot == index
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outlineVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                Text(
                  'Commute overview',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                _CommuteMetrics(schedule: selected),
                const SizedBox(height: 14),
                _SegmentOverview(schedule: selected),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => context.go('/schedules'),
                  icon: const Icon(Icons.edit_road),
                  label: const Text('Manage schedules'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _startOrResume(int scheduleId, int? activeLogId) async {
    if (activeLogId != null) {
      final active = ref.read(activeTransitProvider).asData?.value;
      if (active?.log.scheduleId != scheduleId) {
        _showError(
          StateError(
            'Finish or cancel the current commute before starting another.',
          ),
        );
        return;
      }
      if (mounted) context.go('/active');
      return;
    }

    try {
      await ref
          .read(activeTransitControllerProvider.notifier)
          .startCommute(scheduleId);
      if (mounted) context.go('/active');
    } catch (error) {
      _showError(error);
    }
  }

  void _showError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(error.toString())));
  }
}

class _HomeScheduleCard extends ConsumerWidget {
  const _HomeScheduleCard({
    required this.schedule,
    required this.isCurrentCommute,
    required this.onCommutePressed,
  });

  final ScheduleWithSegments schedule;
  final bool isCurrentCommute;
  final VoidCallback onCommutePressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final variance = ref.watch(scheduleVarianceProvider(schedule.schedule.id));
    return variance.when(
      loading: () =>
          const Card(child: Center(child: CircularProgressIndicator())),
      error: (error, _) => Card(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Could not load commute averages: $error'),
          ),
        ),
      ),
      data: (value) => ScheduleCard(
        schedule: schedule,
        variance: value,
        isCurrentCommute: isCurrentCommute,
        onCommutePressed: (_) => onCommutePressed(),
        onActionSelected: (action) => _handleAction(context, ref, action),
      ),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    ScheduleCardAction action,
  ) async {
    if (action == ScheduleCardAction.edit) {
      context.go('/schedules');
      return;
    }

    final controller = ref.read(scheduleControllerProvider.notifier);
    try {
      switch (action) {
        case ScheduleCardAction.activate:
          await controller.setActive(schedule.schedule.id, true);
          return;
        case ScheduleCardAction.deactivate:
          await controller.setActive(schedule.schedule.id, false);
          return;
        case ScheduleCardAction.delete:
          final active = ref.read(activeTransitProvider).asData?.value;
          if (active?.log.scheduleId == schedule.schedule.id) {
            throw StateError(
              'Cancel the active commute before deleting its schedule.',
            );
          }
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete schedule?'),
              content: Text('Delete "${schedule.schedule.name}"?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Keep schedule'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Delete'),
                ),
              ],
            ),
          );
          if (confirmed == true) {
            await controller.deleteSchedule(schedule.schedule.id);
          }
          return;
        case ScheduleCardAction.edit:
          return;
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }
}

class _CommuteMetrics extends ConsumerWidget {
  const _CommuteMetrics({required this.schedule});

  final ScheduleWithSegments schedule;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final variance = ref.watch(scheduleVarianceProvider(schedule.schedule.id));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: variance.when(
          loading: () => const LinearProgressIndicator(),
          error: (error, _) => Text('Could not load commute metrics: $error'),
          data: (value) {
            final avg = value.averageMinutes;
            return Row(
              children: [
                Expanded(
                  child: _MetricValue(
                    label: 'Expected',
                    value: '${value.expectedMinutes} min',
                  ),
                ),
                Expanded(
                  child: _MetricValue(
                    label: 'Historical average',
                    value: avg == null ? 'No data' : '${avg.round()} min',
                  ),
                ),
                Expanded(
                  child: _MetricValue(
                    label: 'Completed trips',
                    value: '${value.sampleCount}',
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MetricValue extends StatelessWidget {
  const _MetricValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 5),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _SegmentOverview extends ConsumerWidget {
  const _SegmentOverview({required this.schedule});

  final ScheduleWithSegments schedule;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final averages = ref.watch(segmentAveragesProvider(schedule.schedule.id));
    return averages.when(
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Could not load route segments: $error'),
        ),
      ),
      data: (segments) => SegmentAccordion(segments: segments),
    );
  }
}

class _NoSchedules extends StatelessWidget {
  const _NoSchedules();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.route, size: 56),
            const SizedBox(height: 12),
            Text(
              'No schedules yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            const Text('Create a schedule to start tracking your commute.'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => context.go('/schedules'),
              icon: const Icon(Icons.add),
              label: const Text('Create schedule'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

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
