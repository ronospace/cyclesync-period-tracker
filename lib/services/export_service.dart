import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/cycle_models.dart';
import '../models/daily_log_models.dart';
import '../services/enhanced_analytics_service.dart';

/// 🚀 Mission Beta: Advanced Export & Data Management Service
/// Comprehensive data export system with multiple formats and visualizations
class ExportService {
  static const String _appName = 'CycleSync';
  static const String _version = '1.0.0';

  /// Export complete cycle data as PDF report with charts and insights
  static Future<String> exportPDFReport({
    required List<CycleData> cycles,
    required List<DailyLogEntry> dailyLogs,
    required DateRange dateRange,
    bool includeCharts = true,
    bool includeInsights = true,
    bool includeRawData = false,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();

    // Calculate analytics for the report
    final wellbeingTrends = EnhancedAnalyticsService.calculateWellbeingTrends(
      cycles,
      dailyLogs,
    );
    final correlationMatrix =
        EnhancedAnalyticsService.calculateSymptomCorrelations(
          cycles,
          dailyLogs,
        );
    final healthScore = EnhancedAnalyticsService.calculateHealthScore(
      cycles,
      dailyLogs,
    );
    final prediction = EnhancedAnalyticsService.generateAdvancedPredictions(
      cycles,
    );

    // Cover Page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return _buildCoverPage(dateRange, cycles.length, now);
        },
      ),
    );

    // Executive Summary
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return _buildExecutiveSummary(cycles, healthScore, prediction);
        },
      ),
    );

    // Health Insights
    if (includeInsights) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return _buildHealthInsights(wellbeingTrends, healthScore);
          },
        ),
      );
    }

    // Cycle Analysis
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return _buildCycleAnalysis(cycles);
        },
      ),
    );

    // Symptom Correlation Analysis
    if (correlationMatrix.symptoms.isNotEmpty) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return _buildSymptomAnalysis(correlationMatrix);
          },
        ),
      );
    }

    // Predictions and Recommendations
    if (prediction.basedOnCycles > 0) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return _buildPredictionsPage(prediction);
          },
        ),
      );
    }

    // Raw Data (if requested)
    if (includeRawData) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return _buildRawDataPage(cycles, dailyLogs);
          },
        ),
      );
    }

    // Save the PDF
    final output = await getApplicationDocumentsDirectory();
    final fileName =
        'CycleSync_Report_${DateFormat('yyyy-MM-dd').format(now)}.pdf';
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  /// Export cycle data as CSV for spreadsheet analysis
  static Future<String> exportCSV({
    required List<CycleData> cycles,
    required List<DailyLogEntry> dailyLogs,
    bool includeDailyLogs = true,
  }) async {
    final buffer = StringBuffer();

    // CSV Header for cycles
    buffer.writeln('Type,Date,Cycle_Length,Mood,Energy,Pain,Symptoms,Notes');

    // Write cycle data
    for (final cycle in cycles) {
      final symptoms = cycle.symptoms
          .map((s) => '${s.name}(${s.severity})')
          .join(';');
      final notes = cycle.notes.replaceAll(',', ';').replaceAll('\n', ' ');

      buffer.writeln(
        [
          'Cycle',
          DateFormat('yyyy-MM-dd').format(cycle.startDate),
          cycle.lengthInDays,
          cycle.wellbeing.mood,
          cycle.wellbeing.energy,
          cycle.wellbeing.pain,
          '"$symptoms"',
          '"$notes"',
        ].join(','),
      );
    }

    // Write daily log data if requested
    if (includeDailyLogs) {
      for (final log in dailyLogs) {
        final symptoms = log.symptoms.join(';');
        final notes = log.notes.replaceAll(',', ';').replaceAll('\n', ' ');

        buffer.writeln(
          [
            'DailyLog',
            DateFormat('yyyy-MM-dd').format(log.date),
            '', // No cycle length for daily logs
            log.mood ?? '',
            log.energy ?? '',
            log.pain ?? '',
            '"$symptoms"',
            '"$notes"',
          ].join(','),
        );
      }
    }

    // Save CSV file
    final output = await getApplicationDocumentsDirectory();
    final fileName =
        'CycleSync_Data_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.csv';
    final file = File('${output.path}/$fileName');
    await file.writeAsString(buffer.toString());

    return file.path;
  }

  /// Export complete data backup as JSON
  static Future<String> exportJSONBackup({
    required List<CycleData> cycles,
    required List<DailyLogEntry> dailyLogs,
    Map<String, dynamic>? metadata,
  }) async {
    final backup = {
      'app_name': _appName,
      'version': _version,
      'export_date': DateTime.now().toIso8601String(),
      'metadata': metadata ?? {},
      'cycles': cycles.map((c) => c.toJson()).toList(),
      'daily_logs': dailyLogs.map((l) => l.toJson()).toList(),
      'analytics': {
        'health_score': EnhancedAnalyticsService.calculateHealthScore(
          cycles,
          dailyLogs,
        ).toJson(),
        'wellbeing_trends': _serializeWellbeingTrends(
          EnhancedAnalyticsService.calculateWellbeingTrends(cycles, dailyLogs),
        ),
      },
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(backup);

    // Save JSON file
    final output = await getApplicationDocumentsDirectory();
    final fileName =
        'CycleSync_Backup_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.json';
    final file = File('${output.path}/$fileName');
    await file.writeAsString(jsonString);

    return file.path;
  }

  /// Share exported file via platform share dialog
  static Future<void> shareFile(String filePath, String title) async {
    final file = XFile(filePath);
    await Share.shareXFiles([file], text: title);
  }

  /// Import data from JSON backup
  static Future<ImportResult> importFromJSON(String filePath) async {
    try {
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // Validate backup format
      if (data['app_name'] != _appName) {
        throw FormatException('Invalid backup format');
      }

      final cycles = (data['cycles'] as List<dynamic>)
          .map((c) => CycleData.fromJson(c as Map<String, dynamic>))
          .toList();

      final dailyLogs = (data['daily_logs'] as List<dynamic>)
          .map((l) => DailyLogEntry.fromJson(l as Map<String, dynamic>))
          .toList();

      return ImportResult(
        success: true,
        cyclesImported: cycles.length,
        dailyLogsImported: dailyLogs.length,
        cycles: cycles,
        dailyLogs: dailyLogs,
        metadata: data['metadata'] as Map<String, dynamic>?,
      );
    } catch (e) {
      return ImportResult(
        success: false,
        error: e.toString(),
        cyclesImported: 0,
        dailyLogsImported: 0,
        cycles: [],
        dailyLogs: [],
      );
    }
  }

  /// Generate scheduled health report
  static Future<String> generateScheduledReport({
    required List<CycleData> cycles,
    required List<DailyLogEntry> dailyLogs,
    required ReportType reportType,
  }) async {
    final now = DateTime.now();
    late DateRange dateRange;

    switch (reportType) {
      case ReportType.monthly:
        dateRange = DateRange(
          start: DateTime(now.year, now.month - 1, 1),
          end: DateTime(now.year, now.month, 0),
        );
        break;
      case ReportType.quarterly:
        final quarterStart = DateTime(
          now.year,
          ((now.month - 1) ~/ 3) * 3 + 1,
          1,
        );
        dateRange = DateRange(
          start: DateTime(quarterStart.year, quarterStart.month - 3, 1),
          end: DateTime(quarterStart.year, quarterStart.month, 0),
        );
        break;
      case ReportType.yearly:
        dateRange = DateRange(
          start: DateTime(now.year - 1, 1, 1),
          end: DateTime(now.year - 1, 12, 31),
        );
        break;
    }

    // Filter data by date range
    final filteredCycles = cycles
        .where(
          (c) =>
              c.startDate.isAfter(dateRange.start) &&
              c.startDate.isBefore(dateRange.end),
        )
        .toList();

    final filteredLogs = dailyLogs
        .where(
          (l) =>
              l.date.isAfter(dateRange.start) && l.date.isBefore(dateRange.end),
        )
        .toList();

    return await exportPDFReport(
      cycles: filteredCycles,
      dailyLogs: filteredLogs,
      dateRange: dateRange,
      includeCharts: true,
      includeInsights: true,
    );
  }

  // PDF Building Helper Methods

  static pw.Widget _buildCoverPage(
    DateRange dateRange,
    int cycleCount,
    DateTime generateDate,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(40),
          decoration: pw.BoxDecoration(
            gradient: pw.LinearGradient(
              colors: [PdfColors.purple300, PdfColors.pink200],
            ),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                'CycleSync',
                style: pw.TextStyle(
                  fontSize: 48,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Personal Health Report',
                style: pw.TextStyle(fontSize: 24, color: PdfColors.white),
              ),
            ],
          ),
        ),
        pw.Spacer(),
        pw.Padding(
          padding: const pw.EdgeInsets.all(40),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Report Period',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                '${DateFormat.yMMMd().format(dateRange.start)} - ${DateFormat.yMMMd().format(dateRange.end)}',
                style: const pw.TextStyle(fontSize: 16),
              ),
              pw.SizedBox(height: 24),
              pw.Text(
                'Data Summary',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Total Cycles Analyzed: $cycleCount',
                style: const pw.TextStyle(fontSize: 14),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Generated: ${DateFormat.yMMMd().add_jm().format(generateDate)}',
                style: const pw.TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        pw.Spacer(),
      ],
    );
  }

  static pw.Widget _buildExecutiveSummary(
    List<CycleData> cycles,
    HealthScore healthScore,
    AdvancedPrediction prediction,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Header(
          level: 0,
          child: pw.Text(
            'Executive Summary',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.SizedBox(height: 20),
        pw.Container(
          padding: const pw.EdgeInsets.all(20),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Overall Health Score: ${healthScore.overall.toInt()}/100 (${healthScore.overallGrade})',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              ...healthScore.breakdown.entries.map(
                (entry) => pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        entry.key,
                        style: const pw.TextStyle(fontSize: 14),
                      ),
                      pw.Text(
                        '${entry.value.toInt()}%',
                        style: const pw.TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 20),
        if (prediction.basedOnCycles > 0) ...[
          pw.Text(
            'Key Predictions',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Bullet(
            text:
                'Next cycle predicted: ${DateFormat.yMMMd().format(prediction.nextCycleStart)}',
          ),
          pw.Bullet(
            text: 'Confidence level: ${(prediction.confidence * 100).toInt()}%',
          ),
          pw.Bullet(
            text: 'Based on ${prediction.basedOnCycles} completed cycles',
          ),
        ],
      ],
    );
  }

  static pw.Widget _buildHealthInsights(
    WellbeingTrends trends,
    HealthScore score,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Header(
          level: 0,
          child: pw.Text(
            'Health Insights',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.SizedBox(height: 20),
        pw.Text(
          'Wellbeing Averages',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(),
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    'Metric',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    'Average',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    'Rating',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
              ],
            ),
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('Mood'),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('${trends.averageMood.toStringAsFixed(1)}/5'),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(_getRating(trends.averageMood)),
                ),
              ],
            ),
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('Energy'),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    '${trends.averageEnergy.toStringAsFixed(1)}/5',
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(_getRating(trends.averageEnergy)),
                ),
              ],
            ),
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('Pain Level'),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('${trends.averagePain.toStringAsFixed(1)}/5'),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(_getRating(5 - trends.averagePain)),
                ), // Invert for pain
              ],
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildCycleAnalysis(List<CycleData> cycles) {
    if (cycles.isEmpty) {
      return pw.Center(child: pw.Text('No cycle data available'));
    }

    final completedCycles = cycles.where((c) => c.isCompleted).toList();
    final avgLength = completedCycles.isNotEmpty
        ? completedCycles.map((c) => c.lengthInDays).reduce((a, b) => a + b) /
              completedCycles.length
        : 0.0;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Header(
          level: 0,
          child: pw.Text(
            'Cycle Analysis',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.SizedBox(height: 20),
        pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Cycle Statistics',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text('Total Cycles Tracked: ${cycles.length}'),
              pw.Text('Completed Cycles: ${completedCycles.length}'),
              if (completedCycles.isNotEmpty) ...[
                pw.Text(
                  'Average Cycle Length: ${avgLength.toStringAsFixed(1)} days',
                ),
                pw.Text(
                  'Shortest Cycle: ${completedCycles.map((c) => c.lengthInDays).reduce((a, b) => a < b ? a : b)} days',
                ),
                pw.Text(
                  'Longest Cycle: ${completedCycles.map((c) => c.lengthInDays).reduce((a, b) => a > b ? a : b)} days',
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildSymptomAnalysis(SymptomCorrelationMatrix matrix) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Header(
          level: 0,
          child: pw.Text(
            'Symptom Analysis',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.SizedBox(height: 20),
        pw.Text(
          'Common Symptoms',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        pw.Wrap(
          spacing: 8,
          runSpacing: 4,
          children: matrix.symptoms
              .map(
                (symptom) => pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue100,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(
                    symptom,
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ),
              )
              .toList(),
        ),
        pw.SizedBox(height: 20),
        pw.Text(
          'Note: Detailed correlation analysis is available in the interactive app.',
          style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
        ),
      ],
    );
  }

  static pw.Widget _buildPredictionsPage(AdvancedPrediction prediction) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Header(
          level: 0,
          child: pw.Text(
            'Predictions & Recommendations',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.SizedBox(height: 20),
        pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            color: PdfColors.blue50,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Next Cycle Predictions',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Expected Start: ${DateFormat.yMMMd().format(prediction.nextCycleStart)}',
              ),
              pw.Text(
                'Confidence Range: ${DateFormat.MMMd().format(prediction.confidenceLowerBound)} - ${DateFormat.MMMd().format(prediction.confidenceUpperBound)}',
              ),
              pw.Text(
                'Confidence Level: ${(prediction.confidence * 100).toInt()}%',
              ),
              pw.SizedBox(height: 12),
              pw.Text(
                'Expected Ovulation: ${DateFormat.yMMMd().format(prediction.ovulationDate)}',
              ),
              pw.Text(
                'Fertile Window: ${DateFormat.MMMd().format(prediction.fertileWindowStart)} - ${DateFormat.MMMd().format(prediction.fertileWindowEnd)}',
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildRawDataPage(
    List<CycleData> cycles,
    List<DailyLogEntry> dailyLogs,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Header(
          level: 0,
          child: pw.Text(
            'Raw Data',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.SizedBox(height: 20),
        pw.Text(
          'This section contains your complete cycle and daily log data for reference.',
        ),
        pw.SizedBox(height: 10),
        pw.Text('Cycle Count: ${cycles.length}'),
        pw.Text('Daily Log Count: ${dailyLogs.length}'),
        pw.SizedBox(height: 10),
        pw.Text(
          'For detailed raw data access, please use the CSV export function.',
          style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
        ),
      ],
    );
  }

  // Helper Methods

  static String _getRating(double value) {
    if (value >= 4.5) return 'Excellent';
    if (value >= 3.5) return 'Good';
    if (value >= 2.5) return 'Fair';
    if (value >= 1.5) return 'Poor';
    return 'Very Poor';
  }

  static Map<String, dynamic> _serializeWellbeingTrends(
    WellbeingTrends trends,
  ) {
    return {
      'average_mood': trends.averageMood,
      'average_energy': trends.averageEnergy,
      'average_pain': trends.averagePain,
      'mood_trend_count': trends.moodTrend.length,
      'energy_trend_count': trends.energyTrend.length,
      'pain_trend_count': trends.painTrend.length,
    };
  }
}

// Supporting Data Classes

class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange({required this.start, required this.end});
}

class ImportResult {
  final bool success;
  final int cyclesImported;
  final int dailyLogsImported;
  final List<CycleData> cycles;
  final List<DailyLogEntry> dailyLogs;
  final Map<String, dynamic>? metadata;
  final String? error;

  ImportResult({
    required this.success,
    required this.cyclesImported,
    required this.dailyLogsImported,
    required this.cycles,
    required this.dailyLogs,
    this.metadata,
    this.error,
  });
}

enum ReportType { monthly, quarterly, yearly }

// Extension methods for JSON serialization
extension CycleDataJson on CycleData {
  Map<String, dynamic> toJson() => {
    'id': id,
    'start_date': startDate.toIso8601String(),
    'end_date': endDate?.toIso8601String(),
    'symptoms': symptoms
        .map((s) => {'name': s.name, 'severity': s.severity})
        .toList(),
    'wellbeing': {
      'mood': wellbeing.mood,
      'energy': wellbeing.energy,
      'pain': wellbeing.pain,
    },
    'notes': notes,
  };
}

extension DailyLogEntryJson on DailyLogEntry {
  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'mood': mood,
    'energy': energy,
    'pain': pain,
    'symptoms': symptoms,
    'notes': notes,
  };
}

extension HealthScoreJson on HealthScore {
  Map<String, dynamic> toJson() => {
    'overall': overall,
    'breakdown': breakdown,
    'grade': overallGrade,
  };
}
