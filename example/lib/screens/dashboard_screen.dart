import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Simple Overlay Logger Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Placeholder(),
    );
  }
}
