import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScheduleSegmentEditorTile extends StatelessWidget {
    final String mode;
    final TextEditingController nameController;
    final TextEditingController durationController;
    final VoidCallback onRemove;
    final Key itemKey;
    final int index;

    const ScheduleSegmentEditorTile({
        super.key,
        required this.mode,
        required this.nameController,
        required this.durationController,
        required this.onRemove,
        required this.itemKey,
        required this.index,
    });

    static IconData iconForMode(String mode) {
        switch (mode) {
            case 'Bus':
                return Icons.directions_bus_outlined;
            case 'Train':
                return Icons.train_outlined;
            case 'MiniBus':
            case 'Jeepney':
                return Icons.airport_shuttle_outlined;
            case 'Tricycle':
                return Icons.electric_rickshaw_outlined;
            case 'Tram':
            case 'MRT/LRT':
                return Icons.tram_outlined;
            default:
                return Icons.directions_walk_outlined;
        }
    }

    IconData get _modeIcon => iconForMode(mode);

    @override
    Widget build(BuildContext context) {
        return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        // Row 1: = [Transit Mode] and at end delete
                        Row(
                            children: [
                                ReorderableDragStartListener(
                                    index: index,
                                    child: const Padding(
                                        padding: EdgeInsets.all(4),
                                        child: Icon(
                                            Icons.drag_handle,
                                            color: Color(0xFF747B88),
                                        ),
                                    ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFEAF1FF),
                                        borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                            Icon(
                                                _modeIcon,
                                                size: 18,
                                                color: const Color(0xFF0051D5),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                                mode,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFF0B1C30),
                                                ),
                                            ),
                                        ],
                                    ),
                                ),
                                const Spacer(),
                                IconButton(
                                    tooltip: 'Remove segment',
                                    onPressed: onRemove,
                                    icon: const Icon(Icons.delete_outline),
                                    color: const Color(0xFF6A7180),
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(6),
                                ),
                            ],
                        ),
                        const SizedBox(height: 10),

                        // Row 2: 'Commute Label:' and aligned with time field below 'Time'
                        Row(
                            children: const [
                                Expanded(
                                    child: Text(
                                        'Commute Label:',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF64748B),
                                        ),
                                    ),
                                ),
                                SizedBox(width: 16),
                                SizedBox(
                                    width: 80,
                                    child: Text(
                                        'Time',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF64748B),
                                        ),
                                    ),
                                ),
                            ],
                        ),
                        const SizedBox(height: 4),

                        // Row 3: Commute Label text field like schedule name style, and Time field (digits only + 'M')
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                                Expanded(
                                    child: TextField(
                                        controller: nameController,
                                        textCapitalization:
                                            TextCapitalization.words,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0F172A),
                                        ),
                                        decoration: const InputDecoration(
                                            hintText: 'e.g. Bus 42',
                                            hintStyle: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF94A3B8),
                                            ),
                                            border: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            errorBorder: InputBorder.none,
                                            focusedErrorBorder: InputBorder.none,
                                            filled: false,
                                            isDense: true,
                                            contentPadding:
                                                EdgeInsets.symmetric(vertical: 4),
                                        ),
                                    ),
                                ),
                                const SizedBox(width: 16),
                                SizedBox(
                                    width: 80,
                                    child: Row(
                                        children: [
                                            Expanded(
                                                child: TextField(
                                                    controller:
                                                        durationController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    inputFormatters: [
                                                        FilteringTextInputFormatter
                                                            .digitsOnly,
                                                        LengthLimitingTextInputFormatter(
                                                            4,
                                                        ),
                                                    ],
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xFF0F172A),
                                                    ),
                                                    decoration:
                                                        const InputDecoration(
                                                        hintText: '0',
                                                        hintStyle: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Color(
                                                                0xFF94A3B8,
                                                            ),
                                                        ),
                                                        border:
                                                            InputBorder.none,
                                                        enabledBorder:
                                                            InputBorder.none,
                                                        focusedBorder:
                                                            InputBorder.none,
                                                        errorBorder:
                                                            InputBorder.none,
                                                        focusedErrorBorder:
                                                            InputBorder.none,
                                                        filled: false,
                                                        isDense: true,
                                                        contentPadding:
                                                            EdgeInsets
                                                                .symmetric(
                                                            vertical: 4,
                                                        ),
                                                    ),
                                                ),
                                            ),
                                            const SizedBox(width: 4),
                                            const Text(
                                                'M',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w800,
                                                    color: Color(0xFF64748B),
                                                ),
                                            ),
                                        ],
                                    ),
                                ),
                            ],
                        ),
                    ],
                ),
            ),
        );
    }
}
