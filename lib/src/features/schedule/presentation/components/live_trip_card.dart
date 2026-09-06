import 'package:flutter/material.dart';

class LiveTripCard extends StatelessWidget {
    final VoidCallback onResume;
    const LiveTripCard({
        super.key, 
        required this.onResume
    });

    @override
    Widget build(BuildContext context) {
        return Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(0.03), 
                    blurRadius: 6, 
                    offset: const Offset(0, 2)
                )]
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
                children: [
                    Positioned(
                        left: 0, 
                        top: 0, 
                        bottom: 0, 
                        child: Container(
                            width: 6, 
                            color: const Color(0xFF316BF3)
                        )
                    ),
                    Padding(
                        padding: const EdgeInsets.all(16).copyWith(left: 20),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                        Row(
                                            children: const [
                                                Text(
                                                    'Morning Work Commute', 
                                                    style: TextStyle(
                                                        fontSize: 14, 
                                                        fontWeight: FontWeight.bold, 
                                                        color: Color(0xFF0B1C30)
                                                    )
                                                ),
                                                SizedBox(width: 8),
                                                Badge(
                                                    label: Text('LIVE TRIP'), 
                                                    backgroundColor: Color(0xFFDBE1FF)
                                                )
                                            ]
                                        ),
                                        const Icon(
                                            Icons.north_east, 
                                            size: 18, 
                                            color: Color(0xFF0051D5)
                                        )
                                    ]
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                    'Today • Started at 6:04 AM (Scheduled 6:00 AM)', 
                                    style: TextStyle(
                                        fontSize: 11, 
                                        color: Color(0xFF44474E)
                                    )
                                ),
                                const SizedBox(height: 12),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: const [
                                        Text(
                                            'Progress: Leg 2 of 3 (Central Rail)', 
                                            style: TextStyle(
                                                fontSize: 11, 
                                                color: Color(0xFF44474E)
                                            )
                                        ),
                                        Text(
                                            '68% Complete', 
                                            style: TextStyle(
                                                fontSize: 11, 
                                                fontWeight: FontWeight.bold, 
                                                color: Color(0xFF0051D5)
                                            )
                                        )
                                    ]
                                ),
                                const SizedBox(height: 6),
                                const LinearProgressIndicator(
                                    value: 0.68, 
                                    backgroundColor: Color(0xFFD3E4FE), 
                                    color: Color(0xFF316BF3)
                                ),
                                const SizedBox(height: 12),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                        Row(
                                            children: const [
                                                Icon(
                                                    Icons.near_me, 
                                                    size: 14, 
                                                    color: Color(0xFF0051D5)
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                    'Approaching South Terminal', 
                                                    style: TextStyle(
                                                        fontSize: 11, 
                                                        color: Color(0xFF44474E)
                                                    )
                                                )
                                            ]
                                        ),
                                        ElevatedButton.icon(
                                        onPressed: onResume,
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF0051D5),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 14, 
                                                vertical: 8
                                            ),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                                        ),
                                        icon: const Text(
                                            'Resume', 
                                            style: TextStyle(
                                                fontSize: 12, 
                                                fontWeight: FontWeight.bold
                                            )
                                        ),
                                        label: const Icon(
                                            Icons.arrow_forward, 
                                            size: 14)
                                        )
                                    ]
                                )
                            ]
                        )
                    )
                ]
            )
        );
    }
}