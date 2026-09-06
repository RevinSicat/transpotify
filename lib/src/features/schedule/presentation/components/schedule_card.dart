import 'package:flutter/material.dart';
import '../../../../common/utils/common_utilities.dart';
import '../../../../core/local/database.dart';
import 'day_chip.dart';

class ScheduleCard extends StatelessWidget {
    final Schedule schedule;
    final VoidCallback onStartCommute;
    final VoidCallback? onEdit;
    final VoidCallback? onDelete;
    final VoidCallback? onOptionsPressed;

    const ScheduleCard({
        super.key,
        required this.schedule,
        required this.onStartCommute,
        this.onEdit,
        this.onDelete,
        this.onOptionsPressed,
    });

    @override
    Widget build(BuildContext context) {
        final duration = schedule.targetArrivalTime - schedule.targetStartTime;
        final activeDays = schedule.daysOfWeek
            .split(',')
            .where((d) => d.trim().isNotEmpty)
            .toSet();

        return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                    ),
                ],
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                            Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                    color: schedule.isActive
                                        ? const Color(0xFFDCFCE7)
                                        : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                        Container(
                                            width: 6,
                                            height: 6,
                                            decoration: BoxDecoration(
                                                color: schedule.isActive
                                                    ? const Color(0xFF16A34A)
                                                    : const Color(0xFF64748B),
                                                shape: BoxShape.circle,
                                            ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                            schedule.isActive ? 'ACTIVE' : 'PAUSED',
                                            style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: 0.5,
                                                color: schedule.isActive
                                                    ? const Color(0xFF15803D)
                                                    : const Color(0xFF475569),
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                            PopupMenuButton<String>(
                                icon: const Icon(
                                    Icons.more_vert,
                                    size: 20,
                                    color: Color(0xFF44474E),
                                ),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                ),
                                onSelected: (value) {
                                    if (value == 'edit') {
                                        onEdit?.call();
                                    } else if (value == 'delete') {
                                        onDelete?.call();
                                    }
                                },
                                itemBuilder: (context) => [
                                    const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                            children: [
                                                Icon(
                                                    Icons.edit_outlined,
                                                    size: 18,
                                                    color: Color(0xFF0F172A),
                                                ),
                                                SizedBox(width: 10),
                                                Text(
                                                    'Edit',
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.w600,
                                                    ),
                                                ),
                                            ],
                                        ),
                                    ),
                                    const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                            children: [
                                                Icon(
                                                    Icons.delete_outline,
                                                    size: 18,
                                                    color: Colors.red,
                                                ),
                                                SizedBox(width: 10),
                                                Text(
                                                    'Delete',
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.w600,
                                                        color: Colors.red,
                                                    ),
                                                ),
                                            ],
                                        ),
                                    ),
                                ],
                            ),
                        ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                        schedule.name,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF031636),
                        ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                            color: const Color(0xFFEFF4FF),
                            borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                                Row(
                                    children: [
                                        Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                                color: const Color(0xFF0051D5),
                                                borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                                Icons.schedule,
                                                color: Colors.white,
                                                size: 22,
                                            ),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                                Row(
                                                    children: [
                                                        Text(
                                                            CommonUtilities.formatMinutesFromMidnight(
                                                                schedule.targetStartTime,
                                                            ),
                                                            style: const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.bold,
                                                                color: Color(0xFF031636),
                                                            ),
                                                        ),
                                                        const Padding(
                                                            padding: EdgeInsets.symmetric(
                                                                horizontal: 6,
                                                            ),
                                                            child: Icon(
                                                                Icons.arrow_forward,
                                                                size: 14,
                                                                color: Color(0xFF75777F),
                                                            ),
                                                        ),
                                                        Text(
                                                            CommonUtilities.formatMinutesFromMidnight(
                                                                schedule.targetArrivalTime,
                                                            ),
                                                            style: const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.bold,
                                                                color: Color(0xFF031636),
                                                            ),
                                                        ),
                                                    ],
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                    'Target duration • ${CommonUtilities.formatDurationSummary(duration)}',
                                                    style: const TextStyle(
                                                        fontSize: 11,
                                                        color: Color(0xFF44474E),
                                                        fontWeight: FontWeight.w500,
                                                    ),
                                                ),
                                            ],
                                        ),
                                    ],
                                ),
                            ],
                        ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                        'ACTIVE WEEKLY CADENCE',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF44474E),
                        ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                            ('M', 'Mn'),
                            ('T', 'Tu'),
                            ('W', 'We'),
                            ('T', 'Th'),
                            ('F', 'Fr'),
                            ('S', 'Sa'),
                            ('S', 'Su'),
                        ].map((d) => DayChip(
                            day: d.$1,
                            active: activeDays.contains(d.$2),
                        )).toList(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                        children: [
                            Expanded(
                                flex: 2,
                                child: ElevatedButton.icon(
                                    onPressed: onStartCommute,
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF031636),
                                        foregroundColor: Colors.white,
                                        minimumSize: const Size.fromHeight(52),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                        ),
                                    ),
                                    icon: const Icon(
                                        Icons.play_arrow,
                                        color: Color(0xFFDBE1FF),
                                    ),
                                    label: const Text(
                                        'Start Commute',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                        ),
                                    ),
                                ),
                            ),
                            if (onEdit != null) ...[
                                const SizedBox(width: 8),
                                Expanded(
                                    child: OutlinedButton.icon(
                                        onPressed: onEdit,
                                        style: OutlinedButton.styleFrom(
                                            backgroundColor: const Color(0xFFD3E4FE),
                                            foregroundColor: const Color(0xFF031636),
                                            minimumSize: const Size.fromHeight(52),
                                            side: BorderSide.none,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(16),
                                            ),
                                        ),
                                        icon: const Icon(
                                            Icons.edit_outlined,
                                            size: 18,
                                        ),
                                        label: const Text(
                                            'Edit',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                            ),
                                        ),
                                    ),
                                ),
                            ],
                        ],
                    ),
                ],
            ),
        );
    }
}