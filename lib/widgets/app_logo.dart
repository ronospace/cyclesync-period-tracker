import 'package:flutter/material.dart';
import 'dart:math' as math;

/// CycleSync app logo widget
/// A beautiful, theme-aware logo with blood drop design representing menstrual health and cycle tracking
class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? color;

  const AppLogo({super.key, this.size = 60, this.showText = false, this.color});

  @override
  Widget build(BuildContext context) {
    final logoColor = color ?? Theme.of(context).colorScheme.primary;

    if (showText) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLogoIcon(logoColor),
          const SizedBox(height: 8),
          Text(
            'CycleSync',
            style: TextStyle(
              fontSize: size * 0.3,
              fontWeight: FontWeight.bold,
              color: logoColor,
              letterSpacing: 1.2,
            ),
          ),
        ],
      );
    }

    return _buildLogoIcon(logoColor);
  }

  Widget _buildLogoIcon(Color logoColor) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [logoColor.withAlpha(230), logoColor.withAlpha(180)],
        ),
        boxShadow: [
          BoxShadow(
            color: logoColor.withAlpha(77),
            blurRadius: size * 0.2,
            spreadRadius: size * 0.05,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.45, size * 0.54),
          painter: BloodDropPainter(
            color: Colors.white,
            shadowColor: logoColor.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for the blood drop symbol representing menstrual health
class BloodDropPainter extends CustomPainter {
  final Color color;
  final Color shadowColor;

  BloodDropPainter({required this.color, required this.shadowColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = shadowColor
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    // Draw shadow first
    final shadowPath = _createDropPath(size, offset: const Offset(1, 2));
    canvas.drawPath(shadowPath, shadowPaint);

    // Draw main drop
    final path = _createDropPath(size);
    canvas.drawPath(path, paint);

    // Draw inner highlight curve
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    final highlightPath = Path();
    highlightPath.moveTo(size.width * 0.3, size.height * 0.2);
    highlightPath.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.15,
      size.width * 0.5,
      size.height * 0.25,
    );
    highlightPath.quadraticBezierTo(
      size.width * 0.45,
      size.height * 0.4,
      size.width * 0.35,
      size.height * 0.5,
    );
    highlightPath.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.35,
      size.width * 0.3,
      size.height * 0.2,
    );

    canvas.drawPath(highlightPath, highlightPaint);
  }

  Path _createDropPath(Size size, {Offset offset = Offset.zero}) {
    final path = Path();
    final width = size.width;
    final height = size.height;

    // Start at the top point of the drop
    path.moveTo(width / 2 + offset.dx, 0 + offset.dy);

    // Left side curve
    path.quadraticBezierTo(
      width * 0.1 + offset.dx,
      height * 0.3 + offset.dy,
      width * 0.15 + offset.dx,
      height * 0.6 + offset.dy,
    );

    // Bottom curve
    path.quadraticBezierTo(
      width * 0.2 + offset.dx,
      height * 0.9 + offset.dy,
      width / 2 + offset.dx,
      height + offset.dy,
    );

    // Right side curve
    path.quadraticBezierTo(
      width * 0.8 + offset.dx,
      height * 0.9 + offset.dy,
      width * 0.85 + offset.dx,
      height * 0.6 + offset.dy,
    );

    // Top right curve back to start
    path.quadraticBezierTo(
      width * 0.9 + offset.dx,
      height * 0.3 + offset.dy,
      width / 2 + offset.dx,
      0 + offset.dy,
    );

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// Alternative simpler logo design
class SimpleAppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? color;

  const SimpleAppLogo({
    super.key,
    this.size = 60,
    this.showText = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final logoColor = color ?? Theme.of(context).colorScheme.primary;

    if (showText) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSimpleIcon(logoColor),
          const SizedBox(width: 12),
          Text(
            'CycleSync',
            style: TextStyle(
              fontSize: size * 0.4,
              fontWeight: FontWeight.bold,
              color: logoColor,
              letterSpacing: 1.2,
            ),
          ),
        ],
      );
    }

    return _buildSimpleIcon(logoColor);
  }

  Widget _buildSimpleIcon(Color logoColor) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.2),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [logoColor, logoColor.withAlpha(204)],
        ),
        boxShadow: [
          BoxShadow(
            color: logoColor.withAlpha(77),
            blurRadius: size * 0.15,
            spreadRadius: size * 0.03,
            offset: Offset(0, size * 0.05),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.track_changes_rounded,
          size: size * 0.6,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Animated logo for splash screen or special occasions
class AnimatedAppLogo extends StatefulWidget {
  final double size;
  final bool showText;
  final Color? color;

  const AnimatedAppLogo({
    super.key,
    this.size = 60,
    this.showText = false,
    this.color,
  });

  @override
  State<AnimatedAppLogo> createState() => _AnimatedAppLogoState();
}

class _AnimatedAppLogoState extends State<AnimatedAppLogo>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_rotationAnimation, _pulseAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * 2 * 3.14159,
            child: AppLogo(
              size: widget.size,
              showText: widget.showText,
              color: widget.color,
            ),
          ),
        );
      },
    );
  }
}
