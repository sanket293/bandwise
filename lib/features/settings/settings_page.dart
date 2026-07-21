import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/ads/ad_service.dart';
import '../exams/ielts/domain/ielts_models.dart';
import 'settings_controller.dart';

String todayKey() => DateFormat('yyyy-MM-dd').format(DateTime.now());

/// True if the user has unlocked the daily ad-free perk for today.
final adFreeTodayProvider = Provider<bool>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.rewardUnlockedDate == todayKey();
});

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final adFree = ref.watch(adFreeTodayProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader('Appearance'),
          Card(
            child: RadioGroup<ThemeMode>(
              groupValue: settings.themeMode,
              onChanged: (m) => controller.setThemeMode(m!),
              child: Column(
                children: [
                  for (final mode in ThemeMode.values)
                    RadioListTile<ThemeMode>(
                      value: mode,
                      title: Text(switch (mode) {
                        ThemeMode.system => 'System default',
                        ThemeMode.light => 'Light',
                        ThemeMode.dark => 'Dark',
                      }),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _SectionHeader('Default IELTS exam type'),
          Card(
            child: RadioGroup<IeltsVariant>(
              groupValue: IeltsVariant.fromId(settings.variantId),
              onChanged: (nv) => controller.setVariant(nv!),
              child: Column(
                children: [
                  for (final v in IeltsVariant.values)
                    RadioListTile<IeltsVariant>(
                      value: v,
                      title: Text(v.label),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _SectionHeader('Daily perk'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        adFree ? CupertinoIcons.checkmark_seal_fill : CupertinoIcons.gift,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          adFree
                              ? 'Focus Mode is active — banners hidden for today.'
                              : 'Watch one short video to hide banner ads for the rest of today.',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonal(
                      onPressed: adFree
                          ? null
                          : () {
                              final shown = ref.read(adServiceProvider).showRewarded(
                                    onReward: () =>
                                        controller.unlockRewardToday(todayKey()),
                                  );
                              if (!shown) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'No reward video ready yet — try again shortly.')),
                                );
                              }
                            },
                      child: Text(adFree ? 'Unlocked for today' : 'Watch & unlock Focus Mode'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _SectionHeader('About'),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(CupertinoIcons.lock_shield),
                  title: Text('Your data stays on this device'),
                  subtitle: Text('No account, no cloud sync, no personal analytics.'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(CupertinoIcons.info),
                  title: const Text('Scoring data'),
                  subtitle: const Text(
                      'Conversion tables are indicative and versioned. IELTS does not '
                      'publish a single fixed table; boundaries vary between test versions.'),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: Text(text.toUpperCase(),
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
      );
}
