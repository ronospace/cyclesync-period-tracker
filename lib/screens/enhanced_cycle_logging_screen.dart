import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../models/cycle_models.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';
import '../models/cycle_models.dart';
import '../services/tensorflow_prediction_service.dart';
import '../services/ai_insights_engine.dart';

class EnhancedCycleLoggingScreen extends StatefulWidget {
  const EnhancedCycleLoggingScreen({super.key});

  @override
  State<EnhancedCycleLoggingScreen> createState() => _EnhancedCycleLoggingScreenState();
}

class _EnhancedCycleLoggingScreenState extends State<EnhancedCycleLoggingScreen> with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentStep = 0;
  final _notesController = TextEditingController();
  
  // Basic cycle data
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSaving = false;
  
  // Flow tracking
  String _flowIntensity = 'Medium';
  final List<String> _flowOptions = ['Light', 'Medium', 'Heavy', 'Very Heavy'];
  
  // Mood tracking (1-5 scale)
  double _moodLevel = 3.0;
  final List<String> _moodLabels = ['Very Low', 'Low', 'Neutral', 'Good', 'Excellent'];
  
  // Energy tracking (1-5 scale)
  double _energyLevel = 3.0;
  final List<String> _energyLabels = ['Exhausted', 'Low', 'Normal', 'High', 'Energetic'];
  
  // Pain tracking (1-5 scale)
  double _painLevel = 1.0;
  final List<String> _painLabels = ['None', 'Mild', 'Moderate', 'Severe', 'Extreme'];
  
  // Symptoms tracking
  final Set<String> _selectedSymptoms = <String>{};
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

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool get _canContinueFromDates => _startDate != null && _endDate != null;
  bool get _isCurrentStepComplete {
    switch (_currentStep) {
      case 0: return _canContinueFromDates;
      case 1: return true; // Wellbeing always has defaults
      case 2: return true; // Symptoms are optional
      case 3: return true; // Notes are optional
      default: return false;
    }
  }

  Future<void> _saveCycle() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both start and end dates')),
      );
      return;
    }

    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      // Prepare cycle data with symptoms
      final cycleData = {
        'start': _startDate!,
        'end': _endDate!,
        'flow': _flowIntensity,
        'mood_level': _moodLevel.round(),
        'energy_level': _energyLevel.round(),
        'pain_level': _painLevel.round(),
        'symptoms': _selectedSymptoms.toList(),
        'notes': _notesController.text.trim(),
        'created_at': DateTime.now().toIso8601String(),
      };

      await FirebaseService.saveCycleWithSymptoms(
        cycleData: cycleData,
        timeout: const Duration(seconds: 15),
      );

      // Health sync and notifications would be implemented here
      debugPrint('Cycle saved successfully - health sync and notifications disabled for now');

      // Clear form and show success
      _clearForm();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Cycle logged with symptoms successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate back to home after successful save
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save cycle: ${e.toString()}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _saveCycle,
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

  void _clearForm() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _flowIntensity = 'Medium';
      _moodLevel = 3.0;
      _energyLevel = 3.0;
      _painLevel = 1.0;
      _selectedSymptoms.clear();
      _notesController.clear();
    });
  }

  FlowIntensity _parseFlowIntensity(String flow) {
    switch (flow.toLowerCase()) {
      case 'light':
        return FlowIntensity.light;
      case 'heavy':
      case 'very heavy':
        return FlowIntensity.heavy;
      default:
        return FlowIntensity.medium;
    }
  }

  Future<void> _pickDate(bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Widget _buildDateStep() {
    final dateFormat = DateFormat.yMMMd();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Step 1 of 4',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'When was your cycle?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Let\'s start with the basic dates for this cycle.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          
          // Start Date - Prominent Button
          Container(
            width: double.infinity,
            child: Card(
              elevation: _startDate != null ? 0 : 2,
              color: _startDate != null ? Theme.of(context).colorScheme.primaryContainer : null,
              child: InkWell(
                onTap: () async {
                  await _pickDate(true);
                  if (_startDate != null && _endDate == null) {
                    // Auto-suggest end date after start date is selected
                    Future.delayed(const Duration(milliseconds: 500), () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Now select your end date 👇'),
                          backgroundColor: Colors.pink.shade600,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    });
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.play_arrow,
                          color: Theme.of(context).colorScheme.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Start Date',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _startDate != null ? Theme.of(context).colorScheme.primary : null,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _startDate != null 
                                  ? dateFormat.format(_startDate!)
                                  : 'Tap to select when your cycle started',
                              style: TextStyle(
                                color: _startDate != null ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        _startDate != null ? Icons.check_circle : Icons.calendar_today,
                        color: _startDate != null ? Colors.green : Colors.grey.shade400,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // End Date - Prominent Button
          Container(
            width: double.infinity,
            child: Card(
              elevation: _endDate != null ? 0 : 2,
              color: _endDate != null ? Colors.pink.shade50 : null,
              child: InkWell(
                onTap: () async {
                  if (_startDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select start date first'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }
                  await _pickDate(false);
                  if (_canContinueFromDates) {
                    // Auto-advance after both dates are selected
                    Future.delayed(const Duration(milliseconds: 800), () {
                      if (mounted) {
                        _nextStep();
                      }
                    });
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.pink.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.stop,
                          color: Colors.pink.shade400,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'End Date',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _endDate != null ? Colors.pink.shade700 : null,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _endDate != null 
                                  ? dateFormat.format(_endDate!)
                                  : _startDate != null 
                                      ? 'Tap to select when your cycle ended'
                                      : 'Select start date first',
                              style: TextStyle(
                                color: _endDate != null ? Colors.pink.shade600 : Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        _endDate != null ? Icons.check_circle : Icons.calendar_today,
                        color: _endDate != null ? Colors.green : Colors.grey.shade400,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Cycle length display
          if (_startDate != null && _endDate != null) ...[
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.timeline, color: Colors.green.shade600),
                  const SizedBox(width: 12),
                  Text(
                    'Cycle Length: ${_endDate!.difference(_startDate!).inDays + 1} days',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '✨ Great! Moving to flow intensity in a moment...',
              style: TextStyle(
                color: Colors.green.shade600,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildFlowStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Step 2 of 4',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.pink.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Flow Intensity',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.pink.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'How would you describe your flow during this cycle?',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
          const SizedBox(height: 32),
          
          // Flow Options as Cards
          ...List.generate(_flowOptions.length, (index) {
            final flow = _flowOptions[index];
            final isSelected = _flowIntensity == flow;
            
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              child: Card(
                elevation: isSelected ? 0 : 1,
                color: isSelected ? Colors.pink.shade50 : null,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _flowIntensity = flow;
                    });
                    // Auto-advance after selection
                    Future.delayed(const Duration(milliseconds: 800), () {
                      if (mounted) {
                        _nextStep();
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? Colors.pink.shade600 : Colors.transparent,
                            border: Border.all(
                              color: isSelected ? Colors.pink.shade600 : Colors.grey.shade400,
                              width: 2,
                            ),
                          ),
                          child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            flow,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.pink.shade700 : null,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Text(
                            '✨ Selected',
                            style: TextStyle(
                              color: Colors.pink.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWellbeingStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Step 3 of 4',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.pink.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'How are you feeling?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.pink.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Help us understand your wellbeing during this cycle.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
          const SizedBox(height: 32),
          
          // Mood Level
          _buildLevelCard(
            title: 'Mood Level',
            icon: Icons.sentiment_satisfied_alt,
            color: Colors.amber,
            value: _moodLevel,
            labels: _moodLabels,
            onChanged: (value) => setState(() => _moodLevel = value),
          ),
          
          const SizedBox(height: 16),
          
          // Energy Level
          _buildLevelCard(
            title: 'Energy Level',
            icon: Icons.battery_charging_full,
            color: Colors.green,
            value: _energyLevel,
            labels: _energyLabels,
            onChanged: (value) => setState(() => _energyLevel = value),
          ),
          
          const SizedBox(height: 16),
          
          // Pain Level
          _buildLevelCard(
            title: 'Pain Level',
            icon: Icons.healing,
            color: Colors.red,
            value: _painLevel,
            labels: _painLabels,
            onChanged: (value) => setState(() => _painLevel = value),
          ),
          
          const SizedBox(height: 24),
          
          // Continue Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _nextStep(),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Continue to Symptoms'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
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

  Widget _buildSymptomsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Step 4 of 4',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.pink.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Symptoms & Notes',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.pink.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select any symptoms and add optional notes (both are optional).',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
          const SizedBox(height: 32),
          
          // Symptoms Section
          Text(
            'Symptoms (Optional)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap any symptoms you experienced:',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          
          // Selected symptoms count
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
                '${_selectedSymptoms.length} symptom${_selectedSymptoms.length == 1 ? '' : 's'} selected',
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
          
          const SizedBox(height: 32),
          
          // Notes Section
          Text(
            'Notes (Optional)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add any additional notes about this cycle:',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _notesController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'e.g., Had unusual stress, traveled, medication changes...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Summary Card
          Card(
            color: Colors.pink.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.summarize, color: Colors.pink.shade600),
                      const SizedBox(width: 8),
                      Text(
                        'Cycle Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  if (_startDate != null && _endDate != null)
                    Text(
                      'Duration: ${_endDate!.difference(_startDate!).inDays + 1} days (${DateFormat.yMMMd().format(_startDate!)} - ${DateFormat.yMMMd().format(_endDate!)})',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  
                  const SizedBox(height: 4),
                  Text('Flow: $_flowIntensity'),
                  Text('Mood: ${_moodLabels[_moodLevel.round() - 1]}'),
                  Text('Energy: ${_energyLabels[_energyLevel.round() - 1]}'),
                  Text('Pain: ${_painLabels[_painLevel.round() - 1]}'),
                  
                  if (_selectedSymptoms.isNotEmpty)
                    Text('Symptoms: ${_selectedSymptoms.length} selected'),
                  
                  if (_notesController.text.trim().isNotEmpty)
                    Text('Notes: ${_notesController.text.length} characters'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Additional Notes',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add any additional notes about this cycle:',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _notesController,
                maxLines: 8,
                decoration: const InputDecoration(
                  hintText: 'e.g., Had unusual stress this cycle, traveled, medication changes, etc.',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Summary Card
          Card(
            color: Colors.pink.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.summarize, color: Colors.pink.shade600),
                      const SizedBox(width: 8),
                      Text(
                        'Cycle Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  if (_startDate != null && _endDate != null)
                    Text(
                      'Duration: ${_endDate!.difference(_startDate!).inDays + 1} days',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  
                  Text('Flow: $_flowIntensity'),
                  Text('Mood: ${_moodLabels[_moodLevel.round() - 1]}'),
                  Text('Energy: ${_energyLabels[_energyLevel.round() - 1]}'),
                  Text('Pain: ${_painLabels[_painLevel.round() - 1]}'),
                  
                  if (_selectedSymptoms.isNotEmpty)
                    Text('Symptoms: ${_selectedSymptoms.length}'),
                  
                  if (_notesController.text.trim().isNotEmpty)
                    Text('Notes: ${_notesController.text.length} characters'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('🌸 Log Cycle'),
        backgroundColor: Colors.pink.shade50,
        foregroundColor: Colors.pink.shade700,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.pink.shade700),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          if (_currentStep > 0)
            TextButton(
              onPressed: _previousStep,
              child: Text(
                'Back',
                style: TextStyle(color: Colors.pink.shade600),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.pink.shade50,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: List.generate(4, (index) {
                final isCompleted = index < _currentStep;
                final isCurrent = index == _currentStep;
                
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: isCompleted || isCurrent
                                ? Colors.pink.shade600
                                : Colors.grey.shade300,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ['Dates', 'Flow', 'Wellbeing', 'Finish'][index],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isCompleted || isCurrent ? FontWeight.bold : FontWeight.normal,
                            color: isCompleted || isCurrent
                                ? Colors.pink.shade700
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          
          // Page content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Disable swipe to control navigation
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                _buildDateStep(),
                _buildFlowStep(),
                _buildWellbeingStep(),
                _buildSymptomsStep(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: _currentStep < 3
            ? Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _previousStep,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Back'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.pink.shade600,
                          side: BorderSide(color: Colors.pink.shade600),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isCurrentStepComplete ? _nextStep : null,
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(_currentStep == 0 ? 'Continue' : 'Next'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveCycle,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isSaving ? 'Saving...' : 'Save Cycle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
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
