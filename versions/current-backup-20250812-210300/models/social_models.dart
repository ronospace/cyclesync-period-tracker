/// Data models for social sharing and community features
enum SharePermission {
  viewOnly,
  fullAccess,
  limitedAnalytics,
}

enum DataType {
  cyclePattern,
  flowIntensity,
  symptoms,
  wellbeing,
  notes,
  analytics,
}

enum ProviderType {
  gynecologist,
  generalPractitioner,
  nutritionist,
  mentalHealth,
  fertility,
  endocrinologist,
  other,
}

enum ContributionLevel {
  minimal,
  standard,
  comprehensive,
}

enum InsightCategory {
  cyclePattern,
  symptoms,
  wellbeing,
  regularity,
  lifestyle,
}

class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange({
    required this.start,
    required this.end,
  });

  Duration get duration => end.difference(start);
  
  bool contains(DateTime date) {
    return date.isAfter(start.subtract(const Duration(days: 1))) && 
           date.isBefore(end.add(const Duration(days: 1)));
  }

  @override
  String toString() {
    return '${start.day}/${start.month}/${start.year} - ${end.day}/${end.month}/${end.year}';
  }
}

class ShareResult {
  final bool success;
  final String? shareId;
  final String? shareToken;
  final String? accessUrl;
  final String message;
  final String? error;

  ShareResult({
    required this.success,
    this.shareId,
    this.shareToken,
    this.accessUrl,
    required this.message,
    this.error,
  });

  ShareResult.error(String errorMessage)
      : success = false,
        shareId = null,
        shareToken = null,
        accessUrl = null,
        message = 'Error occurred',
        error = errorMessage;
}

class ProviderAccessResult {
  final bool success;
  final String? accessId;
  final String? accessToken;
  final String? dashboardUrl;
  final String message;
  final String? error;

  ProviderAccessResult({
    required this.success,
    this.accessId,
    this.accessToken,
    this.dashboardUrl,
    required this.message,
    this.error,
  });

  ProviderAccessResult.error(String errorMessage)
      : success = false,
        accessId = null,
        accessToken = null,
        dashboardUrl = null,
        message = 'Error occurred',
        error = errorMessage;
}

class SharedDataResult {
  final bool success;
  final ShareInfo? shareInfo;
  final List<Map<String, dynamic>>? cycles;
  final ProviderAnalytics? analytics;
  final String? summary;
  final String? error;

  SharedDataResult({
    required this.success,
    this.shareInfo,
    this.cycles,
    this.analytics,
    this.summary,
    this.error,
  });

  SharedDataResult.error(String errorMessage)
      : success = false,
        shareInfo = null,
        cycles = null,
        analytics = null,
        summary = null,
        error = errorMessage;
}

class ShareInfo {
  final String shareId;
  final String ownerEmail;
  final String providerEmail;
  final SharePermission permission;
  final DateRange dateRange;
  final String? personalMessage;

  ShareInfo({
    required this.shareId,
    required this.ownerEmail,
    required this.providerEmail,
    required this.permission,
    required this.dateRange,
    this.personalMessage,
  });
}

class ProviderAnalytics {
  final int totalCycles;
  final DateRange dateRange;
  final double? averageCycleLength;
  final double cycleRegularity; // 0.0 to 1.0
  final List<String> commonSymptoms;
  final WellbeingAverages? averageWellbeing;

  ProviderAnalytics({
    required this.totalCycles,
    required this.dateRange,
    this.averageCycleLength,
    required this.cycleRegularity,
    required this.commonSymptoms,
    this.averageWellbeing,
  });

  static ProviderAnalytics empty() {
    return ProviderAnalytics(
      totalCycles: 0,
      dateRange: DateRange(start: DateTime.now(), end: DateTime.now()),
      cycleRegularity: 0.0,
      commonSymptoms: [],
    );
  }
}

class WellbeingAverages {
  final double mood;
  final double energy;
  final double pain;

  WellbeingAverages({
    required this.mood,
    required this.energy,
    required this.pain,
  });
}

