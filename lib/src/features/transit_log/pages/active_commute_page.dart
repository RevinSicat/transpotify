import 'package:flutter/material.dart';

class ActiveCommutePage extends StatelessWidget {
    const ActiveCommutePage({super.key});

    @override
    Widget build(BuildContext context) {
        return Scaffold(
        appBar: AppBar(title: const Text('Active commute')),
            body: const Center(
                child: Text('Commute logger — build next.')
            )
        );
    }
}