import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeShell extends StatelessWidget {
    const HomeShell({super.key, required this.navigationShell});

    final StatefulNavigationShell navigationShell;

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: navigationShell,
            bottomNavigationBar: NavigationBar(
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: (index) => navigationShell.goBranch(
                    index,
                    initialLocation: index == navigationShell.currentIndex,
                ),
                destinations: const [
                    NavigationDestination(
                        icon: Icon(Icons.event_note_outlined),
                        selectedIcon: Icon(Icons.event_note),
                        label: 'Schedules',
                    ),
                    NavigationDestination(
                        icon: Icon(Icons.directions_transit_outlined),
                        selectedIcon: Icon(Icons.directions_transit),
                        label: 'Commute',
                    )
                ]
            )
        );
    }
}