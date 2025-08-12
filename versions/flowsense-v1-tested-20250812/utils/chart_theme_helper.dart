import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';
import '../theme/app_theme.dart';

/// Helper utility for creating theme-aware charts with consistent styling
class ChartThemeHelper {
  
  /// Get theme-aware chart colors
  static Map<String, Color> getChartColors(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context, listen: false);
    return themeService.getChartColors(context);
  }
  
  /// Get theme-aware calendar colors  
  static Map<String, Color> getCalendarColors(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context, listen: false);
    return themeService.getCalendarColors(context);
  }
  
  /// Get health-specific colors (theme independent)
  static Map<String, Color> getHealthColors() {
    return AppTheme.healthColors;
  }
  
  /// Create theme-aware grid data for charts
  static FlGridData createGridData(BuildContext context, {
    bool showVerticalLines = true,
    bool showHorizontalLines = true,
    double horizontalInterval = 1.0,
    double verticalInterval = 1.0,
  }) {
    final colors = getChartColors(context);
    
    return FlGridData(
      show: true,
      drawVerticalLine: showVerticalLines,
      drawHorizontalLine: showHorizontalLines,
      horizontalInterval: horizontalInterval,
      verticalInterval: verticalInterval,
      getDrawingHorizontalLine: (value) => FlLine(
        color: colors['grid'] ?? Colors.grey.withOpacity(0.2),
        strokeWidth: 1,
      ),
      getDrawingVerticalLine: (value) => FlLine(
        color: colors['grid'] ?? Colors.grey.withOpacity(0.2),
        strokeWidth: 1,
      ),
    );
  }
  
  /// Create theme-aware border data for charts
  static FlBorderData createBorderData(BuildContext context) {
    final colors = getChartColors(context);
    
    return FlBorderData(
      show: true,
      border: Border.all(
        color: colors['grid'] ?? Colors.grey.withOpacity(0.2),
        width: 1,
      ),
    );
  }
  
  /// Create theme-aware titles data for charts
  static FlTitlesData createTitlesData(BuildContext context, {
    bool showLeftTitles = true,
    bool showBottomTitles = true,
    bool showRightTitles = false,
    bool showTopTitles = false,
    double leftReservedSize = 40,
    double bottomReservedSize = 30,
    Widget Function(double, TitleMeta)? leftTitleWidget,
    Widget Function(double, TitleMeta)? bottomTitleWidget,
  }) {
    final colors = getChartColors(context);
    
    return FlTitlesData(
      show: true,
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: showRightTitles)),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: showTopTitles)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: showBottomTitles,
          reservedSize: bottomReservedSize,
          getTitlesWidget: bottomTitleWidget ?? (value, meta) {
            return Text(
              value.toInt().toString(),
              style: TextStyle(
                color: colors['textSecondary'],
                fontSize: 12,
                fontWeight: FontWeight.w300,
              ),
            );
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: showLeftTitles,
          reservedSize: leftReservedSize,
          getTitlesWidget: leftTitleWidget ?? (value, meta) {
            return Text(
              value.toInt().toString(),
              style: TextStyle(
                color: colors['textSecondary'],
                fontSize: 12,
                fontWeight: FontWeight.w300,
              ),
            );
          },
        ),
      ),
    );
  }
  
  /// Create theme-aware tooltip data for line charts
  static LineTouchTooltipData createLineTooltipData(BuildContext context, {
    Color? backgroundColor,
    List<LineTooltipItem?> Function(List<LineBarSpot>)? tooltipItems,
  }) {
    final colors = getChartColors(context);
    
    return LineTouchTooltipData(
      tooltipBgColor: backgroundColor ?? colors['surface']?.withOpacity(0.9),
      tooltipRoundedRadius: 8,
      getTooltipItems: tooltipItems ?? (touchedSpots) {
        return touchedSpots.map((spot) {
          return LineTooltipItem(
            '${spot.y.toStringAsFixed(1)}',
            TextStyle(
              color: colors['text'],
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          );
        }).toList();
      },
    );
  }
  
  /// Create theme-aware tooltip data for bar charts
  static BarTouchTooltipData createBarTooltipData(BuildContext context, {
    Color? backgroundColor,
    BarTooltipItem? Function(BarChartGroupData, int, BarChartRodData, int)? tooltipItem,
  }) {
    final colors = getChartColors(context);
    
    return BarTouchTooltipData(
      tooltipBgColor: backgroundColor ?? colors['surface']?.withOpacity(0.9),
      tooltipRoundedRadius: 8,
      getTooltipItem: tooltipItem ?? (group, groupIndex, rod, rodIndex) {
        return BarTooltipItem(
          '${rod.toY.toStringAsFixed(1)}',
          TextStyle(
            color: colors['text'],
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        );
      },
    );
  }
  
  /// Get gradient colors for different chart types
  static LinearGradient getChartGradient(BuildContext context, String chartType) {
    final colors = getChartColors(context);
    
    switch (chartType) {
      case 'heartRate':
        final color = colors['heartRate'] ?? Colors.red;
        return LinearGradient(
          colors: [color.withOpacity(0.8), color.withOpacity(0.3)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case 'hrv':
        final color = colors['hrv'] ?? Colors.blue;
        return LinearGradient(
          colors: [color.withOpacity(0.8), color.withOpacity(0.3)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case 'sleep':
        final color = colors['sleep'] ?? Colors.purple;
        return LinearGradient(
          colors: [color.withOpacity(0.8), color.withOpacity(0.3)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case 'temperature':
        final color = colors['temperature'] ?? Colors.orange;
        return LinearGradient(
          colors: [color.withOpacity(0.8), color.withOpacity(0.3)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case 'activity':
        final color = colors['activity'] ?? Colors.green;
        return LinearGradient(
          colors: [color.withOpacity(0.8), color.withOpacity(0.3)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      default:
        return LinearGradient(
          colors: [Colors.blue.withOpacity(0.8), Colors.blue.withOpacity(0.3)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
    }
  }
  
  /// Create theme-aware card container for charts
  static Widget createChartContainer(BuildContext context, Widget chart, {
    String? title,
    String? subtitle,
    double height = 300,
    EdgeInsets padding = const EdgeInsets.all(16),
  }) {
    final colors = getChartColors(context);
    
    return Card(
      elevation: AppTheme.elevationMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      color: colors['surface'],
      child: Container(
        height: height + (title != null ? 60 : 0),
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors['text'],
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: colors['textSecondary'],
                  ),
                ),
              const SizedBox(height: 16),
            ],
            Expanded(child: chart),
          ],
        ),
      ),
    );
  }
  
  /// Create theme-aware legend item
  static Widget createLegendItem(BuildContext context, Color color, String text) {
    final colors = getChartColors(context);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: colors['textSecondary'],
          ),
        ),
      ],
    );
  }
  
  /// Create no data widget with theme-aware colors
  static Widget createNoDataWidget(BuildContext context, String message) {
    final colors = getChartColors(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 48,
            color: colors['textSecondary']?.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: colors['textSecondary'],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
