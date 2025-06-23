import 'package:flutter/material.dart';
import 'package:simple_logger_overlay/simple_logger_overlay.dart';

void main() {
  LoggerCore().i("Example started");
  runApp(const MyExampleApp());
}

class MyExampleApp extends StatelessWidget {
  const MyExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Logger Example')),
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  LoggerCore().d("User tapped log button", tag: "UI");
                },
                child: const Text("Log Something"),
              ),
            ),
          ),
        ),
        const LoggerOverlay(),
      ],
    );
  }
}
