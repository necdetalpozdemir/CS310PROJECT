import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';

/// Seven vertical bars, Monday to Sunday, built from plain Containers
/// (no chart package needed).
///
/// Each value is a ratio from 0.0 to 1.0. A null value means the day
/// hasn't happened yet, so no bar is drawn for it.
class WeekBarChart extends StatelessWidget {
  const WeekBarChart({
    super.key,
    required this.values,
    this.highlightIndex,
    this.height = 140,
  }) : assert(values.length == 7, 'One value per weekday');

  final List<double?> values;

  /// Index (0 = Monday) drawn in a lighter color, e.g. today.
  final int? highlightIndex;

  final double height;

  static const _labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                    ),
                    child: values[i] == null
                        ? const SizedBox.shrink()
                        : _Bar(
                            // clamp keeps a wrong value inside the box.
                            ratio: values[i]!.clamp(0.0, 1.0),
                            color: i == highlightIndex
                                ? AppColors.primary.withValues(alpha: 0.45)
                                : AppColors.primary,
                            maxHeight: height,
                          ),
                  ),
                ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.border),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: Center(
                  child: Text(
                    _labels[i],
                    style: AppTextStyles.caption.copyWith(
                      color: values[i] == null ? AppColors.textHint : null,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.ratio,
    required this.color,
    required this.maxHeight,
  });

  final double ratio;
  final Color color;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    // A 0% day still gets a thin line, so the user sees it was counted.
    final barHeight = ratio == 0 ? 2.0 : maxHeight * ratio;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: barHeight,
      decoration: BoxDecoration(
        color: ratio == 0 ? AppColors.border : color,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.xs),
        ),
      ),
    );
  }
}
