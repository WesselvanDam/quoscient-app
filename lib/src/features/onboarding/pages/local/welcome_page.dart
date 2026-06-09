import 'dart:math';

import 'package:flutter/material.dart' hide Card;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../router/routes.dart';
import '../../../../design_system/components/cards/card.dart';
import '../../../../design_system/styles/app_colors.dart';
import '../../../../design_system/styles/app_typography.dart';
import '../../../../shared/widgets/ratio_text.dart';
import '../../../game/controllers/ratio_controller.dart';
import '../../../game/widgets/custom_ratio_field.dart';

class WelcomePage extends ConsumerStatefulWidget {
  const WelcomePage({super.key});

  @override
  ConsumerState<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends ConsumerState<WelcomePage> {
  bool _showGestureHint = true;

  @override
  void initState() {
    super.initState();
    _showGestureHint = ref.read(ratioControllerProvider) == 3;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<double>(ratioControllerProvider, (previous, next) {
      if (previous != next && _showGestureHint) {
        setState(() {
          _showGestureHint = false;
        });
      }
    });

    final ratio = ref.watch(ratioControllerProvider);

    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        const SizedBox(height: 24),
        GestureDetector(
          onDoubleTap: () => const HomeRoute().go(context),
          child: const Text('Welcome To Quoscient!', style: AppTypography.h2),
        ),
        const Text(
          'To continue, drag the squares until square B is twice the size of square A.',
          style: AppTypography.h4,
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: .end,
            spacing: 16,
            children: [
              Card(
                child: Column(
                  children: [
                    Text(
                      'Ratio between the sizes of both squares'.toUpperCase(),
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.neutral400,
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4, width: double.infinity),
                    RatioText(
                      ratio: ratio,
                      style: AppTypography.labelLarge.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = constraints.biggest.shortestSide;
                    return SizedBox.square(
                      dimension: size,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const CustomRatioField(),
                          Positioned.fill(
                            child: IgnorePointer(
                              child: AnimatedSwitcher(
                                duration: 260.milliseconds,
                                switchInCurve: Curves.easeOutCubic,
                                switchOutCurve: Curves.easeInCubic,
                                transitionBuilder: (child, animation) {
                                  final fade = CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOut,
                                  );
                                  final slide = Tween<Offset>(
                                    begin: const Offset(0, 0.06),
                                    end: Offset.zero,
                                  ).animate(animation);

                                  return FadeTransition(
                                    opacity: fade,
                                    child: SlideTransition(
                                      position: slide,
                                      child: child,
                                    ),
                                  );
                                },
                                child: _showGestureHint
                                    ? const _GestureHintOverlay(
                                        key: ValueKey('gesture-hint'),
                                      )
                                    : const SizedBox.shrink(
                                        key: ValueKey('gesture-hint-hidden'),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GestureHintOverlay extends StatelessWidget {
  const _GestureHintOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: colors.surface.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.16),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                          Icons.touch_app_rounded,
                          color: AppColors.primary700,
                          size: 18,
                        )
                        .animate(
                          onPlay: (controller) =>
                              controller.repeat(reverse: true),
                        )
                        .moveY(
                          begin: 0,
                          end: -3,
                          duration: 900.ms,
                          curve: Curves.easeInOut,
                        ),
                    const SizedBox(width: 8),
                    Text(
                      'Drag up!',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.neutral900,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 160.ms)
              .scale(
                begin: const Offset(0.98, 0.98),
                end: const Offset(1, 1),
                duration: 200.ms,
              ),
          const SizedBox(height: 10),
          const Icon(
                Icons.keyboard_arrow_up_rounded,
                color: AppColors.neutral100,
                size: 30,
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .moveY(
                begin: 0,
                end: -5,
                duration: 900.ms,
                curve: Curves.easeInOut,
              )
              .fadeIn(duration: 220.ms),
        ],
      ),
    );
  }
}
