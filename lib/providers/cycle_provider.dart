import 'package:flutter/foundation.dart';
import '../models/cycle_models.dart';

class CycleProvider extends ChangeNotifier {
  List<CycleData> _cycles = [];
  CycleData? _currentCycle;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<CycleData> get cycles => List.unmodifiable(_cycles);
  CycleData? get currentCycle => _currentCycle;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Basic cycle management
  void addCycle(CycleData cycle) {
    _cycles.add(cycle);
    _cycles.sort((a, b) => b.startDate.compareTo(a.startDate));
    _updateCurrentCycle();
    notifyListeners();
  }

  void updateCycle(CycleData cycle) {
    final index = _cycles.indexWhere((c) => c.id == cycle.id);
    if (index != -1) {
      _cycles[index] = cycle;
      _updateCurrentCycle();
      notifyListeners();
    }
  }

  void removeCycle(String cycleId) {
    _cycles.removeWhere((c) => c.id == cycleId);
    _updateCurrentCycle();
    notifyListeners();
  }

  void _updateCurrentCycle() {
    final now = DateTime.now();
    _currentCycle = _cycles.where((cycle) {
      final endDate = cycle.endDate ?? now;
      return now.isAfter(cycle.startDate) && now.isBefore(endDate.add(const Duration(days: 1)));
    }).firstOrNull;
  }

  // Load cycles (placeholder for actual implementation)
  Future<void> loadCycles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate loading delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // In a real app, this would load from a database or service
      // For now, just ensure we have a current cycle for testing
      if (_cycles.isEmpty) {
        final testCycle = CycleData(
          id: 'current_cycle',
          startDate: DateTime.now().subtract(const Duration(days: 10)),
          symptoms: [],
          userId: 'test_user',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          wellbeing: WellbeingData(
            mood: 0.7,
            energy: 0.6,
            stress: 0.4,
            sleep: 0.8,
          ),
        );
        _cycles.add(testCycle);
        _updateCurrentCycle();
      }
    } catch (e) {
      _error = 'Failed to load cycles: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear all data
  void clear() {
    _cycles.clear();
    _currentCycle = null;
    _error = null;
    notifyListeners();
  }
}
