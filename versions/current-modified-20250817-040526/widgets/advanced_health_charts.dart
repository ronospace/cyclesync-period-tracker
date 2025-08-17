import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/advanced_health_kit_service.dart';
import '../theme/app_theme.dart';
import 'dart:math' as math;

/// Advanced health data visualization widgets using fl_chart
/// Creates beautiful, interactive charts for health metrics
class AdvancedHealthCharts {
  
  /// Heart Rate Line Chart with gradient and interactive tooltips
  static Widget buildHeartRateChart(List<HealthDataPoint> data, {double height = 300}) {
    if (data.isEmpty) {
      return _buildNoDataChart('No heart rate data available');
    }

    // Prepare data points for the chart
    final spots = <FlSpot>[];
    final minTime = data.first.date.millisecondsSinceEpoch.toDouble();
    
    for (int i = 0; i < data.length; i++) {
      final timeOffset = data[i].date.millisecondsSinceEpoch.toDouble() - minTime;
      spots.add(FlSpot(timeOffset / (1000 * 60 * 60), data[i].value)); // Hours on X-axis
    }

    final minY = data.map((d) => d.value).reduce(math.min);
    final maxY = data.map((d) => d.value).reduce(math.max);
    final padding = (maxY - minY) * 0.1;

    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 20,
            verticalInterval: 6,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            ),
            getDrawingVerticalLine: (value) => FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 6,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      '${value.toInt()}h',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w300,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 20,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(
                    '${value.toInt()}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w300,
                      fontSize: 12,
                    ),
                  );
                },
                reservedSize: 42,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
          minX: 0,
          maxX: spots.isNotEmpty ? spots.last.x + 1 : 24,
          minY: minY - padding,
          maxY: maxY + padding,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              gradient: LinearGradient(
                colors: [
                  Colors.red.withOpacity(0.8),
                  Colors.red.withOpacity(0.3),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                      radius: 4,
                      color: Colors.red,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.red.withOpacity(0.3),
                    Colors.red.withOpacity(0.1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.red.withOpacity(0.9),
              tooltipRoundedRadius: 8,
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  final flSpot = barSpot;
                  return LineTooltipItem(
                    '${flSpot.y.round()} bpm\n${flSpot.x.toStringAsFixed(1)}h ago',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  /// HRV (Heart Rate Variability) Bar Chart with stress level indicators
  static Widget buildHRVChart(List<HealthDataPoint> data, {double height = 300}) {
    if (data.isEmpty) {
      return _buildNoDataChart('No HRV data available');
    }

    final barGroups = <BarChartGroupData>[];
    for (int i = 0; i < data.length && i < 12; i++) {
      final hrv = data[i].value;
      Color barColor;
      
      // Color coding based on HRV values (stress levels)
      if (hrv >= 40) {
        barColor = Colors.green; // Low stress
      } else if (hrv >= 30) {
        barColor = Colors.orange; // Moderate stress
      } else if (hrv >= 20) {
        barColor = Colors.red.shade300; // Elevated stress
      } else {
        barColor = Colors.red; // High stress
      }

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: hrv,
              color: barColor,
              width: 16,
              borderRadius: BorderRadius.circular(4),
              gradient: LinearGradient(
                colors: [barColor.withOpacity(0.7), barColor],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Legend
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _buildLegendItem(Colors.green, 'Low (>40ms)'),
              _buildLegendItem(Colors.orange, 'Moderate (30-40ms)'),
              _buildLegendItem(Colors.red, 'High (<20ms)'),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 60,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.blueGrey,
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final hrv = rod.toY;
                      String stressLevel;
                      if (hrv >= 40) stressLevel = 'Low Stress';
                      else if (hrv >= 30) stressLevel = 'Moderate';
                      else if (hrv >= 20) stressLevel = 'Elevated';
                      else stressLevel = 'High Stress';
                      
                      return BarTooltipItem(
                        '${hrv.round()}ms\n$stressLevel',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'T${value.toInt() + 1}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w300,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 10,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            '${value.toInt()}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w300,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: barGroups,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Sleep Pattern Pie Chart with sleep stages
  static Widget buildSleepChart(List<SleepData> data, {double height = 300}) {
    if (data.isEmpty) {
      return _buildNoDataChart('No sleep data available');
    }

    // Calculate sleep stage durations
    Map<String, double> stageDurations = {};
    for (var sleep in data) {
      final stage = sleep.stage;
      final hours = sleep.durationSeconds / 3600; // Convert seconds to hours
      stageDurations[stage] = (stageDurations[stage] ?? 0) + hours;
    }

    final sections = <PieChartSectionData>[];
    final colors = {
      'deep': Colors.indigo,
      'core': Colors.blue,
      'rem': Colors.purple,
      'light': Colors.lightBlue,
      'asleep': Colors.blue.shade300,
      'awake': Colors.red.shade300,
      'inBed': Colors.grey,
    };

    int index = 0;
    stageDurations.forEach((stage, duration) {
      final color = colors[stage] ?? Colors.grey;
      sections.add(
        PieChartSectionData(
          color: color,
          value: duration,
          title: '${duration.toStringAsFixed(1)}h',
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          titlePositionPercentageOffset: 0.6,
        ),
      );
      index++;
    });

    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Legend
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: stageDurations.entries.map((entry) {
              final color = colors[entry.key] ?? Colors.grey;
              return _buildLegendItem(
                color, 
                '${entry.key.toUpperCase()}: ${entry.value.toStringAsFixed(1)}h'
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                  enabled: true,
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: sections,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Temperature Trend Chart with ovulation detection
  static Widget buildTemperatureChart(List<HealthDataPoint> data, {double height = 300}) {
    if (data.isEmpty) {
      return _buildNoDataChart('No temperature data available');
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[i].value));
    }

    final minY = data.map((d) => d.value).reduce(math.min);
    final maxY = data.map((d) => d.value).reduce(math.max);
    final avgTemp = data.map((d) => d.value).reduce((a, b) => a + b) / data.length;

    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 0.2,
            verticalInterval: 1,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            ),
            getDrawingVerticalLine: (value) => FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      'D${value.toInt() + 1}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w300,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 0.2,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(
                    value.toStringAsFixed(1),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w300,
                      fontSize: 12,
                    ),
                  );
                },
                reservedSize: 42,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
          minX: 0,
          maxX: data.length.toDouble() - 1,
          minY: minY - 0.2,
          maxY: maxY + 0.2,
          lineBarsData: [
            // Temperature line
            LineChartBarData(
              spots: spots,
              isCurved: true,
              gradient: LinearGradient(
                colors: [
                  Colors.orange.withOpacity(0.8),
                  Colors.red.withOpacity(0.6),
                ],
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  // Highlight potential ovulation points (temperature spikes)
                  bool isOvulationPoint = false;
                  if (index > 2 && index < data.length - 1) {
                    final current = data[index].value;
                    final recent = data.sublist(index - 3, index).map((d) => d.value);
                    final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
                    isOvulationPoint = current - recentAvg >= 0.2;
                  }
                  
                  return FlDotCirclePainter(
                    radius: isOvulationPoint ? 6 : 4,
                    color: isOvulationPoint ? Colors.purple : Colors.orange,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.withOpacity(0.2),
                    Colors.orange.withOpacity(0.05),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Average line
            LineChartBarData(
              spots: List.generate(
                data.length,
                (index) => FlSpot(index.toDouble(), avgTemp),
              ),
              isCurved: false,
              color: Colors.grey,
              barWidth: 1,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              dashArray: [5, 5],
            ),
          ],
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.orange.withOpacity(0.9),
              tooltipRoundedRadius: 8,
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  final flSpot = barSpot;
                  return LineTooltipItem(
                    '${flSpot.y.toStringAsFixed(2)}°C\nDay ${flSpot.x.toInt() + 1}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: avgTemp,
                color: Colors.grey,
                strokeWidth: 1,
                dashArray: [5, 5],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  padding: const EdgeInsets.only(right: 5, bottom: 5),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 10,
                  ),
                  labelResolver: (line) => 'Avg: ${avgTemp.toStringAsFixed(2)}°C',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Activity Radar Chart showing daily activity metrics
  static Widget buildActivityChart(List<ActivityData> data, {double height = 300}) {
    if (data.isEmpty) {
      return _buildNoDataChart('No activity data available');
    }

    // Calculate averages and create sections
    final avgSteps = data.map((d) => d.steps).reduce((a, b) => a + b) / data.length;
    final avgEnergy = data.map((d) => d.activeEnergy).reduce((a, b) => a + b) / data.length;

    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Activity Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildActivityCard(
                  'Average Steps',
                  '${avgSteps.toInt()}',
                  Icons.directions_walk,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActivityCard(
                  'Active Energy',
                  '${avgEnergy.toInt()} cal',
                  Icons.local_fire_department,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Steps trend chart
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: data.map((d) => d.steps).reduce(math.max),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.blue.withOpacity(0.9),
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toInt()} steps\nDay ${groupIndex + 1}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'D${value.toInt() + 1}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w300,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            value >= 1000 ? '${(value / 1000).toStringAsFixed(1)}k' : '${value.toInt()}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w300,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(data.length, (index) {
                  final steps = data[index].steps;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: steps,
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.withOpacity(0.7),
                            Colors.blue,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: 16,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2000,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widgets
  static Widget _buildNoDataChart(String message) {
    return Container(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildLegendItem(Color color, String text) {
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
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }

  static Widget _buildActivityCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
