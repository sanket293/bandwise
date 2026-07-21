import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../domain/ielts_scoring.dart';

/// A low-friction band picker: a labelled row with a live slider (0.5 steps) and
/// −/+ fine controls. Updates in real time as the user drags — no Calculate
/// button. Used for the four modules in Mode A.
class BandSlider extends StatelessWidget {
  const BandSlider({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final double value;
  final ValueChanged<double> onChanged;

  static const _min = 0.0;
  static const _max = 9.0;

  void _nudge(double delta) {
    final next = (value + delta).clamp(_min, _max).toDouble();
    if (next != value) onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bandColor = AppTheme.bandColor(value, scheme);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: scheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: bandColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  IeltsScoring.formatBand(value),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: bandColor,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              _RoundIconButton(
                icon: CupertinoIcons.minus,
                onTap: () => _nudge(-0.5),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: bandColor,
                    thumbColor: bandColor,
                    overlayColor: bandColor.withValues(alpha: 0.15),
                    trackHeight: 5,
                  ),
                  child: Slider(
                    value: value,
                    min: _min,
                    max: _max,
                    divisions: 18, // 0.0 → 9.0 in 0.5 steps
                    onChanged: onChanged,
                  ),
                ),
              ),
              _RoundIconButton(
                icon: CupertinoIcons.plus,
                onTap: () => _nudge(0.5),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(backgroundColor: scheme.surfaceContainerHighest),
      icon: Icon(icon, size: 18),
      onPressed: onTap,
    );
  }
}
