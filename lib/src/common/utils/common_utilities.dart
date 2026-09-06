import 'package:flutter/material.dart';

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
