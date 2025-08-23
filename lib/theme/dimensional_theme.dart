import 'package:flutter/material.dart';
import 'dart:ui';

/// Dimensional design system for FlowSense app
/// Provides modern, dimensional UI elements with depth, shadows, and gradients
class DimensionalTheme {
  // DIMENSIONAL COLORS
  static const Map<String, List<Color>> gradients = {
    'primary': [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],
    'secondary': [Color(0xFF06B6D4), Color(0xFF3B82F6), Color(0xFF8B5CF6)],
    'health': [Color(0xFF10B981), Color(0xFF059669), Color(0xFF047857)],
    'warning': [Color(0xFFF59E0B), Color(0xFFEF4444), Color(0xFFDC2626)],
    'success': [Color(0xFF10B981), Color(0xFF059669)],
    'surface': [Color(0xFFFAFAFA), Color(0xFFF5F5F5), Color(0xFFE5E5E5)],
    'glass': [Color(0x20FFFFFF), Color(0x10FFFFFF), Color(0x05FFFFFF)],
  };

  // DIMENSIONAL SHADOWS
  static List<BoxShadow> getElevatedShadow(int level) {
    switch (level) {
      case 1:
        return [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, 1),
            blurRadius: 2,
            spreadRadius: 0,
          ),
        ];
      case 2:
        return [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            offset: const Offset(0, 4),
            blurRadius: 16,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            offset: const Offset(0, 2),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ];
      case 3:
        return [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            offset: const Offset(0, 8),
            blurRadius: 24,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            offset: const Offset(0, 4),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ];
      case 4:
        return [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            offset: const Offset(0, 16),
            blurRadius: 32,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            offset: const Offset(0, 8),
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ];
      default:
        return getElevatedShadow(2);
    }
  }

  // COLORED SHADOWS
  static List<BoxShadow> getColoredShadow(
    Color color, {
    double opacity = 0.25,
  }) {
    return [
      BoxShadow(
        color: color.withValues(alpha: opacity),
        offset: const Offset(0, 8),
        blurRadius: 20,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: color.withValues(alpha: opacity * 0.5),
        offset: const Offset(0, 4),
        blurRadius: 12,
        spreadRadius: 0,
      ),
    ];
  }

  // GLASS MORPHISM EFFECT
  static BoxDecoration getGlassEffect({
    Color? color,
    double opacity = 0.15,
    double blur = 20,
    Border? border,
  }) {
    return BoxDecoration(
      color: (color ?? Colors.white).withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(16),
      border:
          border ??
          Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          offset: const Offset(0, 8),
          blurRadius: blur,
        ),
      ],
    );
  }

  // DIMENSIONAL CARD
  static Widget getDimensionalCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? backgroundColor,
    List<Color>? gradient,
    int elevation = 2,
    BorderRadius? borderRadius,
    bool glassEffect = false,
    VoidCallback? onTap,
    BuildContext? context,
  }) {
    // Default colors based on theme
    Color defaultBg = Colors.white;
    if (context != null) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      defaultBg = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    }

    Widget cardWidget = Container(
      padding: padding ?? const EdgeInsets.all(20),
      margin: margin ?? const EdgeInsets.all(8),
      decoration: glassEffect
          ? getGlassEffect(
              color:
                  context != null &&
                      Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.15),
            )
          : BoxDecoration(
              color: backgroundColor ?? defaultBg,
              gradient: gradient != null
                  ? LinearGradient(
                      colors: gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              borderRadius: borderRadius ?? BorderRadius.circular(16),
              boxShadow: getElevatedShadow(elevation),
            ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(16),
          child: cardWidget,
        ),
      );
    }

    return cardWidget;
  }

  // DIMENSIONAL BUTTON
  static Widget getDimensionalButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    List<Color>? gradient,
    Color? textColor,
    double? fontSize,
    EdgeInsetsGeometry? padding,
    double borderRadius = 12,
    int elevation = 2,
    bool isLoading = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient ?? gradients['primary']!.take(2).toList(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: getColoredShadow(
          gradient?.first ?? gradients['primary']!.first,
          opacity: 0.3,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            padding:
                padding ??
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading) ...[
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        textColor ?? Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                if (icon != null && !isLoading) ...[
                  Icon(
                    icon,
                    color: textColor ?? Colors.white,
                    size: (fontSize ?? 16) + 2,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: TextStyle(
                    color: textColor ?? Colors.white,
                    fontSize: fontSize ?? 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // DIMENSIONAL PROGRESS INDICATOR
  static Widget getDimensionalProgress({
    double value = 0.7,
    List<Color>? gradient,
    double height = 12,
    String? label,
    String? valueText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null || valueText != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (label != null)
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                if (valueText != null)
                  Text(
                    valueText,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
              ],
            ),
          ),
        Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(height / 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                offset: const Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient ?? gradients['primary']!.take(2).toList(),
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(height / 2),
                boxShadow: [
                  BoxShadow(
                    color: (gradient?.first ?? gradients['primary']!.first)
                        .withValues(alpha: 0.3),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // DIMENSIONAL STAT CARD
  static Widget getDimensionalStatCard({
    required String title,
    required String value,
    required IconData icon,
    List<Color>? gradient,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return getDimensionalCard(
      elevation: 2,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient ?? gradients['primary']!.take(2).toList(),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: getColoredShadow(
                gradient?.first ?? gradients['primary']!.first,
                opacity: 0.25,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.black45),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing],
        ],
      ),
    );
  }

  // DIMENSIONAL HEADER
  static Widget getDimensionalHeader({
    required String title,
    String? subtitle,
    IconData? icon,
    List<Color>? gradient,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient ?? gradients['primary']!,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: getColoredShadow(
          gradient?.first ?? gradients['primary']!.first,
          opacity: 0.3,
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}

/// DimensionalCard widget for easy use
class DimensionalCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final List<Color>? gradient;
  final int elevation;
  final BorderRadius? borderRadius;
  final bool glassEffect;
  final VoidCallback? onTap;

  const DimensionalCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.gradient,
    this.elevation = 2,
    this.borderRadius,
    this.glassEffect = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBgColor =
        backgroundColor ?? (isDark ? const Color(0xFF2A2A2A) : Colors.white);

    return DimensionalTheme.getDimensionalCard(
      child: child,
      padding: padding,
      margin: margin,
      backgroundColor: defaultBgColor,
      gradient: gradient,
      elevation: elevation,
      borderRadius: borderRadius,
      glassEffect: glassEffect,
      onTap: onTap,
    );
  }
}

/// DimensionalContainer widget for small elements
class DimensionalContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final int elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const DimensionalContainer({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation = 1,
    this.borderRadius,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget container = Container(
      padding: padding ?? const EdgeInsets.all(8),
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        boxShadow: DimensionalTheme.getElevatedShadow(elevation),
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
          child: container,
        ),
      );
    }

    return container;
  }
}
