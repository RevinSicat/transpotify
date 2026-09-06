import 'package:flutter/material.dart';

class ScheduleDaysSelector extends StatelessWidget {
    final Set<String> selectedDays;
    final ValueChanged<String> onDayToggled;

    static const List<String> days = ['Mn', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

    const ScheduleDaysSelector({
        super.key,
        required this.selectedDays,
        required this.onDayToggled,
    });

    @override
    Widget build(BuildContext context) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Row(
                    children: [
                        const Text(
                            'Active Days of Week',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF334155),
                            ),
                        ),
                        const Spacer(),
                        Text(
                            '${selectedDays.length} ${selectedDays.length == 1 ? 'day' : 'days'} selected',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0051D5),
                            ),
                        ),
                    ],
                ),
                const SizedBox(height: 10),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: days.map((day) {
                        final isSelected = selectedDays.contains(day);

                        return Expanded(
                            child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2),
                                child: InkWell(
                                    onTap: () => onDayToggled(day),
                                    borderRadius: BorderRadius.circular(12),
                                    child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 150),
                                        height: 42,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color: isSelected
                                                ? const Color(0xFF0051D5)
                                                : const Color(0xFFE2EDFE),
                                            borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                            day,
                                            style: TextStyle(
                                                color: isSelected
                                                    ? Colors.white
                                                    : const Color(0xFF334155),
                                                fontWeight: FontWeight.w800,
                                                fontSize: 13,
                                            ),
                                        ),
                                    ),
                                ),
                            ),
                        );
                    }).toList(),
                ),
            ],
        );
    }
}
