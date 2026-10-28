import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../pages/active_transit_page.dart';
import '../../pages/home_page.dart';
import '../../pages/schedule_page.dart';
import '../../pages/transit_logs_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) =>
          _AppNavigationShell(state: state, child: child),
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomePage()),
        GoRoute(
          path: '/schedules',
          builder: (context, state) => const SchedulePage(),
        ),
        GoRoute(
          path: '/active',
          builder: (context, state) => const ActiveTransitPage(),
        ),
        GoRoute(
          path: '/logs',
          builder: (context, state) => const TransitLogsPage(),
        ),
      ],
    ),
  ],
);

class _AppNavigationShell extends StatelessWidget {
  const _AppNavigationShell({required this.state, required this.child});

  final GoRouterState state;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final path = state.uri.path;
    final selectedIndex = switch (path) {
      '/schedules' => 1,
      '/active' => 2,
      '/logs' => 3,
      _ => 0,
    };

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          final route = switch (index) {
            1 => '/schedules',
            2 => '/active',
            3 => '/logs',
            _ => '/',
          };
          if (route != path) context.go(route);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note),
            label: 'Schedules',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_transit_outlined),
            selectedIcon: Icon(Icons.directions_transit),
            label: 'Active',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Logs',
          ),
        ],
      ),
    );
  }
}
