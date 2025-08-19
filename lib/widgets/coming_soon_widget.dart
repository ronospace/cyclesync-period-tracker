import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../theme/app_theme.dart';

class ComingSoonWidget extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final String? estimatedDate;
  final String? status;
  final List<String>? features;
  final VoidCallback? onInterested;
  final Color? accentColor;
  final bool showDetails;

  const ComingSoonWidget({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.estimatedDate,
    this.status = 'Coming Soon',
    this.features,
    this.onInterested,
    this.accentColor,
    this.showDetails = false,
  });

  @override
  State<ComingSoonWidget> createState() => _ComingSoonWidgetState();
}

class _ComingSoonWidgetState extends State<ComingSoonWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.accentColor ?? AppTheme.primaryPink;

    return GestureDetector(
      onTapDown: (_) {
        _animationController.forward();
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      onTap: widget.showDetails ? _toggleExpanded : widget.onInterested,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.05),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        _buildShimmerEffect(),
                        _buildContent(accentColor),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [
                  _shimmerAnimation.value - 0.3,
                  _shimmerAnimation.value,
                  _shimmerAnimation.value + 0.3,
                ],
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(Color accentColor) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildAnimatedIcon(accentColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(accentColor),
            ],
          ),
          if (widget.estimatedDate != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: Colors.white.withOpacity(0.7),
                ),
                const SizedBox(width: 8),
                Text(
                  'Expected: ${widget.estimatedDate}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.7),
                      ),
                ),
              ],
            ),
          ],
          if (_isExpanded && widget.features != null) ...[
            const SizedBox(height: 16),
            _buildFeaturesList(),
          ],
          if (widget.onInterested != null || widget.showDetails) ...[
            const SizedBox(height: 16),
            _buildActionButtons(accentColor),
          ],
        ],
      ),
    );
  }

  Widget _buildAnimatedIcon(Color accentColor) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.2 + 0.1 * _pulseAnimation.value),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: accentColor.withOpacity(0.5 + 0.3 * _pulseAnimation.value),
              width: 2,
            ),
          ),
          child: Icon(
            widget.icon,
            size: 24,
            color: Colors.white,
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: accentColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        widget.status!,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFeaturesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Planned Features:',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        ...widget.features!.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.7),
                          ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildActionButtons(Color accentColor) {
    return Row(
      children: [
        if (widget.showDetails)
          TextButton.icon(
            onPressed: _toggleExpanded,
            icon: Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              color: Colors.white,
            ),
            label: Text(
              _isExpanded ? 'Show Less' : 'Show Details',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        const Spacer(),
        if (widget.onInterested != null)
          ElevatedButton(
            onPressed: widget.onInterested,
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Notify Me'),
          ),
      ],
    );
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    HapticFeedback.selectionClick();
  }
}

class ComingSoonSection extends StatelessWidget {
  final String title;
  final List<ComingSoonWidget> features;
  final EdgeInsets? padding;

  const ComingSoonSection({
    super.key,
    required this.title,
    required this.features,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryPink,
                  ),
            ),
          ),
          ...features,
        ],
      ),
    );
  }
}

// Predefined coming soon features for quick usage
class ComingSoonFeatures {
  static const aiPoweredPredictions = ComingSoonWidget(
    title: 'AI-Powered Predictions',
    description: 'Advanced machine learning algorithms to predict your cycle with 99% accuracy',
    icon: Icons.psychology,
    estimatedDate: 'Q2 2024',
    status: 'In Development',
    accentColor: Colors.purple,
    showDetails: true,
    features: [
      'Machine learning cycle prediction',
      'Symptom pattern recognition',
      'Personalized health insights',
      'Fertility window optimization',
    ],
  );

  static const voiceAssistant = ComingSoonWidget(
    title: 'Voice Assistant',
    description: 'Log symptoms and ask questions using natural voice commands',
    icon: Icons.record_voice_over,
    estimatedDate: 'Q3 2024',
    status: 'Coming Soon',
    accentColor: Colors.blue,
    showDetails: true,
    features: [
      'Natural language processing',
      'Voice symptom logging',
      'Conversational AI health coach',
      'Hands-free period tracking',
    ],
  );

  static const arVisualizations = ComingSoonWidget(
    title: 'AR Visualizations',
    description: 'Augmented reality educational content and cycle visualization',
    icon: Icons.view_in_ar,
    estimatedDate: 'Q4 2024',
    status: 'Research Phase',
    accentColor: Colors.orange,
    showDetails: true,
    features: [
      '3D cycle visualizations',
      'Interactive anatomy models',
      'AR health education',
      'Immersive cycle calendar',
    ],
  );

  static const smartWearables = ComingSoonWidget(
    title: 'Smart Wearable Integration',
    description: 'Seamless integration with fitness trackers and smartwatches',
    icon: Icons.watch,
    estimatedDate: 'Q1 2024',
    status: 'Beta Testing',
    accentColor: Colors.green,
    showDetails: true,
    features: [
      'Apple Watch integration',
      'Fitbit synchronization',
      'Heart rate variability tracking',
      'Sleep pattern analysis',
    ],
  );

  static const advancedAnalytics = ComingSoonWidget(
    title: 'Advanced Analytics',
    description: 'Professional-grade health analytics and reporting',
    icon: Icons.analytics,
    estimatedDate: 'Q2 2024',
    status: 'Design Phase',
    accentColor: Colors.indigo,
    showDetails: true,
    features: [
      'Comprehensive health reports',
      'Trend analysis dashboard',
      'Medical-grade insights',
      'Doctor-sharable reports',
    ],
  );
}
