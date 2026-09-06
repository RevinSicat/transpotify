import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/utils/common_utilities.dart';
import '../../../../core/local/database.dart';
import '../../../../core/local/providers.dart';
import '../../../../core/navigation/app_router.dart';
import '../../data/schedule_providers.dart';
import '../components/schedule_card.dart';
import '../components/stat_card.dart';
import '../components/live_trip_card.dart';
import '../components/completed_trip_card.dart';

class ScheduleListPage extends ConsumerWidget {
    const ScheduleListPage({super.key});

    Future<void> confirmDeleteSchedule(
        BuildContext context,
        WidgetRef ref,
        Schedule schedule,
    ) async {
        final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                ),
                title: const Text(
                    'Delete Schedule',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                    ),
                ),
                content: Text(
                    'Are you sure you want to delete "${schedule.name}"? This will also delete all associated transit legs.',
                    style: const TextStyle(color: Color(0xFF475569)),
                ),
                actions: [
                    TextButton(
                        onPressed: () => ctx.pop(false),
                        child: const Text(
                            'Cancel',
                            style: TextStyle(
                                color: Color(0xFF475569),
                                fontWeight: FontWeight.w600,
                            ),
                        ),
                    ),
                    FilledButton(
                        onPressed: () => ctx.pop(true),
                        style: FilledButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                            ),
                        ),
                        child: const Text(
                            'Delete',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                            ),
                        ),
                    ),
                ],
            ),
        );

        if (confirmed == true && context.mounted) {
            try {
                final repository = ref.read(scheduleRepositoryProvider);
                await repository.deleteScheduleWithSegments(schedule.id);
                if (context.mounted) {
                    CommonUtilities.showMessage(
                        context,
                        'Schedule "${schedule.name}" deleted',
                    );
                }
            } catch (error) {
                if (context.mounted) {
                    CommonUtilities.showMessage(
                        context,
                        'Could not delete schedule: $error',
                    );
                }
            }
        }
    }

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final schedulesAsync = ref.watch(schedulesStreamProvider);
        final colorScheme = Theme.of(context).colorScheme;

        return Scaffold(
            backgroundColor: const Color(0xFFF8F9FF),
            floatingActionButton: FloatingActionButton.extended(
                onPressed: () => context.push(AppRoutes.newSchedule),
                backgroundColor: const Color(0xFF0051D5),
                foregroundColor: Colors.white,
                elevation: 4,
                icon: const Icon(Icons.add_rounded),
                label: const Text(
                    'New Schedule',
                    style: TextStyle(fontWeight: FontWeight.bold),
                ),
            ),
            body: CustomScrollView(
                slivers: [
                    SliverAppBar(
                        floating: true,
                        pinned: true,
                        backgroundColor: const Color(0xFFF8F9FF).withValues(alpha: 0.85),
                        elevation: 0,
                        toolbarHeight: 64,
                        title: Row(
                            children: [
                                Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                        color: colorScheme.primary,
                                        borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                        Icons.alt_route, 
                                        color: Colors.white, 
                                        size: 18,
                                    ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                        const Text(
                                            'CommuteFlow',
                                            style: TextStyle(
                                                fontSize: 18, 
                                                fontWeight: FontWeight.w600, 
                                                color: Color(0xFF0B1C30),
                                            ),
                                        ),
                                        Row(
                                            children: [
                                                Container(
                                                    width: 8, 
                                                    height: 8, 
                                                    decoration: const BoxDecoration(
                                                        color: Color(0xFF0051D5), 
                                                        shape: BoxShape.circle,
                                                    ),
                                                ),
                                                const SizedBox(width: 4),
                                                const Text(
                                                    'Transit Planner', 
                                                    style: TextStyle(
                                                        fontSize: 10, 
                                                        fontWeight: FontWeight.w600, 
                                                        color: Color(0xFF0051D5),
                                                    ),
                                                ),
                                            ],
                                        ),
                                    ],
                                ),
                            ],
                        ),
                    ),
                    SliverPadding(
                        padding: const EdgeInsets.all(16.0),
                        sliver: SliverList(
                            delegate: SliverChildListDelegate([
                                Text(
                                    CommonUtilities.getGreeting(), 
                                    style: const TextStyle(
                                        fontSize: 28, 
                                        fontWeight: FontWeight.bold, 
                                        color: Color(0xFF0B1C30),
                                    ),
                                ),
                                const SizedBox(height: 16),
                                schedulesAsync.when(
                                    data: (schedules) {
                                        if (schedules.isEmpty) {
                                            return Container(
                                                width: double.infinity,
                                                padding: const EdgeInsets.symmetric(
                                                    vertical: 36,
                                                    horizontal: 20,
                                                ),
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(24),
                                                    border: Border.all(
                                                        color: const Color(0xFFE2E8F0),
                                                    ),
                                                ),
                                                child: Column(
                                                    children: [
                                                        Container(
                                                            width: 56,
                                                            height: 56,
                                                            decoration: const BoxDecoration(
                                                                color: Color(0xFFE8F1FE),
                                                                shape: BoxShape.circle,
                                                            ),
                                                            child: const Icon(
                                                                Icons.calendar_today_outlined,
                                                                color: Color(0xFF0051D5),
                                                                size: 28,
                                                            ),
                                                        ),
                                                        const SizedBox(height: 16),
                                                        const Text(
                                                            'No Commute Schedules Yet',
                                                            style: TextStyle(
                                                                fontSize: 17,
                                                                fontWeight: FontWeight.bold,
                                                                color: Color(0xFF0B1C30),
                                                            ),
                                                        ),
                                                        const SizedBox(height: 6),
                                                        const Text(
                                                            'Create your first daily commute schedule to track your routine and segments.',
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                color: Color(0xFF64748B),
                                                            ),
                                                        ),
                                                        const SizedBox(height: 18),
                                                        FilledButton.icon(
                                                            onPressed: () => context.push(AppRoutes.newSchedule),
                                                            style: FilledButton.styleFrom(
                                                                backgroundColor: const Color(0xFF0051D5),
                                                                padding: const EdgeInsets.symmetric(
                                                                    horizontal: 20,
                                                                    vertical: 12,
                                                                ),
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(14),
                                                                ),
                                                            ),
                                                            icon: const Icon(Icons.add, size: 18),
                                                            label: const Text(
                                                                'Create Schedule',
                                                                style: TextStyle(fontWeight: FontWeight.w700),
                                                            ),
                                                        ),
                                                    ],
                                                ),
                                            );
                                        }

                                        return Column(
                                            children: schedules.map((schedule) {
                                                return Padding(
                                                    padding: const EdgeInsets.only(bottom: 16),
                                                    child: ScheduleCard(
                                                        schedule: schedule,
                                                        onStartCommute: () => context.push(AppRoutes.activeCommute),
                                                        onEdit: () => context.push(AppRoutes.editSchedule(schedule.id)),
                                                        onDelete: () => confirmDeleteSchedule(context, ref, schedule),
                                                    ),
                                                );
                                            }).toList(),
                                        );
                                    },
                                    loading: () => const Center(
                                        child: Padding(
                                            padding: EdgeInsets.symmetric(vertical: 32),
                                            child: CircularProgressIndicator(),
                                        ),
                                    ),
                                    error: (err, _) => Center(child: Text('Error: $err')),
                                ),
                                /// TODO: Show Average Time and Percentage of being on Time
                                /// Currently Static Value
                                const SizedBox(height: 16),
                                Row(
                                    children: const [
                                        Expanded(
                                            child: StatCard(
                                                title: 'Avg Time', 
                                                value: '2h 42m', 
                                                subtitle: '-18m vs plan', 
                                                icon: Icons.timer, 
                                                color: Color(0xFF0051D5),
                                            ),
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                            child: StatCard(
                                                title: 'On-Time', 
                                                value: '91%', 
                                                subtitle: 'Last 30 days', 
                                                icon: Icons.check_circle, 
                                                color: Color(0xFF316BF3),
                                            ),
                                        ),
                                    ],
                                ),
                                const SizedBox(height: 24),
                                /// TODO: Show Actual Live Transit Details
                                LiveTripCard(onResume: () {}),
                                const SizedBox(height: 12),
                                /// TODO: Show List Of Actual Completed Trips
                                const CompletedTripCard(
                                    title: 'Morning Work Commute', 
                                    time: '2h 38m', 
                                    planned: 'Planned 3h 0m', 
                                    date: 'Yesterday, Oct 22', 
                                    logNo: '47',
                                ),
                                const SizedBox(height: 80),
                            ]),
                        ),
                    ),
                ],
            ),
        );
    }
}