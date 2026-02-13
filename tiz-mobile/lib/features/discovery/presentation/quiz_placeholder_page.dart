import 'package:flutter/material.dart';

class QuizPlaceholderPage extends StatelessWidget {
  const QuizPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('测验')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hourglass_empty, size: 64),
            SizedBox(height: 16),
            Text('敬请期待', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
