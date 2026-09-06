import 'package:flutter/material.dart';

class ScheduleEditorStepper extends StatelessWidget {
    final int currentStep;
    final ValueChanged<int> onStepTapped;

    const ScheduleEditorStepper({
        super.key,
        required this.currentStep,
        required this.onStepTapped,
    });

    @override
    Widget build(BuildContext context) {
        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
                children: [
                    // Step 1: Schedule Details
                    InkWell(
                        onTap: () => onStepTapped(0),
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                    Container(
                                        width: 26,
                                        height: 26,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color: currentStep == 0
                                                ? const Color(0xFF0051D5)
                                                : const Color(0xFFDBEAFE),
                                            shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                            '1',
                                            style: TextStyle(
                                                color: currentStep == 0
                                                    ? Colors.white
                                                    : const Color(0xFF0051D5),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                            ),
                                        ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                        'Schedule Details',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: currentStep == 0
                                                ? const Color(0xFF0F172A)
                                                : const Color(0xFF475569),
                                        ),
                                    ),
                                ],
                            ),
                        ),
                    ),
                    // Connector Bar (flexible to prevent overflow)
                    Expanded(
                        child: Container(
                            height: 3,
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                color: const Color(0xFF2563EB),
                                borderRadius: BorderRadius.circular(2),
                            ),
                        ),
                    ),
                    // Step 2: Commute Modes
                    InkWell(
                        onTap: () => onStepTapped(1),
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                    Container(
                                        width: 28,
                                        height: 28,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color: currentStep == 1
                                                ? const Color(0xFF0051D5)
                                                : const Color(0xFFDBEAFE),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: const Color(0xFFBFDBFE),
                                                width: 2,
                                            ),
                                        ),
                                        child: Text(
                                            '2',
                                            style: TextStyle(
                                                color: currentStep == 1
                                                    ? Colors.white
                                                    : const Color(0xFF0051D5),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                            ),
                                        ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                        'Commute Modes',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: currentStep == 1
                                                ? const Color(0xFF0F172A)
                                                : const Color(0xFF0051D5),
                                        ),
                                    ),
                                ],
                            ),
                        ),
                    ),
                ],
            ),
        );
    }
}
