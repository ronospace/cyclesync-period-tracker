import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/enhanced_analytics_service.dart';

/// 🚀 Enhanced Chart Widgets for Mission Alpha
/// Interactive visualizations for wellbeing trends and correlations

class WellbeingTrendChart extends StatefulWidget {
  final WellbeingTrends trends;
  final String selectedMetric;
  final Function(String) onMetricChanged;

  const WellbeingTrendChart({
    super.key,
    required this.trends,
    required this.selectedMetric,
    required this.onMetricChanged,
  });

  @override
  State<WellbeingTrendChart> createState() => _WellbeingTrendChartState();
}

class _WellbeingTrendChartState extends State<WellbeingTrendChart> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.selectedMetric} Trends',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getMetricColor(widget.selectedMetric),
                  ),
                ),
                _buildMetricSelector(),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(height: 250, child: _buildChart()),
            const SizedBox(height: 16),
            _buildMetricSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricSelector() {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'Mood', label: Text('Mood')),
        ButtonSegment(value: 'Energy', label: Text('Energy')),
        ButtonSegment(value: 'Pain', label: Text('Pain')),
      ],
      selected: {widget.selectedMetric},
      onSelectionChanged: (Set<String> newSelection) {
        widget.onMetricChanged(newSelection.first);
      },
    );
  }

  Widget _buildChart() {
    final trendData = _getTrendData();
    if (trendData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No data available yet',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 1,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey[300]!, strokeWidth: 0.5);
          },
          getDrawingVerticalLine: (value) {
            return FlLine(color: Colors.grey[300]!, strokeWidth: 0.5);
          },
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
              getTitlesWidget: (value, meta) {
                if (value.toInt() < 0 || value.toInt() >= trendData.length) {
                  return const Text('');
                }
                final date = trendData[value.toInt()].date;
                return SideTitleWidget(
                  child: Text(
                    '${date.month}/${date.day}',
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 12),
                );
              },
              reservedSize: 30,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        minX: 0,
        maxX: trendData.length > 1 ? (trendData.length - 1).toDouble() : 1,
        minY: 0,
        maxY: 5,
        lineBarsData: [
          LineChartBarData(
            spots: trendData
                .asMap()
                .entries
                .map((entry) => FlSpot(entry.key.toDouble(), entry.value.value))
                .toList(),
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                _getMetricColor(widget.selectedMetric).withValues(alpha: 0.5),
                _getMetricColor(widget.selectedMetric),
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: index == touchedIndex ? 6 : 3,
                  color: _getMetricColor(widget.selectedMetric),
                  strokeWidth: index == touchedIndex ? 3 : 1,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _getMetricColor(widget.selectedMetric).withValues(alpha: 0.3),
                  _getMetricColor(widget.selectedMetric).withValues(alpha: 0.1),
                ],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchCallback:
              (FlTouchEvent event, LineTouchResponse? touchResponse) {
                setState(() {
                  if (touchResponse != null &&
                      touchResponse.lineBarSpots != null &&
                      touchResponse.lineBarSpots!.isNotEmpty) {
                    touchedIndex = touchResponse.lineBarSpots!.first.spotIndex;
                  } else {
                    touchedIndex = null;
                  }
                });
              },
          getTouchedSpotIndicator:
              (LineChartBarData barData, List<int> spotIndexes) {
                return spotIndexes.map((spotIndex) {
                  return TouchedSpotIndicatorData(
                    FlLine(
                      color: _getMetricColor(widget.selectedMetric),
                      strokeWidth: 2,
                    ),
                    FlDotData(
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 8,
                          color: _getMetricColor(widget.selectedMetric),
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                  );
                }).toList();
              },
          touchTooltipData: LineTouchTooltipData(
            backgroundColor: _getMetricColor(
              widget.selectedMetric,
            ).withValues(alpha: 0.9),
            tooltipRoundedRadius: 8,
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final flSpot = barSpot;
                if (flSpot.x.toInt() >= 0 &&
                    flSpot.x.toInt() < trendData.length) {
                  final date = trendData[flSpot.x.toInt()].date;
                  return LineTooltipItem(
                    '${widget.selectedMetric}: ${flSpot.y.toStringAsFixed(1)}\n${date.month}/${date.day}/${date.year}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }
                return null;
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMetricSummary() {
    final average = _getAverageValue();
    final trend = _calculateTrend();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getMetricColor(widget.selectedMetric).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            'Average',
            average.toStringAsFixed(1),
            Icons.analytics,
          ),
          _buildSummaryItem(
            'Trend',
            trend > 0
                ? 'Improving'
                : trend < 0
                ? 'Declining'
                : 'Stable',
            trend > 0
                ? Icons.trending_up
                : trend < 0
                ? Icons.trending_down
                : Icons.trending_flat,
          ),
          _buildSummaryItem(
            'Records',
            _getTrendData().length.toString(),
            Icons.data_usage,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: _getMetricColor(widget.selectedMetric), size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _getMetricColor(widget.selectedMetric),
            fontSize: 16,
          ),
        ),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  List<TrendPoint> _getTrendData() {
    switch (widget.selectedMetric) {
      case 'Mood':
        return widget.trends.moodTrend;
      case 'Energy':
        return widget.trends.energyTrend;
      case 'Pain':
        return widget.trends.painTrend;
      default:
        return [];
    }
  }

  double _getAverageValue() {
    switch (widget.selectedMetric) {
      case 'Mood':
        return widget.trends.averageMood;
      case 'Energy':
        return widget.trends.averageEnergy;
      case 'Pain':
        return widget.trends.averagePain;
      default:
        return 0.0;
    }
  }

  double _calculateTrend() {
    final data = _getTrendData();
    if (data.length < 2) return 0.0;

    final firstHalf = data.take(data.length ~/ 2);
    final secondHalf = data.skip(data.length ~/ 2);

    final firstAvg =
        firstHalf.map((p) => p.value).reduce((a, b) => a + b) /
        firstHalf.length;
    final secondAvg =
        secondHalf.map((p) => p.value).reduce((a, b) => a + b) /
        secondHalf.length;

    return secondAvg - firstAvg;
  }

  Color _getMetricColor(String metric) {
    switch (metric) {
      case 'Mood':
        return const Color(0xFF4CAF50); // Green
      case 'Energy':
        return const Color(0xFF2196F3); // Blue
      case 'Pain':
        return const Color(0xFFF44336); // Red
      default:
        return Colors.grey;
    }
  }
}

class SymptomCorrelationHeatmap extends StatefulWidget {
  final SymptomCorrelationMatrix matrix;

  const SymptomCorrelationHeatmap({super.key, required this.matrix});

  @override
  State<SymptomCorrelationHeatmap> createState() =>
      _SymptomCorrelationHeatmapState();
}

class _SymptomCorrelationHeatmapState extends State<SymptomCorrelationHeatmap> {
  String? selectedSymptom1;
  String? selectedSymptom2;
  double? selectedCorrelation;

  @override
  Widget build(BuildContext context) {
    if (widget.matrix.symptoms.isEmpty) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(Icons.grid_view, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No symptom data available yet',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Symptom Correlation Heatmap',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Discover which symptoms tend to occur together',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            _buildHeatmap(),
            if (selectedSymptom1 != null && selectedSymptom2 != null) ...[
              const SizedBox(height: 16),
              _buildCorrelationDetails(),
            ],
            const SizedBox(height: 16),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmap() {
    final symptoms = widget.matrix.symptoms;
    final cellSize = (MediaQuery.of(context).size.width - 80) / symptoms.length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column headers
          Row(
            children: [
              SizedBox(width: cellSize), // Space for row headers
              ...symptoms.map(
                (symptom) => SizedBox(
                  width: cellSize,
                  height: 40,
                  child: Center(
                    child: RotatedBox(
                      quarterTurns: 1,
                      child: Text(
                        symptom,
                        style: const TextStyle(fontSize: 10),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Heatmap cells
          ...symptoms.asMap().entries.map((entry) {
            final rowIndex = entry.key;
            final rowSymptom = entry.value;

            return Row(
              children: [
                // Row header
                SizedBox(
                  width: cellSize,
                  height: cellSize,
                  child: Center(
                    child: Text(
                      rowSymptom,
                      style: const TextStyle(fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                // Correlation cells
                ...symptoms.asMap().entries.map((colEntry) {
                  final colIndex = colEntry.key;
                  final colSymptom = colEntry.value;
                  final correlation = widget.matrix.getCorrelation(
                    rowSymptom,
                    colSymptom,
                  );

                  return GestureDetector(
                    onTap: () =>
                        _selectCell(rowSymptom, colSymptom, correlation),
                    child: Container(
                      width: cellSize,
                      height: cellSize,
                      decoration: BoxDecoration(
                        color: _getCorrelationColor(correlation),
                        border: Border.all(
                          color:
                              (selectedSymptom1 == rowSymptom &&
                                      selectedSymptom2 == colSymptom) ||
                                  (selectedSymptom1 == colSymptom &&
                                      selectedSymptom2 == rowSymptom)
                              ? Colors.black
                              : Colors.grey[300]!,
                          width:
                              (selectedSymptom1 == rowSymptom &&
                                      selectedSymptom2 == colSymptom) ||
                                  (selectedSymptom1 == colSymptom &&
                                      selectedSymptom2 == rowSymptom)
                              ? 2
                              : 0.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          correlation.abs() > 0.1
                              ? correlation.toStringAsFixed(2)
                              : '',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: correlation.abs() > 0.5
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCorrelationDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Correlation Details',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '$selectedSymptom1 ↔ $selectedSymptom2',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                'Correlation: ${selectedCorrelation?.toStringAsFixed(3) ?? 'N/A'}',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 16),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: _getCorrelationColor(selectedCorrelation ?? 0),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey[400]!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getCorrelationDescription(selectedCorrelation ?? 0),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Correlation Strength',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildLegendItem('Strong Positive', _getCorrelationColor(0.8)),
            _buildLegendItem('Moderate', _getCorrelationColor(0.5)),
            _buildLegendItem('Weak', _getCorrelationColor(0.2)),
            _buildLegendItem('None', _getCorrelationColor(0.0)),
            _buildLegendItem('Negative', _getCorrelationColor(-0.5)),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: Colors.grey[400]!),
            ),
          ),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  void _selectCell(String symptom1, String symptom2, double correlation) {
    setState(() {
      selectedSymptom1 = symptom1;
      selectedSymptom2 = symptom2;
      selectedCorrelation = correlation;
    });
  }

  Color _getCorrelationColor(double correlation) {
    final absCorr = correlation.abs();
    if (correlation > 0) {
      // Positive correlation - shades of blue
      if (absCorr > 0.7) return const Color(0xFF0D47A1);
      if (absCorr > 0.5) return const Color(0xFF1976D2);
      if (absCorr > 0.3) return const Color(0xFF2196F3);
      if (absCorr > 0.1) return const Color(0xFF64B5F6);
      return const Color(0xFFBBDEFB);
    } else if (correlation < 0) {
      // Negative correlation - shades of red
      if (absCorr > 0.7) return const Color(0xFFB71C1C);
      if (absCorr > 0.5) return const Color(0xFFD32F2F);
      if (absCorr > 0.3) return const Color(0xFFF44336);
      if (absCorr > 0.1) return const Color(0xFFEF5350);
      return const Color(0xFFFFCDD2);
    } else {
      // No correlation - white
      return Colors.white;
    }
  }

  String _getCorrelationDescription(double correlation) {
    final absCorr = correlation.abs();
    if (absCorr > 0.7) {
      return correlation > 0
          ? 'These symptoms very often occur together'
          : 'These symptoms rarely occur together';
    } else if (absCorr > 0.5) {
      return correlation > 0
          ? 'These symptoms often occur together'
          : 'These symptoms sometimes avoid each other';
    } else if (absCorr > 0.3) {
      return correlation > 0
          ? 'These symptoms sometimes occur together'
          : 'These symptoms have a slight negative relationship';
    } else if (absCorr > 0.1) {
      return 'These symptoms have a weak relationship';
    } else {
      return 'These symptoms appear to be independent of each other';
    }
  }
}
