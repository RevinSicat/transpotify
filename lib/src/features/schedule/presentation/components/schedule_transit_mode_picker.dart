import 'package:flutter/material.dart';
import 'schedule_segment_editor_tile.dart';

class ScheduleTransitModePicker extends StatelessWidget {
    final ValueChanged<String> onModeSelected;

    static const List<String> availableModes = [
        'Walk',
        'Bus',
        'Jeepney',
        'Train',
        'Tricycle',
    ];

    const ScheduleTransitModePicker({
        super.key,
        required this.onModeSelected,
    });

    @override
    Widget build(BuildContext context) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                const Text(
                    'Add Transit Mode',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                    ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                    width: double.infinity,
                    child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: availableModes.map((mode) {
                            return OutlinedButton.icon(
                                onPressed: () => onModeSelected(mode),
                                style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF0F172A),
                                    side: const BorderSide(
                                        color: Color(0xFFCBD5E1),
                                    ),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                    ),
                                ),
                                icon: Icon(
                                    ScheduleSegmentEditorTile.iconForMode(mode),
                                    size: 18,
                                    color: const Color(0xFF0051D5),
                                ),
                                label: Text(
                                    mode,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                    ),
                                ),
                            );
                        }).toList(),
                    ),
                ),
            ],
        );
    }
}
