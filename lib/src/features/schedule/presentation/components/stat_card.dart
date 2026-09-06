import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
    final String title;
    final String value;
    final String subtitle;
    final IconData icon;
    final Color color;

    const StatCard({
        super.key, 
        required this.title, 
        required this.value, 
        required this.subtitle, 
        required this.icon, 
        required this.color
    });

    @override
    Widget build(BuildContext context) {
        return Container(
        padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(0.02), 
                    blurRadius: 4, 
                    offset: const Offset(0, 2)
                )],
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Row(
                        children: [
                            Icon(
                                icon, 
                                size: 14, 
                                color: color
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                                child: Text(
                                    title, 
                                    style: const TextStyle(
                                        fontSize: 11, 
                                        color: Color(0xFF44474E)
                                    ), 
                                    overflow: TextOverflow.ellipsis
                                )
                            )
                        ]
                    ),
                    const SizedBox(height: 8),
                    Text(
                        value, 
                        style: const TextStyle(
                            fontSize: 16, 
                            fontWeight: FontWeight.bold, 
                            color: Color(0xFF0B1C30)
                        )
                    ),
                    const SizedBox(height: 2),
                    Text(
                        subtitle, 
                        style: TextStyle(
                            fontSize: 10, 
                            fontWeight: FontWeight.w600, 
                            color: color
                        )
                    )
                ]
            )
        );
    }
}