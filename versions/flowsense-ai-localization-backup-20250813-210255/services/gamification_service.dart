import 'dart:math';
import '../models/social_models.dart';

/// Service for managing gamification features like challenges, achievements, and user stats
class GamificationService {
  static final Random _random = Random();

  /// Get active challenges for the user
  static Future<List<Challenge>> getActiveChallenges() async {
    await Future.delayed(const Duration(milliseconds: 600)); // Simulate API call
    
    final challenges = <Challenge>[];
    final now = DateTime.now();
    
    // Daily Challenges
    challenges.addAll([
      Challenge(
        id: 'daily_track',
        title: '📝 Daily Tracker',
        description: 'Log your daily wellbeing data',
        type: ChallengeType.daily,
        targetValue: 1,
        currentProgress: _random.nextBool() ? 1 : 0,
        startDate: DateTime(now.year, now.month, now.day),
        endDate: DateTime(now.year, now.month, now.day, 23, 59, 59),
        participants: _generateParticipants(156),
        reward: '+50 Points',
      ),
      Challenge(
        id: 'daily_water',
        title: '💧 Hydration Hero',
        description: 'Drink at least 8 glasses of water',
        type: ChallengeType.daily,
        targetValue: 8,
        currentProgress: 3 + _random.nextInt(6),
        startDate: DateTime(now.year, now.month, now.day),
        endDate: DateTime(now.year, now.month, now.day, 23, 59, 59),
        participants: _generateParticipants(203),
        reward: '+30 Points',
      ),
      Challenge(
        id: 'daily_mood',
        title: '😊 Mood Check',
        description: 'Track your mood and energy levels',
        type: ChallengeType.daily,
        targetValue: 1,
        currentProgress: _random.nextBool() ? 1 : 0,
        startDate: DateTime(now.year, now.month, now.day),
        endDate: DateTime(now.year, now.month, now.day, 23, 59, 59),
        participants: _generateParticipants(89),
        reward: '+25 Points',
      ),
    ]);
    
    // Weekly Challenges
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    challenges.addAll([
      Challenge(
        id: 'weekly_streak',
        title: '🔥 7-Day Streak',
        description: 'Track your cycle data for 7 consecutive days',
        type: ChallengeType.weekly,
        targetValue: 7,
        currentProgress: 1 + _random.nextInt(7),
        startDate: weekStart,
        endDate: weekStart.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59)),
        participants: _generateParticipants(1247),
        reward: '+200 Points & Streak Master Badge',
      ),
      Challenge(
        id: 'weekly_community',
        title: '💬 Community Supporter',
        description: 'Help 5 community members with comments or likes',
        type: ChallengeType.weekly,
        targetValue: 5,
        currentProgress: _random.nextInt(6),
        startDate: weekStart,
        endDate: weekStart.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59)),
        participants: _generateParticipants(567),
        reward: '+150 Points & Community Helper Badge',
      ),
      Challenge(
        id: 'weekly_wellness',
        title: '🧘 Wellness Week',
        description: 'Complete 3 wellness activities (exercise, meditation, self-care)',
        type: ChallengeType.weekly,
        targetValue: 3,
        currentProgress: _random.nextInt(4),
        startDate: weekStart,
        endDate: weekStart.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59)),
        participants: _generateParticipants(892),
        reward: '+180 Points & Wellness Guru Badge',
      ),
    ]);
    
    // Monthly Challenges
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    challenges.addAll([
      Challenge(
        id: 'monthly_consistent',
        title: '📅 Consistency Champion',
        description: 'Track your data for 25 out of 30 days this month',
        type: ChallengeType.monthly,
        targetValue: 25,
        currentProgress: now.day + _random.nextInt(5) - 2,
        startDate: monthStart,
        endDate: monthEnd,
        participants: _generateParticipants(2156),
        reward: '+500 Points & Consistency Crown',
      ),
    ]);
    
    // Community Challenges
    challenges.addAll([
      Challenge(
        id: 'community_global',
        title: '🌍 Global Period Positivity',
        description: 'Help our community reach 10,000 support interactions',
        type: ChallengeType.community,
        targetValue: 10000,
        currentProgress: 7500 + _random.nextInt(1000),
        startDate: monthStart,
        endDate: monthEnd,
        participants: _generateParticipants(15432),
        reward: 'Exclusive Global Supporter Badge & 1000 Points',
      ),
      Challenge(
        id: 'community_stories',
        title: '📖 Share Your Story',
        description: 'Community goal: 500 inspiring period stories shared',
        type: ChallengeType.community,
        targetValue: 500,
        currentProgress: 342 + _random.nextInt(50),
        startDate: monthStart,
        endDate: monthEnd,
        participants: _generateParticipants(8923),
        reward: 'Storyteller Badge & Special Recognition',
      ),
    ]);
    
    // Mark some challenges as completed
    for (final challenge in challenges) {
      if (challenge.currentProgress >= challenge.targetValue) {
        challenges[challenges.indexOf(challenge)] = Challenge(
          id: challenge.id,
          title: challenge.title,
          description: challenge.description,
          type: challenge.type,
          targetValue: challenge.targetValue,
          currentProgress: challenge.currentProgress,
          startDate: challenge.startDate,
          endDate: challenge.endDate,
          participants: challenge.participants,
          reward: challenge.reward,
          isCompleted: true,
        );
      }
    }
    
    return challenges;
  }

  /// Get recent achievements for the user
  static Future<List<Achievement>> getRecentAchievements() async {
    await Future.delayed(const Duration(milliseconds: 400)); // Simulate API call
    
    final achievements = <Achievement>[];
    final now = DateTime.now();
    
    // Recent achievements based on activity
    if (_random.nextBool()) {
      achievements.add(Achievement(
        id: 'first_week',
        title: 'Welcome to CycleSync! 🎉',
        description: 'Completed your first week of tracking',
        type: AchievementType.tracking,
        iconUrl: '',
        unlockedAt: now.subtract(const Duration(hours: 2)),
        points: 100,
      ));
    }
    
    if (_random.nextBool()) {
      achievements.add(Achievement(
        id: 'community_helper',
        title: 'Community Helper 💕',
        description: 'Helped 10 community members with support',
        type: AchievementType.community,
        iconUrl: '',
        unlockedAt: now.subtract(const Duration(days: 1)),
        points: 150,
        isRare: true,
      ));
    }
    
    if (_random.nextBool()) {
      achievements.add(Achievement(
        id: 'streak_master',
        title: 'Streak Master 🔥',
        description: 'Maintained a 30-day tracking streak',
        type: AchievementType.consistency,
        iconUrl: '',
        unlockedAt: now.subtract(const Duration(days: 3)),
        points: 300,
        isRare: true,
      ));
    }
    
    return achievements;
  }

  /// Get all possible achievements (for display in grid)
  static List<Achievement> getAllPossibleAchievements() {
    final now = DateTime.now();
    
    return [
      // Tracking Achievements
      Achievement(
        id: 'first_log',
        title: 'First Steps',
        description: 'Logged your first daily data',
        type: AchievementType.tracking,
        iconUrl: '',
        unlockedAt: now,
        points: 50,
      ),
      Achievement(
        id: 'week_tracker',
        title: 'Week Warrior',
        description: 'Tracked for 7 consecutive days',
        type: AchievementType.tracking,
        iconUrl: '',
        unlockedAt: now,
        points: 100,
      ),
      Achievement(
        id: 'month_tracker',
        title: 'Monthly Master',
        description: 'Completed a full month of tracking',
        type: AchievementType.tracking,
        iconUrl: '',
        unlockedAt: now,
        points: 250,
      ),
      
      // Consistency Achievements
      Achievement(
        id: 'fire_starter',
        title: 'Fire Starter',
        description: 'Started your first streak',
        type: AchievementType.consistency,
        iconUrl: '',
        unlockedAt: now,
        points: 25,
      ),
      Achievement(
        id: 'streak_keeper',
        title: 'Streak Keeper',
        description: '14-day tracking streak',
        type: AchievementType.consistency,
        iconUrl: '',
        unlockedAt: now,
        points: 150,
      ),
      Achievement(
        id: 'consistency_queen',
        title: 'Consistency Queen',
        description: '100-day tracking streak',
        type: AchievementType.consistency,
        iconUrl: '',
        unlockedAt: now,
        points: 1000,
        isRare: true,
      ),
      
      // Community Achievements
      Achievement(
        id: 'first_like',
        title: 'Supporter',
        description: 'Liked your first community post',
        type: AchievementType.community,
        iconUrl: '',
        unlockedAt: now,
        points: 10,
      ),
      Achievement(
        id: 'comment_hero',
        title: 'Comment Hero',
        description: 'Left 50 helpful comments',
        type: AchievementType.community,
        iconUrl: '',
        unlockedAt: now,
        points: 200,
      ),
      Achievement(
        id: 'community_leader',
        title: 'Community Leader',
        description: 'Top 1% community contributor',
        type: AchievementType.community,
        iconUrl: '',
        unlockedAt: now,
        points: 500,
        isRare: true,
      ),
      
      // Wellness Achievements
      Achievement(
        id: 'self_care_starter',
        title: 'Self-Care Starter',
        description: 'Logged your first wellness activity',
        type: AchievementType.wellness,
        iconUrl: '',
        unlockedAt: now,
        points: 30,
      ),
      Achievement(
        id: 'wellness_warrior',
        title: 'Wellness Warrior',
        description: 'Completed 30 wellness activities',
        type: AchievementType.wellness,
        iconUrl: '',
        unlockedAt: now,
        points: 180,
      ),
      Achievement(
        id: 'mindful_master',
        title: 'Mindful Master',
        description: 'Mastered cycle awareness and wellness',
        type: AchievementType.wellness,
        iconUrl: '',
        unlockedAt: now,
        points: 400,
        isRare: true,
      ),
      
      // Knowledge Achievements
      Achievement(
        id: 'curious_learner',
        title: 'Curious Learner',
        description: 'Read your first educational tip',
        type: AchievementType.knowledge,
        iconUrl: '',
        unlockedAt: now,
        points: 20,
      ),
      Achievement(
        id: 'cycle_scholar',
        title: 'Cycle Scholar',
        description: 'Completed cycle education course',
        type: AchievementType.knowledge,
        iconUrl: '',
        unlockedAt: now,
        points: 300,
      ),
      Achievement(
        id: 'period_professor',
        title: 'Period Professor',
        description: 'Shared 100 educational insights',
        type: AchievementType.knowledge,
        iconUrl: '',
        unlockedAt: now,
        points: 600,
        isRare: true,
      ),
    ];
  }

  /// Get user statistics
  static Future<Map<String, dynamic>> getUserStats() async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate API call
    
    return {
      'level': 5 + _random.nextInt(15), // Level 5-20
      'points': 1250 + _random.nextInt(5000), // 1250-6250 points
      'streak': _random.nextInt(30) + 1, // 1-30 day streak
      'rank': _random.nextInt(1000) + 1, // Rank 1-1000
      'newAchievements': _random.nextInt(3), // 0-2 new achievements
      
      // Monthly stats
      'trackingDays': DateTime.now().day + _random.nextInt(5) - 2,
      'challengesCompleted': _random.nextInt(10),
      'monthlyPoints': 350 + _random.nextInt(200),
      'monthlyAchievements': _random.nextInt(5),
      
      // Global community stats
      'globalUsers': '${10000 + _random.nextInt(5000)}',
      'activeUsers': '${5000 + _random.nextInt(2000)}',
      'todayChallenges': '${100 + _random.nextInt(100)}',
      'supportPosts': '${50 + _random.nextInt(50)}',
    };
  }

  /// Complete a challenge
  static Future<bool> completeChallenge(String challengeId) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call
    
    // In real implementation, this would:
    // 1. Update challenge progress in database
    // 2. Award points and badges
    // 3. Check for achievement unlocks
    // 4. Update user stats
    
    return true; // Success
  }

  /// Award achievement to user
  static Future<Achievement?> checkAndAwardAchievements(Map<String, dynamic> userActivity) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate API call
    
    // In real implementation, this would check various conditions
    // and award appropriate achievements based on user activity
    
    if (_random.nextDouble() < 0.1) { // 10% chance of new achievement
      final achievements = getAllPossibleAchievements();
      return achievements[_random.nextInt(achievements.length)];
    }
    
    return null;
  }

  /// Get leaderboard data
  static Future<List<Map<String, dynamic>>> getLeaderboard({
    String period = 'weekly', // weekly, monthly, all-time
    int limit = 50,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate API call
    
    final leaderboard = <Map<String, dynamic>>[];
    
    // Generate sample leaderboard data
    final names = [
      'CycleQueen', 'FlowGuru', 'PeriodPower', 'MoonChild', 'WellnessWave',
      'CycleStar', 'FlowFriend', 'PeriodPro', 'MoonBeam', 'WellnessWin',
      'CycleSage', 'FlowFab', 'PeriodPal', 'MoonGlow', 'WellnessWiz',
    ];
    
    for (int i = 0; i < limit; i++) {
      final points = (1000 - i * 15) + _random.nextInt(50);
      leaderboard.add({
        'rank': i + 1,
        'username': names[_random.nextInt(names.length)],
        'points': points,
        'streak': _random.nextInt(50) + 1,
        'level': (points / 500).floor() + 1,
        'badges': _random.nextInt(10) + 1,
        'isCurrentUser': i == _random.nextInt(limit), // Random position for current user
      });
    }
    
    return leaderboard;
  }

  /// Generate sample participant list
  static List<String> _generateParticipants(int count) {
    final participants = <String>[];
    for (int i = 0; i < count; i++) {
      participants.add('user_$i');
    }
    return participants;
  }

  /// Get user's challenge progress
  static Future<Map<String, double>> getUserChallengeProgress() async {
    await Future.delayed(const Duration(milliseconds: 200)); // Simulate API call
    
    return {
      'daily_completion': 0.7 + _random.nextDouble() * 0.3, // 70-100%
      'weekly_completion': 0.4 + _random.nextDouble() * 0.6, // 40-100%
      'monthly_completion': 0.2 + _random.nextDouble() * 0.8, // 20-100%
      'community_participation': 0.3 + _random.nextDouble() * 0.7, // 30-100%
    };
  }

  /// Create custom challenge
  static Future<Challenge?> createCustomChallenge({
    required String title,
    required String description,
    required ChallengeType type,
    required int targetValue,
    required String reward,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000)); // Simulate API call
    
    if (title.trim().isEmpty || description.trim().isEmpty) {
      throw Exception('Title and description cannot be empty');
    }
    
    final now = DateTime.now();
    final challenge = Challenge(
      id: 'custom_${now.millisecondsSinceEpoch}',
      title: title,
      description: description,
      type: type,
      targetValue: targetValue,
      currentProgress: 0,
      startDate: now,
      endDate: _getEndDateForType(type, now),
      participants: ['current_user'],
      reward: reward,
    );
    
    return challenge;
  }

  static DateTime _getEndDateForType(ChallengeType type, DateTime startDate) {
    switch (type) {
      case ChallengeType.daily:
        return DateTime(startDate.year, startDate.month, startDate.day, 23, 59, 59);
      case ChallengeType.weekly:
        return startDate.add(const Duration(days: 7));
      case ChallengeType.monthly:
        return DateTime(startDate.year, startDate.month + 1, startDate.day);
      case ChallengeType.community:
        return startDate.add(const Duration(days: 30)); // Default 30 days for community
    }
  }
}
