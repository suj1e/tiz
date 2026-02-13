import 'package:flutter/material.dart';

void main() {
  runApp(const TizApp());
}

class TizApp extends StatelessWidget {
  const TizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tiz',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Tiz MVP'),
        ),
      ),
    );
  }
}