class CommunityInsightResult {
  final bool success;
  final List<CommunityInsight>? insights;
  final int? participantCount;
  final DateTime? lastUpdated;
  final String? error;

  CommunityInsightResult({
    required this.success,
    this.insights,
    this.participantCount,
    this.lastUpdated,
    this.error,
  });

  CommunityInsightResult.error(String errorMessage)
      : success = false,
        insights = null,
        participantCount = null,
        lastUpdated = null,
        error = errorMessage;
}

class CommunityInsight {
  final String title;
  final String value;
  final String description;
  final InsightCategory category;
  final Map<String, dynamic>? metadata;

  CommunityInsight({
    required this.title,
    required this.value,
    required this.description,
    required this.category,
    this.metadata,
  });
}

class CommunityDataPreferences {
  final bool shareCyclePatterns;
  final bool shareSymptomTrends;
  final bool shareWellbeingData;
  final bool shareAgeRange;
  final bool shareGeographicRegion;
  final ContributionLevel contributionLevel;

  CommunityDataPreferences({
    this.shareCyclePatterns = false,
    this.shareSymptomTrends = false,
    this.shareWellbeingData = false,
    this.shareAgeRange = false,
    this.shareGeographicRegion = false,
    this.contributionLevel = ContributionLevel.minimal,
  });

  Map<String, dynamic> toJson() {
    return {
      'share_cycle_patterns': shareCyclePatterns,
      'share_symptom_trends': shareSymptomTrends,
      'share_wellbeing_data': shareWellbeingData,
      'share_age_range': shareAgeRange,
      'share_geographic_region': shareGeographicRegion,
      'contribution_level': contributionLevel.name,
    };
  }

  static CommunityDataPreferences fromJson(Map<String, dynamic> json) {
    return CommunityDataPreferences(
      shareCyclePatterns: json['share_cycle_patterns'] ?? false,
      shareSymptomTrends: json['share_symptom_trends'] ?? false,
      shareWellbeingData: json['share_wellbeing_data'] ?? false,
      shareAgeRange: json['share_age_range'] ?? false,
      shareGeographicRegion: json['share_geographic_region'] ?? false,
      contributionLevel: ContributionLevel.values.firstWhere(
        (level) => level.name == json['contribution_level'],
        orElse: () => ContributionLevel.minimal,
      ),
    );
  }
}

class MySharedDataResult {
  final bool success;
  final List<ShareSummary>? activeShares;
  final List<ShareSummary>? expiredShares;
  final List<ProviderAccessSummary>? providerAccess;
  final int? totalShares;
  final String? error;

  MySharedDataResult({
    required this.success,
    this.activeShares,
    this.expiredShares,
    this.providerAccess,
    this.totalShares,
    this.error,
  });

  MySharedDataResult.error(String errorMessage)
      : success = false,
        activeShares = null,
        expiredShares = null,
        providerAccess = null,
        totalShares = null,
        error = errorMessage;
}

class ShareSummary {
  final String shareId;
  final String providerEmail;
  final List<String> dataTypes;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final int accessCount;
  final String status;

  ShareSummary({
    required this.shareId,
    required this.providerEmail,
    required this.dataTypes,
    required this.createdAt,
    this.expiresAt,
    required this.accessCount,
    required this.status,
  });

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get isActive => status == 'active' && !isExpired;

  String get timeRemaining {
    if (expiresAt == null) return 'No expiration';
    if (isExpired) return 'Expired';
    
    final remaining = expiresAt!.difference(DateTime.now());
    if (remaining.inDays > 0) {
      return '${remaining.inDays} days remaining';
    } else if (remaining.inHours > 0) {
      return '${remaining.inHours} hours remaining';
    } else {
      return '${remaining.inMinutes} minutes remaining';
    }
  }
}

class ProviderAccessSummary {
  final String accessId;
  final String providerName;
  final ProviderType providerType;
  final DateTime grantedAt;
  final DateTime? expiresAt;
  final String status;

