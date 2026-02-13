import 'package:flutter/material.dart';
import '../../translation/presentation/translation_page.dart';
import 'quiz_placeholder_page.dart';

class DiscoveryPage extends StatefulWidget {
  const DiscoveryPage({super.key});

  @override
  State<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends State<DiscoveryPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('发现'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '翻译'),
            Tab(text: '测验'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          TranslationPage(),
          QuizPlaceholderPage(),
        ],
      ),
    );
  }
}
