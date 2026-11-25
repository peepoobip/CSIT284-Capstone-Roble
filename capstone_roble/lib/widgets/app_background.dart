import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseColors = isDark
        ? const [Color(0xFF0F0C29), Color(0xFF1B1446), Color(0xFF0B2545)]
        : const [Color(0xFFFFD3E6), Color(0xFFDCCFFF), Color(0xFFBFE8FF)];

    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: baseColors,
              ),
            ),
          ),
        ),
        Positioned(
          top: -110,
          right: -90,
          child: _Glow(
            color: const Color(0xFFFF4081),
            size: 340,
            alpha: isDark ? 0.35 : 0.40,
          ),
        ),
        Positioned(
          top: 300,
          left: -120,
          child: _Glow(
            color: const Color(0xFFFF9100),
            size: 280,
            alpha: isDark ? 0.22 : 0.35,
          ),
        ),
        Positioned(
          bottom: -130,
          left: -90,
          child: _Glow(
            color: const Color(0xFF00BFA5),
            size: 380,
            alpha: isDark ? 0.30 : 0.40,
          ),
        ),
        Positioned(
          bottom: 60,
          right: -110,
          child: _Glow(
            color: const Color(0xFF7C4DFF),
            size: 300,
            alpha: isDark ? 0.35 : 0.30,
          ),
        ),
        child,
      ],
    );
  }
}

class _Glow extends StatelessWidget {
  final Color color;
  final double size;
  final double alpha;

  const _Glow({required this.color, required this.size, required this.alpha});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: alpha),
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}