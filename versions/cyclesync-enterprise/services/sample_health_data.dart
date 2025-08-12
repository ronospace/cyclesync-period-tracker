import 'dart:math' as math;
import 'advanced_health_kit_service.dart';

/// Sample health data generator for testing advanced charts
/// Creates realistic health data patterns for demonstration
class SampleHealthData {
  
  /// Generate sample heart rate data with realistic patterns
  static List<HealthDataPoint> generateHeartRateData({int days = 7}) {
    final data = <HealthDataPoint>[];
    final now = DateTime.now();
    final random = math.Random();
    
    for (int day = 0; day < days; day++) {
      // Generate 12-24 readings per day (every 1-2 hours)
      final readingsPerDay = 12 + random.nextInt(12);
      
      for (int reading = 0; reading < readingsPerDay; reading++) {
        final date = now.subtract(Duration(days: days - day - 1))
            .add(Duration(hours: reading * 2, minutes: random.nextInt(60)));
        
        // Realistic heart rate with circadian rhythm
        double baseHR = 65 + random.nextGaussian() * 8; // Normal resting HR
        
        // Add circadian variation (higher during day, lower at night)
        final hour = date.hour;
        if (hour >= 6 && hour <= 22) {
          baseHR += 10 + random.nextInt(15); // Daytime increase
        } else {
          baseHR -= 5 + random.nextInt(10); // Nighttime decrease
        }
        
        // Add some activity spikes
        if (random.nextDouble() < 0.1) {
          baseHR += 30 + random.nextInt(40); // Exercise/activity spike
        }
        
        baseHR = math.max(45, math.min(180, baseHR)); // Keep in valid range
        
        data.add(HealthDataPoint(
          value: baseHR,
          date: date,
          unit: 'bpm',
        ));
      }
    }
    
    return data..sort((a, b) => a.date.compareTo(b.date));
  }
  
  /// Generate sample HRV data with stress patterns
  static List<HealthDataPoint> generateHRVData({int days = 7}) {
    final data = <HealthDataPoint>[];
    final now = DateTime.now();
    final random = math.Random();
    
    for (int day = 0; day < days; day++) {
      final date = now.subtract(Duration(days: days - day - 1));
      
      // Realistic HRV values (20-50ms range, higher = less stress)
      double baseHRV = 35 + random.nextGaussian() * 8;
      
      // Add weekly stress pattern (Monday stress, Friday relief)
      final weekday = date.weekday;
      if (weekday == 1 || weekday == 2) { // Monday/Tuesday
        baseHRV -= 8; // Higher stress
      } else if (weekday >= 5) { // Friday/Weekend
        baseHRV += 5; // Lower stress
      }
      
      // Simulate cycle-related stress variations
      final cycleDay = (days - day) % 28;
      if (cycleDay >= 22 && cycleDay <= 27) { // PMS period
        baseHRV -= 10;
      }
      
      baseHRV = math.max(15, math.min(55, baseHRV)); // Keep in valid range
      
      data.add(HealthDataPoint(
        value: baseHRV,
        date: date,
        unit: 'ms',
      ));
    }
    
    return data;
  }
  
  /// Generate sample sleep data with realistic sleep stages
  static List<SleepData> generateSleepData({int days = 7}) {
    final data = <SleepData>[];
    final now = DateTime.now();
    final random = math.Random();
    
    for (int day = 0; day < days; day++) {
      final sleepDate = now.subtract(Duration(days: days - day - 1));
      
      // Random bedtime (9 PM - 12 AM)
      final bedtimeHour = 21 + random.nextInt(3);
      final bedtimeMinute = random.nextInt(60);
      final bedtime = DateTime(
        sleepDate.year, sleepDate.month, sleepDate.day,
        bedtimeHour, bedtimeMinute,
      );
      
      // Sleep duration (6-9 hours)
      final sleepHours = 6.5 + random.nextDouble() * 2.5;
      final wakeTime = bedtime.add(Duration(
        hours: sleepHours.floor(),
        minutes: ((sleepHours % 1) * 60).round(),
      ));
      
      // Create sleep stages
      final stages = ['inBed', 'light', 'deep', 'rem', 'core', 'awake'];
      final stageWeights = [0.1, 0.3, 0.2, 0.2, 0.15, 0.05]; // Realistic distribution
      
      for (int i = 0; i < stages.length; i++) {
        final stage = stages[i];
        final weight = stageWeights[i];
        final stageDuration = sleepHours * 3600 * weight; // Convert to seconds
        
        if (stageDuration > 300) { // At least 5 minutes
          data.add(SleepData(
            stage: stage,
            startDate: bedtime,
            endDate: wakeTime,
            duration: stageDuration,
          ));
        }
      }
    }
    
    return data;
  }
  
