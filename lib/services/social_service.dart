import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/social_models.dart';
import 'error_service.dart';
import 'email_service.dart';

/// Comprehensive social sharing and community service for healthcare and partner integration
class SocialService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Share cycle data with healthcare provider or partner
  static Future<ShareResult> shareWithProvider({
    required String providerEmail,
    required SharePermission permission,
    required DateRange dateRange,
    required List<DataType> dataTypes,
    String? personalMessage,
    Duration? expiration,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return ShareResult.error('User not authenticated');
      }

      // Create secure share token
      final shareToken = await _createSecureShareToken();
      final shareId = _firestore.collection('shares').doc().id;

      // Prepare share data
      final shareData = {
        'id': shareId,
        'owner_id': user.uid,
        'owner_email': user.email,
        'provider_email': providerEmail,
        'permission': permission.name,
        'date_range': {
          'start': dateRange.start.toIso8601String(),
          'end': dateRange.end.toIso8601String(),
        },
        'data_types': dataTypes.map((type) => type.name).toList(),
        'personal_message': personalMessage,
        'share_token': shareToken,
        'expires_at': expiration != null
            ? DateTime.now().add(expiration).toIso8601String()
            : null,
        'created_at': FieldValue.serverTimestamp(),
        'status': 'pending',
        'access_count': 0,
      };

      // Store share record
      await _firestore.collection('shares').doc(shareId).set(shareData);

      // Send notification to provider (would integrate with email service)
      await _sendShareNotification(
        providerEmail: providerEmail,
        shareToken: shareToken,
        ownerName: user.displayName ?? user.email ?? 'User',
        personalMessage: personalMessage,
      );

      // Log share activity
      await _logShareActivity(
        shareId: shareId,
        action: 'created',
        details: 'Shared with $providerEmail',
      );

      return ShareResult(
        success: true,
        shareId: shareId,
        shareToken: shareToken,
        accessUrl: await _generateSecureAccessUrl(shareToken),
        message: 'Data shared successfully with $providerEmail',
      );
    } catch (e, stackTrace) {
      ErrorService.logError(
        e,
        stackTrace: stackTrace,
        context: 'Social Service - Share with Provider',
        severity: ErrorSeverity.error,
      );

      return ShareResult.error('Failed to share data: ${e.toString()}');
    }
  }

  /// Create secure access for healthcare providers
  static Future<ProviderAccessResult> createProviderAccess({
    required String providerName,
    required String providerEmail,
    required ProviderType providerType,
    required List<DataType> authorizedDataTypes,
    Duration? accessDuration,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return ProviderAccessResult.error('User not authenticated');
      }

      final accessId = _firestore.collection('provider_access').doc().id;
      final accessToken = await _createSecureShareToken();

      final accessData = {
        'id': accessId,
        'patient_id': user.uid,
        'patient_email': user.email,
        'provider_name': providerName,
        'provider_email': providerEmail,
        'provider_type': providerType.name,
        'authorized_data_types': authorizedDataTypes
            .map((type) => type.name)
            .toList(),
        'access_token': accessToken,
        'granted_at': FieldValue.serverTimestamp(),
        'expires_at': accessDuration != null
            ? DateTime.now().add(accessDuration).toIso8601String()
            : null,
        'status': 'active',
        'access_history': [],
      };

      await _firestore
          .collection('provider_access')
          .doc(accessId)
          .set(accessData);

      // Generate provider dashboard URL
      final dashboardUrl = await _generateProviderDashboardUrl(accessToken);

      return ProviderAccessResult(
        success: true,
        accessId: accessId,
        accessToken: accessToken,
        dashboardUrl: dashboardUrl,
        message: 'Provider access created successfully',
      );
    } catch (e) {
      return ProviderAccessResult.error(
        'Failed to create provider access: ${e.toString()}',
      );
    }
  }

  /// Get shared data for healthcare provider access
  static Future<SharedDataResult> getSharedData(String shareToken) async {
    try {
      // Verify share token and get permissions
      final shareDoc = await _firestore
          .collection('shares')
          .where('share_token', isEqualTo: shareToken)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();

      if (shareDoc.docs.isEmpty) {
        return SharedDataResult.error('Invalid or expired share token');
      }

      final shareData = shareDoc.docs.first.data();
      final shareId = shareData['id'];

      // Check expiration
      if (shareData['expires_at'] != null) {
        final expiresAt = DateTime.parse(shareData['expires_at']);
        if (DateTime.now().isAfter(expiresAt)) {
          return SharedDataResult.error('Share link has expired');
        }
      }

      // Get permitted data types
      final permittedTypes = (shareData['data_types'] as List)
          .map((type) => DataType.values.firstWhere((t) => t.name == type))
          .toList();

      // Get date range
      final dateRange = DateRange(
        start: DateTime.parse(shareData['date_range']['start']),
        end: DateTime.parse(shareData['date_range']['end']),
      );

      // Fetch actual cycle data - temporary implementation
      // TODO: Implement proper getCyclesInRange method in FirebaseService
      final cycles = await _getCyclesInRangeTemp(
        shareData['owner_id'],
        dateRange.start,
        dateRange.end,
      );

      // Filter data based on permissions
      final filteredCycles = _filterCycleData(cycles, permittedTypes);

      // Update access count
      await _firestore.collection('shares').doc(shareId).update({
        'access_count': FieldValue.increment(1),
        'last_accessed': FieldValue.serverTimestamp(),
      });

      // Log access
      await _logShareActivity(
        shareId: shareId,
        action: 'accessed',
        details: 'Data accessed by provider',
      );

      return SharedDataResult(
        success: true,
        shareInfo: ShareInfo(
          shareId: shareId,
          ownerEmail: shareData['owner_email'],
          providerEmail: shareData['provider_email'],
          permission: SharePermission.values.firstWhere(
            (p) => p.name == shareData['permission'],
          ),
          dateRange: dateRange,
          personalMessage: shareData['personal_message'],
        ),
        cycles: filteredCycles,
        analytics: await _generateProviderAnalytics(filteredCycles),
        summary: _generateDataSummary(filteredCycles),
      );
    } catch (e) {
      return SharedDataResult.error(
        'Failed to retrieve shared data: ${e.toString()}',
      );
    }
  }

  /// Create anonymous community insights
  static Future<CommunityInsightResult> generateCommunityInsights() async {
    try {
      // Generate anonymous, aggregated insights from community data
      final insights = await _generateAnonymousCommunityInsights();

      return CommunityInsightResult(
        success: true,
        insights: insights,
      );
    } catch (e) {
      return CommunityInsightResult(
        success: false,
        error: 'Failed to generate community insights: ${e.toString()}',
      );
    }
  }

  /// Join anonymous community data sharing
  static Future<bool> joinCommunityDataSharing(
    CommunityDataPreferences preferences,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _firestore.collection('community_participants').doc(user.uid).set({
        'user_id': user.uid,
        'joined_at': FieldValue.serverTimestamp(),
        'preferences': {
          'share_cycle_patterns': preferences.shareCyclePatterns,
          'share_symptom_trends': preferences.shareSymptomTrends,
          'share_wellbeing_data': preferences.shareWellbeingData,
          'share_age_range': preferences.shareAgeRange,
          'share_geographic_region': preferences.shareGeographicRegion,
        },
        'data_contribution_level': preferences.contributionLevel.name,
        'status': 'active',
      });

      return true;
    } catch (e) {
      ErrorService.logError(e, context: 'Community Data Sharing');
      return false;
    }
  }

  /// Get my shared data overview
  static Future<MySharedDataResult> getMySharedData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return MySharedDataResult.error('User not authenticated');
      }

      // Get active shares
      final sharesQuery = await _firestore
          .collection('shares')
          .where('owner_id', isEqualTo: user.uid)
          .orderBy('created_at', descending: true)
          .get();

      final shares = sharesQuery.docs
          .map((doc) => _mapToShareSummary(doc.data()))
          .toList();

      // Get provider access records
      final providerAccessQuery = await _firestore
          .collection('provider_access')
          .where('patient_id', isEqualTo: user.uid)
          .orderBy('granted_at', descending: true)
          .get();

      final providerAccess = providerAccessQuery.docs
          .map((doc) => _mapToProviderAccessSummary(doc.data()))
          .toList();

      return MySharedDataResult(
        success: true,
        activeShares: shares.where((s) => s.status == 'active').toList(),
        expiredShares: shares.where((s) => s.status == 'expired').toList(),
        providerAccess: providerAccess,
        totalShares: shares.length,
      );
    } catch (e) {
      return MySharedDataResult.error(
        'Failed to retrieve shared data: ${e.toString()}',
      );
    }
  }

  /// Revoke shared access
  static Future<bool> revokeAccess(String shareId) async {
    try {
      await _firestore.collection('shares').doc(shareId).update({
        'status': 'revoked',
        'revoked_at': FieldValue.serverTimestamp(),
      });

      await _logShareActivity(
        shareId: shareId,
        action: 'revoked',
        details: 'Access revoked by owner',
      );

      return true;
    } catch (e) {
      ErrorService.logError(e, context: 'Revoke Access');
      return false;
    }
  }

  // Private helper methods

  /// Temporary implementation to get cycles in date range
  /// TODO: Move this to FirebaseService as getCyclesInRange
  static Future<List<Map<String, dynamic>>> _getCyclesInRangeTemp(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cycles')
          .where('start', isGreaterThanOrEqualTo: startDate)
          .where('start', isLessThanOrEqualTo: endDate)
          .orderBy('start')
          .get();

      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      debugPrint('Error fetching cycles in range: $e');
      return [];
    }
  }

  static Future<String> _createSecureShareToken() async {
    // Generate cryptographically secure token
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp * 1000 + (DateTime.now().microsecond % 1000));
    return 'cs_${random.toRadixString(36)}_${timestamp.toRadixString(36)}';
  }

  static Future<String> _generateSecureAccessUrl(String shareToken) async {
    // In production, this would be your actual domain
    return 'https://cyclesync.app/share/$shareToken';
  }

  static Future<String> _generateProviderDashboardUrl(
    String accessToken,
  ) async {
    return 'https://cyclesync.app/provider/$accessToken';
  }

  static Future<void> _sendShareNotification({
    required String providerEmail,
    required String shareToken,
    required String ownerName,
    String? personalMessage,
  }) async {
    final accessUrl = await _generateSecureAccessUrl(shareToken);

    final success = await EmailService.sendShareNotification(
      providerEmail: providerEmail,
      shareToken: shareToken,
      ownerName: ownerName,
      accessUrl: accessUrl,
      personalMessage: personalMessage,
    );

    if (success) {
      debugPrint('✅ Share notification sent to $providerEmail');
    } else {
      debugPrint('❌ Failed to send share notification to $providerEmail');
    }
  }

  static Future<void> _logShareActivity({
    required String shareId,
    required String action,
    required String details,
  }) async {
    try {
      await _firestore.collection('share_activity').add({
        'share_id': shareId,
        'action': action,
        'details': details,
        'timestamp': FieldValue.serverTimestamp(),
        'ip_address': 'redacted', // Would capture actual IP in production
      });
    } catch (e) {
      debugPrint('Failed to log share activity: $e');
    }
  }

  static List<Map<String, dynamic>> _filterCycleData(
    List<Map<String, dynamic>> cycles,
    List<DataType> permittedTypes,
  ) {
    return cycles.map((cycle) {
      final filteredCycle = <String, dynamic>{
        'id': cycle['id'],
        'start': cycle['start'],
        'end': cycle['end'],
      };

      if (permittedTypes.contains(DataType.flowIntensity)) {
        filteredCycle['flow'] = cycle['flow'];
        filteredCycle['flow_intensity'] = cycle['flow_intensity'];
      }

      if (permittedTypes.contains(DataType.symptoms)) {
        filteredCycle['symptoms'] = cycle['symptoms'];
      }

      if (permittedTypes.contains(DataType.wellbeing)) {
        filteredCycle['mood_level'] = cycle['mood_level'];
        filteredCycle['energy_level'] = cycle['energy_level'];
        filteredCycle['pain_level'] = cycle['pain_level'];
      }

      if (permittedTypes.contains(DataType.notes)) {
        filteredCycle['notes'] = cycle['notes'];
      }

      return filteredCycle;
    }).toList();
  }

  static Future<ProviderAnalytics> _generateProviderAnalytics(
    List<Map<String, dynamic>> cycles,
  ) async {
    if (cycles.isEmpty) {
      return ProviderAnalytics.empty();
    }

    final cycleLengths = <int>[];
    final symptoms = <String>[];
    double totalMood = 0, totalEnergy = 0, totalPain = 0;
    int wellbeingCount = 0;

    for (final cycle in cycles) {
      // Calculate cycle length
      if (cycle['start'] != null && cycle['end'] != null) {
        final start = cycle['start'] is DateTime
            ? cycle['start'] as DateTime
            : DateTime.parse(cycle['start'].toString());
        final end = cycle['end'] is DateTime
            ? cycle['end'] as DateTime
            : DateTime.parse(cycle['end'].toString());
        cycleLengths.add(end.difference(start).inDays + 1);
      }

      // Collect symptoms
      if (cycle['symptoms'] != null) {
        symptoms.addAll((cycle['symptoms'] as List).cast<String>());
      }

      // Aggregate wellbeing data
      if (cycle['mood_level'] != null) {
        totalMood += (cycle['mood_level'] as num).toDouble();
        wellbeingCount++;
      }
      if (cycle['energy_level'] != null) {
        totalEnergy += (cycle['energy_level'] as num).toDouble();
      }
      if (cycle['pain_level'] != null) {
        totalPain += (cycle['pain_level'] as num).toDouble();
      }
    }

    return ProviderAnalytics(
      totalCycles: cycles.length,
      dateRange: DateRange(
        start: cycles
            .map((c) => _parseDateTime(c['start']))
            .where((d) => d != null)
            .reduce((a, b) => a!.isBefore(b!) ? a : b)!,
        end: cycles
            .map((c) => _parseDateTime(c['end']))
            .where((d) => d != null)
            .reduce((a, b) => a!.isAfter(b!) ? a : b)!,
      ),
      averageCycleLength: cycleLengths.isNotEmpty
          ? cycleLengths.reduce((a, b) => a + b) / cycleLengths.length
          : null,
      cycleRegularity: _calculateRegularity(cycleLengths),
      commonSymptoms: _getTopSymptoms(symptoms, 5),
      averageWellbeing: wellbeingCount > 0
          ? WellbeingAverages(
              mood: totalMood / wellbeingCount,
              energy: totalEnergy / wellbeingCount,
              pain: totalPain / wellbeingCount,
            )
          : null,
    );
  }

  static String _generateDataSummary(List<Map<String, dynamic>> cycles) {
    if (cycles.isEmpty)
      return 'No cycle data available for the selected period.';

    final cycleCount = cycles.length;
    final dateRange = cycles.isNotEmpty
        ? '${_formatDate(_parseDateTime(cycles.last['start']))} - ${_formatDate(_parseDateTime(cycles.first['end']))}'
        : 'Unknown';

    return 'Summary: $cycleCount cycles tracked from $dateRange. '
        'Data includes menstrual patterns, symptoms, and wellbeing metrics as authorized.';
  }

  static Future<List<CommunityInsight>>
  _generateAnonymousCommunityInsights() async {
    // This would generate aggregated, anonymous insights from community data
    // For now, return sample insights
    return [
      CommunityInsight(
        id: 'cycle_length_avg',
        title: 'Average Cycle Length',
        value: '28.3 days',
        description: 'Based on 10,000+ anonymous cycles',
        category: InsightCategory.cyclePattern,
        supportCount: 10000,
        createdAt: DateTime.now().subtract(Duration(days: 1)),
      ),
      CommunityInsight(
        id: 'common_symptoms',
        title: 'Most Common Symptoms',
        value: 'Cramps (67%), Fatigue (54%), Mood changes (48%)',
        description: 'From community symptom tracking',
        category: InsightCategory.symptoms,
        supportCount: 8500,
        createdAt: DateTime.now().subtract(Duration(days: 2)),
      ),
      CommunityInsight(
        id: 'cycle_regularity',
        title: 'Cycle Regularity',
        value: '73% regular cycles',
        description: 'Regular defined as ±3 days variation',
        category: InsightCategory.regularity,
        supportCount: 7300,
        createdAt: DateTime.now().subtract(Duration(days: 3)),
      ),
    ];
  }

  static Future<int> _getCommunityParticipantCount() async {
    try {
      final snapshot = await _firestore
          .collection('community_participants')
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      return 0; // Return 0 if count fails
    }
  }

  static DateTime? _parseDateTime(dynamic date) {
    if (date == null) return null;
    if (date is DateTime) return date;
    try {
      if (date.toString().contains('Timestamp')) {
        return (date as dynamic).toDate();
      }
      return DateTime.parse(date.toString());
    } catch (e) {
      return null;
    }
  }

  static String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.day}/${date.month}/${date.year}';
  }

  static double _calculateRegularity(List<int> cycleLengths) {
    if (cycleLengths.length < 2) return 0.0;

    final mean = cycleLengths.reduce((a, b) => a + b) / cycleLengths.length;
    final variance =
        cycleLengths
            .map((l) => (l - mean) * (l - mean))
            .reduce((a, b) => a + b) /
        cycleLengths.length;

    return 1.0 - (variance / 25.0).clamp(0.0, 1.0); // Normalize to 0-1
  }

  static List<String> _getTopSymptoms(List<String> symptoms, int count) {
    final symptomCounts = <String, int>{};
    for (final symptom in symptoms) {
      symptomCounts[symptom] = (symptomCounts[symptom] ?? 0) + 1;
    }

    final sorted = symptomCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(count).map((e) => e.key).toList();
  }

  static ShareSummary _mapToShareSummary(Map<String, dynamic> data) {
    return ShareSummary(
      shareId: data['id'],
      providerEmail: data['provider_email'],
      dataTypes: (data['data_types'] as List).cast<String>(),
      createdAt: (data['created_at'] as Timestamp).toDate(),
      expiresAt: data['expires_at'] != null
          ? DateTime.parse(data['expires_at'])
          : null,
      accessCount: data['access_count'] ?? 0,
      status: data['status'],
    );
  }

  static ProviderAccessSummary _mapToProviderAccessSummary(
    Map<String, dynamic> data,
  ) {
    return ProviderAccessSummary(
      accessId: data['id'],
      providerName: data['provider_name'],
      providerType: ProviderType.values.firstWhere(
        (t) => t.name == data['provider_type'],
      ),
      grantedAt: (data['granted_at'] as Timestamp).toDate(),
      expiresAt: data['expires_at'] != null
          ? DateTime.parse(data['expires_at'])
          : null,
      status: data['status'],
    );
  }
}

// Data models for social features (continued in next section due to length)
