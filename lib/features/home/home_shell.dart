import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ads/adaptive_banner.dart';
import '../../core/exam/exam_registry.dart';
import '../log/presentation/log_page.dart';
import '../settings/settings_page.dart';

/// Root navigation shell. The Simulator + Rubrics tabs are provided by the
/// active [ExamModule] (exam-agnostic), while Log + Settings are core features.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final exam = ref.watch(selectedExamProvider);
    final adFree = ref.watch(adFreeTodayProvider);

    final pages = [
      exam.buildSimulatorPage(context),
      exam.buildRubricsPage(context),
      const LogPage(),
      const SettingsPage(),
    ];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: _index, children: pages),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Persistent, non-intrusive banner. Hidden when the daily Focus-Mode
          // perk is active. Never overlaps interactive controls (its own row).
          if (!adFree) const AdaptiveBanner(),
          NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: const [
              NavigationDestination(
                  icon: Icon(CupertinoIcons.slider_horizontal_3), label: 'Simulate'),
              NavigationDestination(
                  icon: Icon(CupertinoIcons.doc_text), label: 'Rubrics'),
              NavigationDestination(
                  icon: Icon(CupertinoIcons.calendar), label: 'Log'),
              NavigationDestination(
                  icon: Icon(CupertinoIcons.settings), label: 'Settings'),
            ],
          ),
        ],
      ),
    );
  }
}
