import 'package:flutter/material.dart';

class ScheduleEditorActionButtons extends StatelessWidget {
    final int currentStep;
    final bool isSaving;
    final VoidCallback onSave;
    final VoidCallback onNext;
    final VoidCallback onBack;

    const ScheduleEditorActionButtons({
        super.key,
        required this.currentStep,
        required this.isSaving,
        required this.onSave,
        required this.onNext,
        required this.onBack,
    });

    @override
    Widget build(BuildContext context) {
        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
                children: [
                    if (currentStep == 0) ...[
                        Expanded(
                            child: OutlinedButton.icon(
                                onPressed: isSaving ? null : onSave,
                                style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF0051D5),
                                    side: const BorderSide(
                                        color: Color(0xFF0051D5),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14),
                                    ),
                                ),
                                icon: const Icon(Icons.check_circle_outline),
                                label: const Text(
                                    'Save Schedule',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                    ),
                                ),
                            ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                            child: FilledButton.icon(
                                onPressed: onNext,
                                style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF0051D5),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14),
                                    ),
                                ),
                                icon: const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 18,
                                ),
                                label: const Text(
                                    'Commute Modes',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                    ),
                                ),
                            ),
                        ),
                    ] else ...[
                        Expanded(
                            child: OutlinedButton.icon(
                                onPressed: onBack,
                                style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF475569),
                                    side: const BorderSide(
                                        color: Color(0xFFCBD5E1),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14),
                                    ),
                                ),
                                icon: const Icon(Icons.arrow_back_rounded),
                                label: const Text(
                                    'Back to Details',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                    ),
                                ),
                            ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                            child: FilledButton.icon(
                                onPressed: isSaving ? null : onSave,
                                style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF0051D5),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14),
                                    ),
                                ),
                                icon: isSaving
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                        ),
                                    )
                                    : const Icon(Icons.check_rounded),
                                label: const Text(
                                    'Save Schedule',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                    ),
                                ),
                            ),
                        ),
                    ],
                ],
            ),
        );
    }
}
