import 'package:flutter/material.dart';

class CompletedTripCard extends StatelessWidget {
    final String title;
    final String time;
    final String planned;
    final String date;
    final String logNo;

    const CompletedTripCard({
        super.key, 
        required this.title, 
        required this.time, 
        required this.planned, 
        required this.date, 
        required this.logNo
    });

    @override
    Widget build(BuildContext context) {
        return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(0.02), 
                    blurRadius: 4, 
                    offset: const Offset(0, 2)
                )]
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Row(
                                        children: [
                                            Text(
                                                title, 
                                                style: const TextStyle(
                                                    fontSize: 14, 
                                                    fontWeight: FontWeight.bold, 
                                                    color: Color(0xFF0B1C30)
                                                )
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 6, 
                                                    vertical: 2
                                                ),
                                                decoration: BoxDecoration(
                                                    color: const Color(0xFFEFF4FF), 
                                                    borderRadius: BorderRadius.circular(12)
                                                ),
                                                child: const Text(
                                                    'COMPLETED', 
                                                    style: TextStyle(
                                                        fontSize: 9, 
                                                        fontWeight: FontWeight.bold, 
                                                        color: Color(0xFF0B1C30)
                                                    )
                                                )
                                            )
                                        ]
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                        date, 
                                        style: const TextStyle(
                                            fontSize: 11, 
                                            color: Color(0xFF44474E)
                                        )
                                    )
                                ]
                            ),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                    Text(
                                        time, 
                                        style: const TextStyle(
                                            fontSize: 16, 
                                            fontWeight: FontWeight.bold, 
                                            color: Color(0xFF0B1C30)
                                        )
                                    ),
                                    Text(
                                        planned, 
                                        style: const TextStyle(
                                            fontSize: 10, 
                                            color: Color(0xFF0051D5), 
                                            fontWeight: FontWeight.w500
                                        )
                                    )
                                ]
                            )
                        ]
                    ),
                    const SizedBox(height: 8),
                    Row(
                        children: [
                        const Icon(
                            Icons.check_circle_outline, 
                            size: 13, 
                            color: Color(0xFF75777F)
                        ),
                        const SizedBox(width: 4),
                        const Text(
                            'All legs on-time', 
                            style: TextStyle(
                                fontSize: 11, 
                                color: Color(0xFF44474E)
                            )
                        ),
                        const SizedBox(width: 6),
                        const Text(
                            '•', 
                            style: 
                            TextStyle(
                                color: Color(0xFF75777F)
                            )
                        ),
                        const SizedBox(width: 6),
                            Text(
                                'SQLite Log #$logNo', 
                                style: const TextStyle(
                                    fontSize: 11, 
                                    color: Color(0xFF44474E)
                                )
                            )
                        ]
                    )
                ]
            )
        );
    }
}