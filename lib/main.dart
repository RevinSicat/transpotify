import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/core/navigation/app_router.dart';

void main() {
  runApp(const ProviderScope(child: TranspotifyApp()));
}

class TranspotifyApp extends StatelessWidget {
  const TranspotifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF00796B),
    );
    return MaterialApp.router(
      title: 'Transpotify',
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        cardTheme: const CardThemeData(margin: EdgeInsets.zero),
      ),
      routerConfig: appRouter,
    );
  }
}