  /// Generate sample body temperature data with ovulation pattern
  static List<HealthDataPoint> generateTemperatureData({int days = 28}) {
    final data = <HealthDataPoint>[];
    final now = DateTime.now();
    final random = math.Random();
    
    for (int day = 0; day < days; day++) {
      final date = now.subtract(Duration(days: days - day - 1));
      
      // Base body temperature (97.8-98.6°F = 36.6-37.0°C)
      double baseTemp = 36.7 + random.nextGaussian() * 0.1;
      
      // Simulate menstrual cycle temperature pattern
      final cycleDay = day + 1;
      
      if (cycleDay <= 5) {
        // Menstrual phase - slightly lower
        baseTemp -= 0.1;
      } else if (cycleDay >= 6 && cycleDay <= 13) {
        // Follicular phase - low and stable
        baseTemp -= 0.05;
      } else if (cycleDay >= 14 && cycleDay <= 16) {
        // Ovulation - temperature rises
        baseTemp += 0.3 + (cycleDay - 14) * 0.1;
      } else {
        // Luteal phase - elevated and stable
        baseTemp += 0.2;
      }
      
      // Add small daily variations
      baseTemp += (random.nextDouble() - 0.5) * 0.1;
      
      data.add(HealthDataPoint(
        value: baseTemp,
        date: date,
        unit: '°C',
      ));
    }
    
    return data;
  }
  
  /// Generate sample activity data with realistic patterns
  static List<ActivityData> generateActivityData({int days = 7}) {
    final data = <ActivityData>[];
    final now = DateTime.now();
    final random = math.Random();
    
    for (int day = 0; day < days; day++) {
      final date = now.subtract(Duration(days: days - day - 1));
      
      // Base step count (sedentary to active lifestyle)
      double steps = 3000 + random.nextGaussian() * 2000;
      
      // Weekend vs weekday patterns
      final isWeekend = date.weekday >= 6;
      if (isWeekend) {
        steps += random.nextInt(3000); // More variable on weekends
      } else {
        steps += 2000; // Consistent weekday activity
      }
      
      // Add workout days (30% chance)
      if (random.nextDouble() < 0.3) {
        steps += 2000 + random.nextInt(4000); // Exercise day
      }
      
      steps = math.max(1000, math.min(25000, steps)); // Keep realistic
      
      // Calculate active energy based on steps
      final activeEnergy = (steps / 20) + random.nextInt(100); // ~1 cal per 20 steps
      
      data.add(ActivityData(
        date: date,
        steps: steps,
        activeEnergy: activeEnergy,
        unit: 'steps',
      ));
    }
    
    return data;
  }
}

extension GaussianRandom on math.Random {
  /// Generate a Gaussian (normal) random number with mean 0 and std dev 1
  double nextGaussian() {
    if (_hasSpare) {
      _hasSpare = false;
      return _spare;
    }
    
    _hasSpare = true;
    
    final u = nextDouble();
    final v = nextDouble();
    final magnitude = math.sqrt(-2.0 * math.log(u));
    
    _spare = magnitude * math.sin(2.0 * math.pi * v);
    return magnitude * math.cos(2.0 * math.pi * v);
  }
  
  static bool _hasSpare = false;
  static double _spare = 0.0;
}
