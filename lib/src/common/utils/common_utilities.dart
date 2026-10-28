import 'package:flutter/material.dart';

/// Result of comparing a schedule's planned duration with what actually happened.
///
/// Sign convention: [varianceMinutes] = average − expected, so a NEGATIVE value
/// means trips are faster than planned and a POSITIVE value means slower.
class DurationVariance {
  const DurationVariance({
    required this.expectedMinutes,
    required this.averageMinutes,
    required this.sampleCount,
  });

  final int expectedMinutes;

  /// Null when there are no completed logs yet.
  final double? averageMinutes;
  final int sampleCount;

  bool get hasData => averageMinutes != null;

  double? get varianceMinutes =>
      averageMinutes == null ? null : averageMinutes! - expectedMinutes;

  String get summary => CommonUtilities.formatVarianceSummary(varianceMinutes);
}

abstract final class CommonUtilities {
  /// Data Functions
  static String formatTimeNumber(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  static String formatTimePeriod(TimeOfDay time) {
    return time.period == DayPeriod.am ? 'AM' : 'PM';
  }

  static int timeToMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

  static TimeOfDay minutesToTime(int minutes) {
    return TimeOfDay(hour: (minutes ~/ 60) % 24, minute: minutes % 60);
  }

  static String formatMinutesFromMidnight(int minutesFromMidnight) {
    final hours = minutesFromMidnight ~/ 60;
    final minutes = minutesFromMidnight % 60;
    final period = hours >= 12 ? 'PM' : 'AM';
    final displayHour = hours % 12 == 0 ? 12 : hours % 12;
    return '$displayHour:${minutes.toString().padLeft(2, '0')} $period';
  }

  static int durationMinutes(TimeOfDay start, TimeOfDay arrival) {
    return timeToMinutes(arrival) - timeToMinutes(start);
  }

  static String formatDurationSummary(int duration) {
    if (duration < 0) return 'Arrival must be after start';
    final hours = duration ~/ 60;
    final mins = duration % 60;
    return '${hours}h ${mins.toString().padLeft(2, '0')}m ($duration mins)';
  }

  /// --- Variance / Analytics ---

  /// Parses a stored "HH:mm" string (24h) into minutes since midnight.
  /// Throws [FormatException] on malformed or out-of-range input.
  static int parseHHmmToMinutes(String value) {
    final parts = value.trim().split(':');
    final hour = parts.length == 2 ? int.tryParse(parts[0]) : null;
    final minute = parts.length == 2 ? int.tryParse(parts[1]) : null;
    if (hour == null || minute == null || hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      throw FormatException('Expected "HH:mm" (24h), got "$value"');
    }
    return hour * 60 + minute;
  }

  /// Expected Duration = targetArrivalTime - targetStartTime.
  /// An arrival earlier than the start is treated as crossing midnight.
  static int expectedDurationMinutes(String targetStartTime, String targetArrivalTime) {
    final start = parseHHmmToMinutes(targetStartTime);
    final arrival = parseHHmmToMinutes(targetArrivalTime);
    return arrival >= start ? arrival - start : arrival + 24 * 60 - start;
  }

  /// Average Duration = mean of historical actual durations (completed logs only,
  /// filtering is the caller's/DAO's job). Null when there is no history.
  static double? averageDurationMinutes(Iterable<int> actualDurations) {
    if (actualDurations.isEmpty) return null;
    return actualDurations.reduce((a, b) => a + b) / actualDurations.length;
  }

  /// Variance = Average Duration - Expected Duration. Null when there is no average.
  static double? varianceMinutes({required double? average, required int expected}) {
    return average == null ? null : average - expected;
  }

  /// One-stop helper: schedule target times + completed-log durations -> [DurationVariance].
  static DurationVariance computeVariance({
    required String targetStartTime,
    required String targetArrivalTime,
    required Iterable<int> completedDurations,
  }) {
    return DurationVariance(
      expectedMinutes: expectedDurationMinutes(targetStartTime, targetArrivalTime),
      averageMinutes: averageDurationMinutes(completedDurations),
      sampleCount: completedDurations.length,
    );
  }

  /// e.g. "15 mins less than expected time", "1h 05m more than expected time".
  static String formatVarianceSummary(double? variance) {
    if (variance == null) return 'No completed trips yet';
    final rounded = variance.round();
    if (rounded == 0) return 'Right on the expected time';
    final abs = rounded.abs();
    final amount = abs >= 60
        ? '${abs ~/ 60}h ${(abs % 60).toString().padLeft(2, '0')}m'
        : '$abs ${abs == 1 ? 'min' : 'mins'}';
    return '$amount ${rounded < 0 ? 'less' : 'more'} than expected time';
  }

  /// --- Dynamic Copy ---
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning!';
    if (hour < 17) return 'Good afternoon!';
    return 'Good evening!';
  }

  /// --- UI Feedback ---
  static void showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}