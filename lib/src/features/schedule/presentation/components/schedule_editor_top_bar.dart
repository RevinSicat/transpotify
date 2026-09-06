import 'package:flutter/material.dart';

class ScheduleEditorTopBar extends StatelessWidget {
    final VoidCallback onClose;
    final String title;

    const ScheduleEditorTopBar({
        super.key,
        required this.onClose,
        this.title = 'New Commute Schedule'
    });

    @override
    Widget build(BuildContext context) {
        return Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: Row(
                children: [
                    InkWell(
                        onTap: onClose,
                        borderRadius: BorderRadius.circular(22),
                        child: Container(
                            width: 42,
                            height: 42,
                            decoration: const BoxDecoration(
                                color: Color(0xFFE8F1FE),
                                shape: BoxShape.circle
                            ),
                            child: const Icon(
                                Icons.close,
                                size: 20,
                                color: Color(0xFF0F172A)
                            )
                        )
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(
                            title,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.3
                            ),
                            overflow: TextOverflow.ellipsis
                        )
                    )
                ]
            )
        );
    }
}
