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
      body: ListView(
        children: [
          const SizedBox(height: 16),
          ListTile(
            onTap: () {},
            title: Text(
              'BLoC Example',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            subtitle: Text(
              'Example of using BLoC logger with SimpleOverlayLogger',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: Icon(Icons.arrow_forward_ios_rounded),
          ),
        ],
      ),
    );
  }
}
