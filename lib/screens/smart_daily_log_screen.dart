import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../services/firebase_service.dart';
import '../services/ai_insights_engine.dart';
import '../services/tensorflow_prediction_service.dart';
import '../theme/app_theme.dart';
import '../models/cycle_models.dart';
import '../l10n/generated/app_localizations.dart';

class SmartDailyLogScreen extends StatefulWidget {
  const SmartDailyLogScreen({super.key});

  @override
  State<SmartDailyLogScreen> createState() => _SmartDailyLogScreenState();
}

class _SmartDailyLogScreenState extends State<SmartDailyLogScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  DateTime _selectedDate = DateTime.now();
  final _notesController = TextEditingController();
  bool _isSaving = false;
  bool _isLoading = false;
  
  // Tracking data
  double _moodLevel = 3.0;
  double _energyLevel = 3.0;
  double _painLevel = 1.0;
  double _stressLevel = 2.0;
  double _sleepQuality = 3.0;
  int _waterIntake = 8; // glasses
  int _exerciseMinutes = 0;
  
  final Set<String> _selectedSymptoms = <String>{};
  final List<String> _moodLabels = ['Very Low', 'Low', 'Neutral', 'Good', 'Excellent'];
  final List<String> _energyLabels = ['Exhausted', 'Low', 'Normal', 'High', 'Energetic'];
  final List<String> _painLabels = ['None', 'Mild', 'Moderate', 'Severe', 'Extreme'];
  final List<String> _stressLabels = ['Very Calm', 'Relaxed', 'Neutral', 'Stressed', 'Very Stressed'];
  final List<String> _sleepLabels = ['Poor', 'Fair', 'Good', 'Very Good', 'Excellent'];
  
  final List<SymptomOption> _symptomOptions = [
    SymptomOption('cramps', 'Cramps', Icons.healing, Colors.red),
    SymptomOption('headache', 'Headache', Icons.psychology_alt, Colors.orange),
    SymptomOption('mood_swings', 'Mood Swings', Icons.sentiment_very_dissatisfied, Colors.purple),
    SymptomOption('fatigue', 'Fatigue', Icons.battery_0_bar, Colors.grey),
    SymptomOption('bloating', 'Bloating', Icons.expand, Colors.blue),
    SymptomOption('breast_tenderness', 'Breast Tenderness', Icons.favorite_border, Colors.pink),
    SymptomOption('nausea', 'Nausea', Icons.sick, Colors.green),
    SymptomOption('back_pain', 'Back Pain', Icons.accessibility_new, Colors.brown),
    SymptomOption('acne', 'Acne', Icons.face_retouching_natural, Colors.amber),
    SymptomOption('food_cravings', 'Food Cravings', Icons.restaurant, Colors.deepOrange),
    SymptomOption('insomnia', 'Sleep Issues', Icons.bedtime_off, Colors.indigo),
    SymptomOption('hot_flashes', 'Hot Flashes', Icons.whatshot, Colors.deepOrange),
  ];
  
  // AI Insights
  List<AIInsight> _aiInsights = [];
  Map<String, dynamic>? _predictions;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _loadDailyData();
    _generateAIInsights();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadDailyData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load existing daily log data for selected date
      final dailyData = await _getDailyLogForDate(_selectedDate);
      if (dailyData != null) {
        setState(() {
          _moodLevel = dailyData['mood_level']?.toDouble() ?? 3.0;
          _energyLevel = dailyData['energy_level']?.toDouble() ?? 3.0;
          _painLevel = dailyData['pain_level']?.toDouble() ?? 1.0;
          _stressLevel = dailyData['stress_level']?.toDouble() ?? 2.0;
          _sleepQuality = dailyData['sleep_quality']?.toDouble() ?? 3.0;
          _waterIntake = dailyData['water_intake']?.toInt() ?? 8;
          _exerciseMinutes = dailyData['exercise_minutes']?.toInt() ?? 0;
          _notesController.text = dailyData['notes'] ?? '';
          
          if (dailyData['symptoms'] != null) {
            _selectedSymptoms.clear();
            _selectedSymptoms.addAll((dailyData['symptoms'] as List).cast<String>());
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading daily data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<Map<String, dynamic>?> _getDailyLogForDate(DateTime date) async {
    try {
      // This would typically query your database for daily log entries
      // For now, return null to indicate no existing data
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _generateAIInsights() async {
    try {
      final cycleData = await FirebaseService.getCycles(limit: 10);
      
      // Convert Firebase data to CycleData objects
      final cycles = cycleData.map((data) => CycleData.fromFirestore(data)).toList();
      
      // Generate cycle insights using AI
      final insights = await AIInsightsEngine.generatePersonalizedInsights(
        cycles: cycles,
        userPreferences: {
          'focus_areas': ['cycle_prediction', 'symptom_patterns', 'wellness'],
        },
      );
      
      // Get AI predictions for various metrics
      final predictions = await TensorFlowPredictionService.getCyclePredictions(
        cycles: cycles,
        currentWellbeing: {
          'mood': _moodLevel,
          'energy': _energyLevel,
          'pain': _painLevel,
          'stress': _stressLevel,
        },
      );
      
      setState(() {
        _aiInsights = insights;
        _predictions = predictions;
      });
    } catch (e) {
      debugPrint('Error generating AI insights: $e');
    }
  }

  Future<void> _saveDailyLog() async {
    if (_isSaving) return;
    
    setState(() => _isSaving = true);
    
    try {
      final dailyLogData = {
        'date': _selectedDate,
        'mood_level': _moodLevel,
        'energy_level': _energyLevel,
        'pain_level': _painLevel,
        'stress_level': _stressLevel,
        'sleep_quality': _sleepQuality,
        'water_intake': _waterIntake,
        'exercise_minutes': _exerciseMinutes,
        'symptoms': _selectedSymptoms.toList(),
        'notes': _notesController.text.trim(),
        'created_at': DateTime.now().toIso8601String(),
      };

      // Save to Firebase (implement this method in FirebaseService)
      await FirebaseService.saveDailyLog(dailyLogData);
      
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.dailyLogSavedFor(DateFormat.yMMMd().format(_selectedDate)) ?? 'Daily log saved for ${DateFormat.yMMMd().format(_selectedDate)}'),
          ),
        );
        
        // Regenerate insights with new data
        _generateAIInsights();
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.errorSavingDailyLog(e.toString()) ?? 'Error saving daily log: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: l10n?.retry ?? 'Retry',
              textColor: Colors.white,
              onPressed: _saveDailyLog,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildDateSelector() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: AppTheme.primaryPink),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)?.loggingFor ?? 'Logging for',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Text(
                    DateFormat.yMMMMEEEEd().format(_selectedDate),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 1)),
                );
                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                  });
                  _loadDailyData();
                }
              },
              icon: const Icon(Icons.edit_calendar),
              label: Text(AppLocalizations.of(context)?.change ?? 'Change'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWellbeingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateSelector(),
          
          // Mood
          _buildLevelCard(
            title: AppLocalizations.of(context)?.moodLevel ?? 'Mood Level',
            icon: Icons.sentiment_satisfied_alt,
            color: Colors.amber,
            value: _moodLevel,
            labels: _moodLabels,
            onChanged: (value) => setState(() => _moodLevel = value),
          ),
          
          const SizedBox(height: 16),
          
          // Energy
          _buildLevelCard(
            title: AppLocalizations.of(context)?.energyLevel ?? 'Energy Level',
            icon: Icons.battery_charging_full,
            color: Colors.green,
            value: _energyLevel,
            labels: _energyLabels,
            onChanged: (value) => setState(() => _energyLevel = value),
          ),
          
          const SizedBox(height: 16),
          
          // Pain
          _buildLevelCard(
            title: AppLocalizations.of(context)?.painLevel ?? 'Pain Level',
            icon: Icons.healing,
            color: Colors.red,
            value: _painLevel,
            labels: _painLabels,
            onChanged: (value) => setState(() => _painLevel = value),
          ),
          
          const SizedBox(height: 16),
          
          // Stress
          _buildLevelCard(
            title: AppLocalizations.of(context)?.stressLevel ?? 'Stress Level',
            icon: Icons.psychology,
            color: Colors.orange,
            value: _stressLevel,
            labels: _stressLabels,
            onChanged: (value) => setState(() => _stressLevel = value),
          ),
          
          const SizedBox(height: 16),
          
          // Sleep Quality
          _buildLevelCard(
            title: AppLocalizations.of(context)?.sleepQuality ?? 'Sleep Quality',
            icon: Icons.bedtime,
            color: Colors.indigo,
            value: _sleepQuality,
            labels: _sleepLabels,
            onChanged: (value) => setState(() => _sleepQuality = value),
          ),
        ],
      ),
    );
  }

  Widget _buildLifestyleTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Water Intake
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_drink, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)?.waterIntake ?? 'Water Intake',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$_waterIntake glasses (${(_waterIntake * 240).toStringAsFixed(0)}ml)',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _waterIntake > 0 ? () => setState(() => _waterIntake--) : null,
                        icon: const Icon(Icons.remove_circle),
                        color: Colors.red,
                      ),
                      Expanded(
                        child: Slider(
                          value: _waterIntake.toDouble(),
                          min: 0,
                          max: 15,
                          divisions: 15,
                          activeColor: Colors.blue,
                          onChanged: (value) => setState(() => _waterIntake = value.round()),
                        ),
                      ),
                      IconButton(
                        onPressed: _waterIntake < 15 ? () => setState(() => _waterIntake++) : null,
                        icon: const Icon(Icons.add_circle),
                        color: Colors.green,
                      ),
                    ],
                  ),
                  // Water intake visualization
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(15, (index) {
                      return Expanded(
                        child: Container(
                          height: 20,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: index < _waterIntake ? Colors.blue : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Exercise
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.fitness_center, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)?.exercise ?? 'Exercise',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$_exerciseMinutes minutes',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _exerciseMinutes >= 15 ? () => setState(() => _exerciseMinutes -= 15) : null,
                        icon: const Icon(Icons.remove_circle),
                        color: Colors.red,
                      ),
                      Expanded(
                        child: Slider(
                          value: _exerciseMinutes.toDouble(),
                          min: 0,
                          max: 180,
                          divisions: 12,
                          activeColor: Colors.green,
                          onChanged: (value) => setState(() => _exerciseMinutes = value.round()),
                        ),
                      ),
                      IconButton(
                        onPressed: _exerciseMinutes < 180 ? () => setState(() => _exerciseMinutes += 15) : null,
                        icon: const Icon(Icons.add_circle),
                        color: Colors.green,
                      ),
                    ],
                  ),
                  // Exercise goal indicator
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (_exerciseMinutes / 30).clamp(0.0, 1.0),
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _exerciseMinutes >= 30 
                        ? '🎉 Daily goal achieved!'
                    : '${30 - _exerciseMinutes} ${AppLocalizations.of(context)?.minutes ?? 'min'} to reach daily goal',
                    style: TextStyle(
                      fontSize: 12,
                      color: _exerciseMinutes >= 30 ? Colors.green : Colors.grey.shade600,
                      fontWeight: _exerciseMinutes >= 30 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)?.symptomsToday ?? 'Symptoms Today',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)?.tapSymptomsExperienced ?? 'Tap any symptoms you experienced today:',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  
                  if (_selectedSymptoms.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.pink.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.pink.shade200),
                      ),
                      child: Text(
                        AppLocalizations.of(context)?.symptomSelected(_selectedSymptoms.length) ?? '',
                        style: TextStyle(
                          color: Colors.pink.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Symptoms grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _symptomOptions.length,
                    itemBuilder: (context, index) {
                      final symptom = _symptomOptions[index];
                      final isSelected = _selectedSymptoms.contains(symptom.id);
                      
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedSymptoms.remove(symptom.id);
                            } else {
                              _selectedSymptoms.add(symptom.id);
                            }
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? symptom.color.withOpacity(0.1) : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? symptom.color : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 12),
                              Icon(
                                symptom.icon,
                                color: isSelected ? symptom.color : Colors.grey.shade600,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  symptom.name,
                                  style: TextStyle(
                                    color: isSelected ? symptom.color : Colors.grey.shade700,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Notes Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)?.dailyNotes ?? 'Daily Notes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)?.howFeelingToday ?? 'How are you feeling today? Any thoughts or observations?',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: _notesController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)?.feelingGreatToday ?? 'e.g., Feeling great today, had a good workout...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIInsightsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isLoading)
            Card(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(AppLocalizations.of(context)?.generatingAIInsights ?? 'Generating AI insights...'),
                    ],
                  ),
                ),
              ),
            )
          else ...[
            // AI Predictions Card
            if (_predictions != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome, color: Colors.purple),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context)?.aiPredictions ?? 'AI Predictions',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      if (_predictions!['next_period'] != null)
                        _buildPredictionItem(
                          AppLocalizations.of(context)?.nextPeriod ?? 'Next Period',
                          _predictions!['next_period']['date'],
                          _predictions!['next_period']['confidence'],
                          Icons.event,
                          Colors.red,
                        ),
                      
                      if (_predictions!['ovulation'] != null)
                        _buildPredictionItem(
                          AppLocalizations.of(context)?.ovulation ?? 'Ovulation',
                          _predictions!['ovulation']['date'],
                          _predictions!['ovulation']['confidence'],
                          Icons.favorite,
                          Colors.pink,
                        ),
                      
                      if (_predictions!['cycle_irregularity'] != null)
                        _buildPredictionItem(
                          AppLocalizations.of(context)?.cycleRegularity ?? 'Cycle Regularity',
                          _predictions!['cycle_irregularity']['risk_level'],
                          _predictions!['cycle_irregularity']['confidence'],
                          Icons.warning,
                          Colors.orange,
                        ),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            
            // AI Insights
            if (_aiInsights.isNotEmpty) ...[
              Text(
                '🧠 ${AppLocalizations.of(context)?.personalInsights ?? 'Personal Insights'}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...List.generate(_aiInsights.length, (index) {
                final insight = _aiInsights[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getInsightColor(insight.type).withOpacity(0.2),
                      child: Icon(
                        _getInsightIcon(insight.type),
                        color: _getInsightColor(insight.type),
                      ),
                    ),
                    title: Text(
                      insight.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(insight.message),
                    trailing: insight.priority == InsightPriority.high
                        ? const Icon(Icons.priority_high, color: Colors.red)
                        : null,
                  ),
                );
              }),
            ] else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.lightbulb_outline, size: 48, color: Colors.grey),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)?.noInsightsYet ?? 'No insights yet',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context)?.keepTrackingForInsights ?? 'Keep tracking your daily data to get personalized AI insights!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildLevelCard({
    required String title,
    required IconData icon,
    required Color color,
    required double value,
    required List<String> labels,
    required ValueChanged<double> onChanged,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Current level display
            Center(
              child: Column(
                children: [
                  Text(
                    labels[value.round() - 1],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return Icon(
                        index < value ? Icons.star : Icons.star_border,
                        color: color,
                        size: 24,
                      );
                    }),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Slider
            Slider(
              value: value,
              min: 1,
              max: 5,
              divisions: 4,
              activeColor: color,
              onChanged: onChanged,
            ),
            
            // Scale labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(labels.first, style: const TextStyle(fontSize: 12)),
                Text(labels.last, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionItem(
    String title,
    String value,
    double confidence,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(value),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: confidence,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
                const SizedBox(height: 2),
                Text(
                  '${(confidence * 100).toStringAsFixed(0)}% ${AppLocalizations.of(context)?.confidence ?? 'confidence'}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getInsightColor(InsightType type) {
    switch (type) {
      case InsightType.cycle:
        return Colors.pink;
      case InsightType.symptom:
        return Colors.orange;
      case InsightType.wellness:
        return Colors.green;
      case InsightType.prediction:
        return Colors.purple;
    }
  }

  IconData _getInsightIcon(InsightType type) {
    switch (type) {
      case InsightType.cycle:
        return Icons.calendar_month;
      case InsightType.symptom:
        return Icons.healing;
      case InsightType.wellness:
        return Icons.health_and_safety;
      case InsightType.prediction:
        return Icons.auto_awesome;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('🌸 ${AppLocalizations.of(context)?.smartDailyLog ?? 'Smart Daily Log'}'),
        backgroundColor: Colors.pink.shade50,
        foregroundColor: Colors.pink.shade700,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.pink.shade700),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton.icon(
              onPressed: _saveDailyLog,
              icon: const Icon(Icons.save),
              label: Text(AppLocalizations.of(context)?.save ?? 'Save'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.pink.shade700,
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.pink.shade700,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: Colors.pink.shade600,
          tabs: [
            Tab(icon: Icon(Icons.sentiment_satisfied_alt), text: AppLocalizations.of(context)?.wellbeing ?? 'Wellbeing'),
            Tab(icon: Icon(Icons.fitness_center), text: AppLocalizations.of(context)?.lifestyle ?? 'Lifestyle'),
            Tab(icon: Icon(Icons.healing), text: AppLocalizations.of(context)?.symptoms ?? 'Symptoms'),
            Tab(icon: Icon(Icons.auto_awesome), text: AppLocalizations.of(context)?.aiInsights ?? 'AI Insights'),
          ],
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildWellbeingTab(),
            _buildLifestyleTab(),
            _buildSymptomsTab(),
            _buildAIInsightsTab(),
          ],
        ),
      ),
    );
  }
}

class SymptomOption {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  SymptomOption(this.id, this.name, this.icon, this.color);
}
