import 'package:flutter/material.dart';
import 'dart:math' as math;

/// AI Assistant Avatar that provides contextual insights and help
class AIAssistantAvatar extends StatefulWidget {
  final VoidCallback? onTap;
  final bool isActive;
  final bool hasNotification;
  final String? statusMessage;

  const AIAssistantAvatar({
    super.key,
    this.onTap,
    this.isActive = false,
    this.hasNotification = false,
    this.statusMessage,
  });

  @override
  State<AIAssistantAvatar> createState() => _AIAssistantAvatarState();
}

class _AIAssistantAvatarState extends State<AIAssistantAvatar>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _glowController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for breathing effect
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Rotation animation for active state
    _rotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    // Glow animation for notifications
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _startAnimations();
  }

  void _startAnimations() {
    _pulseController.repeat(reverse: true);

    if (widget.isActive) {
      _rotationController.repeat();
    }

    if (widget.hasNotification) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AIAssistantAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _rotationController.repeat();
      } else {
        _rotationController.stop();
      }
    }

    if (widget.hasNotification != oldWidget.hasNotification) {
      if (widget.hasNotification) {
        _glowController.repeat(reverse: true);
      } else {
        _glowController.stop();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _pulseAnimation,
          _rotationAnimation,
          _glowAnimation,
        ]),
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.isActive
                        ? Colors.deepPurple.withValues(alpha: 0.9)
                        : Colors.blue.withValues(alpha: 0.8),
                    widget.isActive
                        ? Colors.indigo.withValues(alpha: 0.9)
                        : Colors.blueAccent.withValues(alpha: 0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.hasNotification
                        ? Colors.amber.withValues(
                            alpha: _glowAnimation.value * 0.6,
                          )
                        : Colors.blue.withValues(alpha: 0.3),
                    blurRadius: widget.hasNotification ? 20 : 10,
                    spreadRadius: widget.hasNotification ? 5 : 2,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background gradient overlay
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  // AI Brain icon with rotation
                  Transform.rotate(
                    angle: widget.isActive ? _rotationAnimation.value : 0,
                    child: Icon(
                      Icons.psychology_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  // Notification indicator
                  if (widget.hasNotification)
                    Positioned(
                      top: 5,
                      right: 5,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.amber,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withValues(alpha: 0.6),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
