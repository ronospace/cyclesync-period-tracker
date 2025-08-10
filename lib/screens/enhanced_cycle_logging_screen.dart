import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';

class EnhancedCycleLoggingScreen extends StatefulWidget {
  const EnhancedCycleLoggingScreen({super.key});

  @override
  State<EnhancedCycleLoggingScreen> createState() => _EnhancedCycleLoggingScreenState();
}

class _EnhancedCycleLoggingScreenState extends State<EnhancedCycleLoggingScreen> with TickerProviderStateMixin {
  late TabController _tabController;
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
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notesController.dispose();
    super.dispose();
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

      // Update notifications
      try {
        final cycles = await FirebaseService.getCycles();
        await NotificationService.updateCycleNotifications(cycles);
      } catch (e) {
        debugPrint('Failed to update notifications: $e');
      }

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

  Widget _buildBasicsTab() {
    final dateFormat = DateFormat.yMMMd();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cycle Dates',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Start Date
          Card(
            child: ListTile(
              leading: Icon(Icons.play_arrow, color: Colors.pink.shade600),
              title: const Text('Start Date'),
              subtitle: Text(
                _startDate != null 
                    ? dateFormat.format(_startDate!)
                    : 'Tap to select start date',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _pickDate(true),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // End Date
          Card(
            child: ListTile(
              leading: Icon(Icons.stop, color: Colors.pink.shade400),
              title: const Text('End Date'),
              subtitle: Text(
                _endDate != null 
                    ? dateFormat.format(_endDate!)
                    : 'Tap to select end date',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _pickDate(false),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Flow Intensity
          Text(
            'Flow Intensity',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: _flowOptions.map((flow) {
                  return RadioListTile<String>(
                    title: Text(flow),
                    value: flow,
                    groupValue: _flowIntensity,
                    onChanged: (value) {
                      setState(() {
                        _flowIntensity = value!;
                      });
                    },
                    activeColor: Colors.pink.shade600,
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWellbeingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How are you feeling?',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
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

  Widget _buildSymptomsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Symptoms',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select any symptoms you\'re experiencing:',
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
      appBar: AppBar(
        title: const Text('🌸 Log Cycle'),
        backgroundColor: Colors.pink.shade50,
        foregroundColor: Colors.pink.shade700,
        iconTheme: IconThemeData(color: Colors.pink.shade700),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.pink.shade700),
          onPressed: () => context.go('/home'),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Basics', icon: Icon(Icons.calendar_today, size: 16)),
            Tab(text: 'Wellbeing', icon: Icon(Icons.favorite, size: 16)),
            Tab(text: 'Symptoms', icon: Icon(Icons.healing, size: 16)),
            Tab(text: 'Notes', icon: Icon(Icons.note, size: 16)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBasicsTab(),
          _buildWellbeingTab(),
          _buildSymptomsTab(),
          _buildNotesTab(),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
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
            backgroundColor: Colors.pink.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
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
