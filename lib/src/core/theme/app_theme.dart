import 'package:flutter/material.dart';

abstract class AppSpacing {
    static const double xs = 4;
    static const double sm = 8;
    static const double md = 16;
    static const double lg = 24;
    static const double xl = 32;
}

class TransportModeStyle {
    const TransportModeStyle({required this.color, required this.icon});
    final Color color;
    final IconData icon;
}

abstract class AppTransportModes {
static const Map<String, TransportModeStyle> _styles = {
    'Bus': TransportModeStyle(
        color: Color(0xFFFB8C00),
        icon: Icons.directions_bus_filled_outlined,
    ),
    'Jeepney': TransportModeStyle(
        color: Color(0xFF00897B),
        icon: Icons.airport_shuttle_outlined,
    ),
    'Tricycle': TransportModeStyle(
        color: Color(0xFF8E24AA),
        icon: Icons.electric_rickshaw_outlined,
    ),
    'Train': TransportModeStyle(
        color: Color(0xFF3949AB),
        icon: Icons.train_outlined,
    ),
    'MRT/LRT': TransportModeStyle(
        color: Color(0xFF3949AB),
        icon: Icons.tram_outlined,
    ),
    'Walk': TransportModeStyle(
        color: Color(0xFF757575),
        icon: Icons.directions_walk_outlined,
    ),
};

static const TransportModeStyle _fallback = TransportModeStyle(
    color: Color(0xFF546E7A),
    icon: Icons.commute_outlined,
);

static TransportModeStyle styleFor(String mode) =>
    _styles[mode] ?? _fallback;

    static List<String> get suggested => _styles.keys.toList(growable: false);
}

abstract class AppTheme {
    static const _seedColor = Color(0xFF00695C);

    static ThemeData get light => _build(Brightness.light);
    static ThemeData get dark => _build(Brightness.dark);

    static ThemeData _build(Brightness brightness) {
        final colorScheme = ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: brightness,
        );

        return ThemeData(
        useMaterial3: true,
        brightness: brightness,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: colorScheme.surface,
        appBarTheme: AppBarTheme(
            backgroundColor: colorScheme.surface,
            foregroundColor: colorScheme.onSurface,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
            ),
        ),
        cardTheme: CardThemeData(
            elevation: 0,
            color: colorScheme.surfaceContainerHigh,
            shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            ),
            margin: EdgeInsets.zero,
        ),
        filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
            ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
            ),
            ),
        ),
        inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        navigationBarTheme: NavigationBarThemeData(
            backgroundColor: colorScheme.surface,
            indicatorColor: colorScheme.primaryContainer,
            elevation: 0,
            height: 64,
        ),
        chipTheme: ChipThemeData(
            shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            ),
            side: BorderSide.none,
            backgroundColor: colorScheme.surfaceContainerHighest,
            labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
        dividerTheme: DividerThemeData(
            color: colorScheme.outlineVariant,
            space: 1,
        ),
        textTheme: const TextTheme(
            headlineSmall: TextStyle(fontWeight: FontWeight.w700),
            titleLarge: TextStyle(fontWeight: FontWeight.w700),
            titleMedium: TextStyle(fontWeight: FontWeight.w600),
            bodyMedium: TextStyle(height: 1.4),
        ),
        );
    }
}