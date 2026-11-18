import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFF0F7),
                  Color(0xFFF3EBFF),
                  Color(0xFFE3F6FF),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: -90,
          right: -70,
          child: _Blob(color: const Color(0xFFFF4081), size: 260, alpha: 0.14),
        ),
        Positioned(
          bottom: -100,
          left: -80,
          child: _Blob(color: const Color(0xFF00BFA5), size: 300, alpha: 0.14),
        ),
        Positioned(
          top: 320,
          left: -60,
          child: _Blob(color: const Color(0xFFFF9100), size: 160, alpha: 0.12),
        ),
        child,
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;
  final double alpha;

  const _Blob({required this.color, required this.size, required this.alpha});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: alpha),
      ),
    );
  }
}