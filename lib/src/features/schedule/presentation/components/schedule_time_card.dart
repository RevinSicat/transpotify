import 'package:flutter/material.dart';
import '../../../../common/utils/common_utilities.dart';

class ScheduleTimeCard extends StatelessWidget {
    final bool isStart;
    final TimeOfDay time;
    final VoidCallback onTap;

    const ScheduleTimeCard({
        super.key,
        required this.isStart,
        required this.time,
        required this.onTap,
    });

    @override
    Widget build(BuildContext context) {
        final label = isStart ? 'TARGET START' : 'TARGET ARRIVAL';
        final icon = isStart ? Icons.access_time_rounded : Icons.flag_outlined;

        return InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: const Color(0xFFF0F6FF),
                    borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Row(
                            children: [
                                Text(
                                    label,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                        color: Color(0xFF475569),
                                    ),
                                ),
                                const Spacer(),
                                Icon(
                                    icon,
                                    size: 16,
                                    color: const Color(0xFF0051D5),
                                ),
                            ],
                        ),
                        const SizedBox(height: 10),
                        RichText(
                            text: TextSpan(
                                text: CommonUtilities.formatTimeNumber(time),
                                style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF0B1C30),
                                ),
                                children: [
                                    TextSpan(
                                        text: ' ${CommonUtilities.formatTimePeriod(time)}',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF475569),
                                        ),
                                    ),
                                ],
                            ),
                        ),
                    ],
                ),
            ),
        );
    }
}
