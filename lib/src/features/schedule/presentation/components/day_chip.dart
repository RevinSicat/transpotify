import 'package:flutter/material.dart';

class DayChip extends StatelessWidget {
    final String day;
    final bool active;
    const DayChip({
        super.key, 
        required this.day, 
        required this.active
    });

    @override
    Widget build(BuildContext context) {
        return Container(
            width: 38,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
                color: active ? const Color(0xFF0051D5) 
                    : const Color(0xFFD3E4FE),
                borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                    Text(
                        day, 
                        style: TextStyle(
                            fontSize: 11, 
                            fontWeight: FontWeight.bold, 
                            color: active ? Colors.white 
                                : const Color(0xFF44474E)
                        )
                    ),
                    if (active) ...[
                        const SizedBox(height: 4),
                        Container(
                            width: 4, 
                            height: 4, 
                            decoration: const BoxDecoration(
                                color: Colors.white, 
                                shape: BoxShape.circle
                            )
                        ),
                    ]
                ]
            )
        );
    }
}