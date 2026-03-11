import 'package:flutter/material.dart';

class PremiumBackground extends StatelessWidget {
  final Widget child;

  const PremiumBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Базовый цвет подложки (очень темный для ночной, светло-серый для дневной)
    final baseColor = isDark ? Colors.black : const Color(0xFFF2F2F7);

    return Material(
      color: baseColor,
      child: Stack(
        children: [
          // 1. Верхнее левое пятно (Primary Color)
          Positioned(
            top: -150,
            left: -150,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(isDark ? 0.25 : 0.1),
                    Colors.transparent,
                  ],
                  stops: const [0.2, 1.0],
                ),
              ),
            ),
          ),

          // 2. Нижнее правое пятно (Secondary / Tertiary Color)
          Positioned(
            bottom: -200,
            right: -100,
            child: Container(
              width: 600,
              height: 600,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    theme.colorScheme.secondary.withOpacity(isDark ? 0.2 : 0.08),
                    Colors.transparent,
                  ],
                  stops: const [0.2, 1.0],
                ),
              ),
            ),
          ),

          // 3. Сам контент экрана поверх фона
          Positioned.fill(
            child: child,
          ),
        ],
      ),
    );
  }
}