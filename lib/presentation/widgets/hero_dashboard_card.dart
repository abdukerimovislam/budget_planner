import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

enum CardMetal { platinum, gold }

class HeroDashboardCard extends StatelessWidget {
  final String label;
  final String value;
  final bool isWarning;
  final bool withSparkline;
  final Widget bottomWidget;
  final CardMetal metal;

  const HeroDashboardCard({
    super.key,
    required this.label,
    required this.value,
    this.isWarning = false,
    this.withSparkline = false,
    required this.bottomWidget,
    this.metal = CardMetal.platinum,
  });

  @override
  Widget build(BuildContext context) {
    final isGold = metal == CardMetal.gold;

    // Сверхреалистичные градиенты металлов
    final platinumGradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF5A5A5C), // Светлый край (блик на металле)
        Color(0xFF2C2C2E), // Основной титан (iOS System Dark)
        Color(0xFF1C1C1E), // Глубокая тень
        Color(0xFF3A3A3C), // Нижний отблеск
      ],
      stops: [0.0, 0.4, 0.8, 1.0],
    );

    final goldGradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFFDE08B), // Яркий золотой блик
        Color(0xFFD4AF37), // Классическое золото
        Color(0xFFAA771C), // Темная бронзовая тень
        Color(0xFFE8C361), // Нижний отблеск
      ],
      stops: [0.0, 0.3, 0.7, 1.0],
    );

    final textColor = isGold ? const Color(0xFF3E2B08) : Colors.white;
    final subTextColor = isGold ? const Color(0xFF7A5C22) : const Color(0xFFAEAEC0);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24), // Скругления как у физической карты
        gradient: isGold ? goldGradient : platinumGradient,
        boxShadow: [
          BoxShadow(
            color: (isGold ? const Color(0xFFD4AF37) : Colors.black).withOpacity(isGold ? 0.4 : 0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(isGold ? 0.5 : 0.15), // Тонкая фаска (edge highlight)
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // 1. Диагональный световой блик (Магия стекла/металла)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: const Alignment(-0.8, -1.0),
                    end: const Alignment(0.8, 1.0),
                    colors: [
                      Colors.white.withOpacity(0.0),
                      Colors.white.withOpacity(isGold ? 0.3 : 0.1),
                      Colors.white.withOpacity(0.0),
                    ],
                    stops: const [0.3, 0.5, 0.7],
                  ),
                ),
              ),
            ),
          ),

          // 2. График (Пульс) на фоне
          if (withSparkline)
            Positioned(
              bottom: 0, left: 0, right: 0, height: 110,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                child: CustomPaint(
                    painter: _SparklinePainter(
                        color: (isGold ? Colors.white : CupertinoColors.activeGreen).withOpacity(0.2)
                    )
                ),
              ),
            ),

          // 3. Основной контент Карты
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Шапка карты: Лого + Значок бесконтактной оплаты (NFC)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(CupertinoIcons.creditcard_fill, size: 16, color: subTextColor),
                        const SizedBox(width: 8),
                        Text(
                          'BUDGET PLANNER',
                          style: TextStyle(
                            color: subTextColor,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.0, // Эффект гравировки
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    Transform.rotate(
                      angle: 3.14159 / 2, // Поворачиваем иконку Wi-Fi, чтобы получить NFC
                      child: Icon(Icons.wifi, size: 20, color: subTextColor),
                    ),
                  ],
                ),

                const Spacer(flex: 1),

                // Центральная часть: Суммы
                Text(
                  label,
                  style: TextStyle(
                      color: subTextColor,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      fontSize: 12
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (w, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                          position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(anim),
                          child: w
                      )
                  ),
                  child: Text(
                    value,
                    key: ValueKey(value),
                    style: TextStyle(
                      color: isWarning ? CupertinoColors.destructiveRed : textColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 42,
                      letterSpacing: -1.5,
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // Подвал карты (Виджет со стеклом)
                bottomWidget,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final Color color;
  _SparklinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.8, size.width * 0.5, size.height * 0.4)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.1, size.width, size.height * 0.6)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}