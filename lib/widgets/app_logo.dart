import 'package:flutter/material.dart';
import 'dart:math' as math;

/// CycleSync app logo widget
/// A beautiful, theme-aware logo that represents menstrual health and cycle tracking
class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? color;

  const AppLogo({
    super.key,
    this.size = 60,
    this.showText = false,
    this.color,
  });

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
          colors: [
            logoColor.withAlpha(230),
            logoColor.withAlpha(180),
          ],
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
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring representing the cycle
          Container(
            width: size * 0.85,
            height: size * 0.85,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withAlpha(179),
                width: size * 0.04,
              ),
            ),
          ),
          
          // Inner flower/bloom symbol
          Container(
            width: size * 0.5,
            height: size * 0.5,
            child: CustomPaint(
              painter: FlowerPainter(
                color: Colors.white,
                strokeWidth: size * 0.04,
              ),
            ),
          ),
          
          // Center dot
          Container(
            width: size * 0.15,
            height: size * 0.15,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for the flower/bloom symbol in the center
class FlowerPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  FlowerPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;

    // Draw 5 petals forming a flower
    for (int i = 0; i < 5; i++) {
      final angle = (i * 72) * (3.14159 / 180); // 72 degrees apart
      final petalEnd = Offset(
        center.dx + radius * 0.8 * math.cos(angle),
        center.dy + radius * 0.8 * math.sin(angle),
      );
      
      // Draw petal as a curved path
      final path = Path();
      path.moveTo(center.dx, center.dy);
      
      // Control points for smooth curves
      final control1 = Offset(
        center.dx + radius * 0.3 * math.cos(angle - 0.5),
        center.dy + radius * 0.3 * math.sin(angle - 0.5),
      );
      final control2 = Offset(
        center.dx + radius * 0.3 * math.cos(angle + 0.5),
        center.dy + radius * 0.3 * math.sin(angle + 0.5),
      );
      
      path.quadraticBezierTo(control1.dx, control1.dy, petalEnd.dx, petalEnd.dy);
      path.quadraticBezierTo(control2.dx, control2.dy, center.dx, center.dy);
      
      canvas.drawPath(path, paint);
    }
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
          colors: [
            logoColor,
            logoColor.withAlpha(204),
          ],
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

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
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

