import 'package:flutter/material.dart';

abstract final class AppColors {
  static const _modeColors = <String, Color>{
    'walk': Color(0xFF2E7D32),
    'bus': Color(0xFF1565C0),
    'train': Color(0xFF6A1B9A),
    'minibus': Color(0xFF00838F),
    'car': Color(0xFFEF6C00),
    'motorcycle': Color(0xFFC62828),
    'bike': Color(0xFF558B2F),
    'other': Color(0xFF546E7A),
  };

  static Color transportModeColor(String mode) =>
      _modeColors[mode.trim().toLowerCase()] ?? _modeColors['other']!;

  static IconData transportModeIcon(String mode) {
    return switch (mode.trim().toLowerCase()) {
      'walk' => Icons.directions_walk,
      'bus' => Icons.directions_bus,
      'train' => Icons.train,
      'minibus' => Icons.directions_bus,
      'car' => Icons.directions_car,
      'motorcycle' => Icons.two_wheeler,
      'bike' => Icons.directions_bike,
      _ => Icons.directions_transit,
    };
  }
}
