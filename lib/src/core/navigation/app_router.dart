import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../pages/home_shell.dart';
import '../../features/schedule/presentation/pages/schedule_list_page.dart';
import '../../features/schedule/presentation/pages/schedule_editor_page.dart';
import '../../features/transit_log/pages/active_commute_page.dart';

abstract class AppRoutes {
    static const schedules = '/schedules';
    static const newSchedule = '/schedules/new';
    static const commute = '/commute';
    static const activeCommute = '/commute/active';

    static String editSchedule(int id) => '/schedules/$id/edit';
    static String commuteDetail(int transitLogId) => '/commute/$transitLogId';
}

final rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.schedules,
    routes: [
        StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) => HomeShell(navigationShell: navigationShell),
            branches: [
                StatefulShellBranch(
                    routes: [
                        GoRoute(
                            path: AppRoutes.schedules,
                            builder: (context, state) => const ScheduleListPage()
                        )
                    ]
                ),
                StatefulShellBranch(
                    routes: [
                        GoRoute(
                            path: AppRoutes.commute,
                            builder: (context, state) => const ActiveCommutePage()
                        )
                    ]
                )
            ]
        ),
        GoRoute(
            path: AppRoutes.newSchedule,
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => const ScheduleEditorPage()
        ),
        GoRoute(
            path: '/schedules/:id/edit',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) {
                final id = int.tryParse(state.pathParameters['id'] ?? '');
                return ScheduleEditorPage(scheduleId: id);
            },
        ),
        GoRoute(
            path: AppRoutes.activeCommute,
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => const ActiveCommutePage()
        ),
    ]
);