  ProviderAccessSummary({
    required this.accessId,
    required this.providerName,
    required this.providerType,
    required this.grantedAt,
    this.expiresAt,
    required this.status,
  });

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get isActive => status == 'active' && !isExpired;

  String get providerTypeDisplayName {
    switch (providerType) {
      case ProviderType.gynecologist:
        return 'Gynecologist';
      case ProviderType.generalPractitioner:
        return 'General Practitioner';
      case ProviderType.nutritionist:
        return 'Nutritionist';
      case ProviderType.mentalHealth:
        return 'Mental Health Professional';
      case ProviderType.fertility:
        return 'Fertility Specialist';
      case ProviderType.endocrinologist:
        return 'Endocrinologist';
      case ProviderType.other:
        return 'Other Healthcare Provider';
    }
  }
}

// Extensions for enhanced functionality
extension SharePermissionExtension on SharePermission {
  String get displayName {
    switch (this) {
      case SharePermission.viewOnly:
        return 'View Only';
      case SharePermission.fullAccess:
        return 'Full Access';
      case SharePermission.limitedAnalytics:
        return 'Limited Analytics';
    }
  }

  String get description {
    switch (this) {
      case SharePermission.viewOnly:
        return 'Provider can view basic cycle data and patterns';
      case SharePermission.fullAccess:
        return 'Provider can view all data including detailed notes and symptoms';
      case SharePermission.limitedAnalytics:
        return 'Provider can view aggregated analytics and trends only';
    }
  }

  List<DataType> get allowedDataTypes {
    switch (this) {
      case SharePermission.viewOnly:
        return [DataType.cyclePattern];
      case SharePermission.fullAccess:
        return DataType.values;
      case SharePermission.limitedAnalytics:
        return [DataType.analytics, DataType.cyclePattern];
    }
  }
}

extension DataTypeExtension on DataType {
  String get displayName {
    switch (this) {
      case DataType.cyclePattern:
        return 'Cycle Patterns';
      case DataType.flowIntensity:
        return 'Flow Intensity';
      case DataType.symptoms:
        return 'Symptoms';
      case DataType.wellbeing:
        return 'Wellbeing Data';
      case DataType.notes:
        return 'Personal Notes';
      case DataType.analytics:
        return 'Analytics & Insights';
    }
  }

  String get description {
    switch (this) {
      case DataType.cyclePattern:
        return 'Menstrual cycle start/end dates and lengths';
      case DataType.flowIntensity:
        return 'Flow heaviness and intensity levels';
      case DataType.symptoms:
        return 'Physical and emotional symptoms';
      case DataType.wellbeing:
        return 'Mood, energy, and pain levels';
      case DataType.notes:
        return 'Personal notes and observations';
      case DataType.analytics:
        return 'Aggregated insights and predictions';
    }
  }

  bool get isSensitive {
    switch (this) {
      case DataType.notes:
      case DataType.wellbeing:
        return true;
      case DataType.cyclePattern:
      case DataType.flowIntensity:
      case DataType.symptoms:
      case DataType.analytics:
        return false;
    }
  }
}

extension ContributionLevelExtension on ContributionLevel {
  String get displayName {
    switch (this) {
      case ContributionLevel.minimal:
        return 'Minimal';
      case ContributionLevel.standard:
        return 'Standard';
      case ContributionLevel.comprehensive:
        return 'Comprehensive';
    }
  }

  String get description {
    switch (this) {
      case ContributionLevel.minimal:
        return 'Share basic cycle patterns only';
      case ContributionLevel.standard:
        return 'Share cycles, symptoms, and trends';
      case ContributionLevel.comprehensive:
        return 'Share all data to help research';
    }
  }

  List<DataType> get includedDataTypes {
    switch (this) {
      case ContributionLevel.minimal:
        return [DataType.cyclePattern];
      case ContributionLevel.standard:
        return [DataType.cyclePattern, DataType.symptoms, DataType.flowIntensity];
      case ContributionLevel.comprehensive:
        return [
          DataType.cyclePattern,
          DataType.symptoms,
          DataType.flowIntensity,
          DataType.wellbeing,
        ];
    }
  }
}
