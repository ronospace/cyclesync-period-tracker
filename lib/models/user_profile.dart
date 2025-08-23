import 'package:cloud_firestore/cloud_firestore.dart';

/// Comprehensive user profile model for CycleSync app
/// Handles all user data including personal info, preferences, cycle data, and app settings
class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final String? username;
  final String? photoURL;
  final DateTime createdAt;
  final DateTime lastSignIn;
  final DateTime? updatedAt;

  // Authentication & Security
  final String authProvider;
  final bool isEmailVerified;
  final bool biometricEnabled;

  // Personal Information
  final String? firstName;
  final String? lastName;
  final DateTime? dateOfBirth;
  final String? phoneNumber;
  final String? timezone;
  final String language;

  // Cycle Tracking Data
  final CycleTrackingData cycleData;

  // App Preferences
  final UserPreferences preferences;

  // Social Features
  final SocialProfile socialProfile;

  // App Statistics
  final UserStats stats;

  const UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    this.username,
    this.photoURL,
    required this.createdAt,
    required this.lastSignIn,
    this.updatedAt,
    this.authProvider = 'email',
    this.isEmailVerified = false,
    this.biometricEnabled = false,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.phoneNumber,
    this.timezone,
    this.language = 'en',
    required this.cycleData,
    required this.preferences,
    required this.socialProfile,
    required this.stats,
  });

  /// Get the user's full name (firstName + lastName or displayName as fallback)
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return displayName;
  }

  /// Get the user's first name or displayName as fallback
  String get preferredName {
    return firstName ?? displayName.split(' ').first;
  }

  /// Check if user has completed basic profile setup
  bool get isProfileComplete {
    return displayName.isNotEmpty &&
        isEmailVerified &&
        cycleData.hasBasicCycleData;
  }

  /// Check if user needs onboarding
  bool get needsOnboarding {
    return !isProfileComplete || !stats.hasCompletedOnboarding;
  }

  /// Factory constructor from Firestore document
  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserProfile(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      username: data['username'],
      photoURL: data['photoURL'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastSignIn:
          (data['lastSignIn'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      authProvider: data['authProvider'] ?? 'email',
      isEmailVerified: data['isEmailVerified'] ?? false,
      biometricEnabled: data['biometricEnabled'] ?? false,
      firstName: data['firstName'],
      lastName: data['lastName'],
      dateOfBirth: (data['dateOfBirth'] as Timestamp?)?.toDate(),
      phoneNumber: data['phoneNumber'],
      timezone: data['timezone'],
      language: data['language'] ?? 'en',
      cycleData: CycleTrackingData.fromMap(data['cycleData'] ?? {}),
      preferences: UserPreferences.fromMap(data['preferences'] ?? {}),
      socialProfile: SocialProfile.fromMap(data['socialProfile'] ?? {}),
      stats: UserStats.fromMap(data['stats'] ?? {}),
    );
  }

  /// Factory constructor from Map
  factory UserProfile.fromMap(Map<String, dynamic> data) {
    return UserProfile(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      username: data['username'],
      photoURL: data['photoURL'],
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(data['createdAt']?.toString() ?? '') ??
                DateTime.now(),
      lastSignIn: data['lastSignIn'] is Timestamp
          ? (data['lastSignIn'] as Timestamp).toDate()
          : DateTime.tryParse(data['lastSignIn']?.toString() ?? '') ??
                DateTime.now(),
      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.tryParse(data['updatedAt']?.toString() ?? ''),
      authProvider: data['authProvider'] ?? 'email',
      isEmailVerified: data['isEmailVerified'] ?? false,
      biometricEnabled: data['biometricEnabled'] ?? false,
      firstName: data['firstName'],
      lastName: data['lastName'],
      dateOfBirth: data['dateOfBirth'] is Timestamp
          ? (data['dateOfBirth'] as Timestamp).toDate()
          : DateTime.tryParse(data['dateOfBirth']?.toString() ?? ''),
      phoneNumber: data['phoneNumber'],
      timezone: data['timezone'],
      language: data['language'] ?? 'en',
      cycleData: CycleTrackingData.fromMap(data['cycleData'] ?? {}),
      preferences: UserPreferences.fromMap(data['preferences'] ?? {}),
      socialProfile: SocialProfile.fromMap(data['socialProfile'] ?? {}),
      stats: UserStats.fromMap(data['stats'] ?? {}),
    );
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'username': username,
      'photoURL': photoURL,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastSignIn': Timestamp.fromDate(lastSignIn),
      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : FieldValue.serverTimestamp(),
      'authProvider': authProvider,
      'isEmailVerified': isEmailVerified,
      'biometricEnabled': biometricEnabled,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth != null
          ? Timestamp.fromDate(dateOfBirth!)
          : null,
      'phoneNumber': phoneNumber,
      'timezone': timezone,
      'language': language,
      'cycleData': cycleData.toMap(),
      'preferences': preferences.toMap(),
      'socialProfile': socialProfile.toMap(),
      'stats': stats.toMap(),
    };
  }

  /// Convert to Map for local storage (uses ISO strings instead of Timestamps)
  Map<String, dynamic> toLocalStorageMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'username': username,
      'photoURL': photoURL,
      'createdAt': createdAt.toIso8601String(),
      'lastSignIn': lastSignIn.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'authProvider': authProvider,
      'isEmailVerified': isEmailVerified,
      'biometricEnabled': biometricEnabled,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'phoneNumber': phoneNumber,
      'timezone': timezone,
      'language': language,
      'cycleData': cycleData.toLocalStorageMap(),
      'preferences': preferences.toMap(),
      'socialProfile': socialProfile.toMap(),
      'stats': stats.toLocalStorageMap(),
    };
  }

  /// Create a copy with updated fields
  UserProfile copyWith({
    String? email,
    String? displayName,
    String? username,
    String? photoURL,
    DateTime? lastSignIn,
    DateTime? updatedAt,
    String? authProvider,
    bool? isEmailVerified,
    bool? biometricEnabled,
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    String? phoneNumber,
    String? timezone,
    String? language,
    CycleTrackingData? cycleData,
    UserPreferences? preferences,
    SocialProfile? socialProfile,
    UserStats? stats,
  }) {
    return UserProfile(
      uid: uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt,
      lastSignIn: lastSignIn ?? this.lastSignIn,
      updatedAt: updatedAt ?? DateTime.now(),
      authProvider: authProvider ?? this.authProvider,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      timezone: timezone ?? this.timezone,
      language: language ?? this.language,
      cycleData: cycleData ?? this.cycleData,
      preferences: preferences ?? this.preferences,
      socialProfile: socialProfile ?? this.socialProfile,
      stats: stats ?? this.stats,
    );
  }

  @override
  String toString() {
    return 'UserProfile(uid: $uid, displayName: $displayName, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}

/// Cycle tracking data model
class CycleTrackingData {
  final int averageCycleLength;
  final int averagePeriodLength;
  final DateTime? trackingStartDate;
  final DateTime? lastPeriodDate;
  final DateTime? nextPeriodPrediction;
  final DateTime? nextOvulationPrediction;
  final bool isPregnant;
  final bool isTryingToConceive;
  final String trackingMethod;

  const CycleTrackingData({
    this.averageCycleLength = 28,
    this.averagePeriodLength = 5,
    this.trackingStartDate,
    this.lastPeriodDate,
    this.nextPeriodPrediction,
    this.nextOvulationPrediction,
    this.isPregnant = false,
    this.isTryingToConceive = false,
    this.trackingMethod = 'calendar',
  });

  bool get hasBasicCycleData {
    return trackingStartDate != null || lastPeriodDate != null;
  }

  factory CycleTrackingData.fromMap(Map<String, dynamic> data) {
    return CycleTrackingData(
      averageCycleLength: data['averageCycleLength'] ?? 28,
      averagePeriodLength: data['averagePeriodLength'] ?? 5,
      trackingStartDate: data['trackingStartDate'] is Timestamp
          ? (data['trackingStartDate'] as Timestamp).toDate()
          : DateTime.tryParse(data['trackingStartDate']?.toString() ?? ''),
      lastPeriodDate: data['lastPeriodDate'] is Timestamp
          ? (data['lastPeriodDate'] as Timestamp).toDate()
          : DateTime.tryParse(data['lastPeriodDate']?.toString() ?? ''),
      nextPeriodPrediction: data['nextPeriodPrediction'] is Timestamp
          ? (data['nextPeriodPrediction'] as Timestamp).toDate()
          : DateTime.tryParse(data['nextPeriodPrediction']?.toString() ?? ''),
      nextOvulationPrediction: data['nextOvulationPrediction'] is Timestamp
          ? (data['nextOvulationPrediction'] as Timestamp).toDate()
          : DateTime.tryParse(
              data['nextOvulationPrediction']?.toString() ?? '',
            ),
      isPregnant: data['isPregnant'] ?? false,
      isTryingToConceive: data['isTryingToConceive'] ?? false,
      trackingMethod: data['trackingMethod'] ?? 'calendar',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'averageCycleLength': averageCycleLength,
      'averagePeriodLength': averagePeriodLength,
      'trackingStartDate': trackingStartDate != null
          ? Timestamp.fromDate(trackingStartDate!)
          : null,
      'lastPeriodDate': lastPeriodDate != null
          ? Timestamp.fromDate(lastPeriodDate!)
          : null,
      'nextPeriodPrediction': nextPeriodPrediction != null
          ? Timestamp.fromDate(nextPeriodPrediction!)
          : null,
      'nextOvulationPrediction': nextOvulationPrediction != null
          ? Timestamp.fromDate(nextOvulationPrediction!)
          : null,
      'isPregnant': isPregnant,
      'isTryingToConceive': isTryingToConceive,
      'trackingMethod': trackingMethod,
    };
  }

  Map<String, dynamic> toLocalStorageMap() {
    return {
      'averageCycleLength': averageCycleLength,
      'averagePeriodLength': averagePeriodLength,
      'trackingStartDate': trackingStartDate?.toIso8601String(),
      'lastPeriodDate': lastPeriodDate?.toIso8601String(),
      'nextPeriodPrediction': nextPeriodPrediction?.toIso8601String(),
      'nextOvulationPrediction': nextOvulationPrediction?.toIso8601String(),
      'isPregnant': isPregnant,
      'isTryingToConceive': isTryingToConceive,
      'trackingMethod': trackingMethod,
    };
  }

  CycleTrackingData copyWith({
    int? averageCycleLength,
    int? averagePeriodLength,
    DateTime? trackingStartDate,
    DateTime? lastPeriodDate,
    DateTime? nextPeriodPrediction,
    DateTime? nextOvulationPrediction,
    bool? isPregnant,
    bool? isTryingToConceive,
    String? trackingMethod,
  }) {
    return CycleTrackingData(
      averageCycleLength: averageCycleLength ?? this.averageCycleLength,
      averagePeriodLength: averagePeriodLength ?? this.averagePeriodLength,
      trackingStartDate: trackingStartDate ?? this.trackingStartDate,
      lastPeriodDate: lastPeriodDate ?? this.lastPeriodDate,
      nextPeriodPrediction: nextPeriodPrediction ?? this.nextPeriodPrediction,
      nextOvulationPrediction:
          nextOvulationPrediction ?? this.nextOvulationPrediction,
      isPregnant: isPregnant ?? this.isPregnant,
      isTryingToConceive: isTryingToConceive ?? this.isTryingToConceive,
      trackingMethod: trackingMethod ?? this.trackingMethod,
    );
  }
}

/// User preferences model
class UserPreferences {
  final bool notifications;
  final bool reminders;
  final bool dataSharing;
  final bool smartInsights;
  final bool communityFeatures;
  final bool biometricAuth;
  final String theme;
  final String language;
  final bool healthKitSync;
  final bool partnerSharing;

  const UserPreferences({
    this.notifications = true,
    this.reminders = true,
    this.dataSharing = false,
    this.smartInsights = true,
    this.communityFeatures = true,
    this.biometricAuth = false,
    this.theme = 'system',
    this.language = 'en',
    this.healthKitSync = false,
    this.partnerSharing = false,
  });

  factory UserPreferences.fromMap(Map<String, dynamic> data) {
    return UserPreferences(
      notifications: data['notifications'] ?? true,
      reminders: data['reminders'] ?? true,
      dataSharing: data['dataSharing'] ?? false,
      smartInsights: data['smartInsights'] ?? true,
      communityFeatures: data['communityFeatures'] ?? true,
      biometricAuth: data['biometricAuth'] ?? false,
      theme: data['theme'] ?? 'system',
      language: data['language'] ?? 'en',
      healthKitSync: data['healthKitSync'] ?? false,
      partnerSharing: data['partnerSharing'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notifications': notifications,
      'reminders': reminders,
      'dataSharing': dataSharing,
      'smartInsights': smartInsights,
      'communityFeatures': communityFeatures,
      'biometricAuth': biometricAuth,
      'theme': theme,
      'language': language,
      'healthKitSync': healthKitSync,
      'partnerSharing': partnerSharing,
    };
  }

  UserPreferences copyWith({
    bool? notifications,
    bool? reminders,
    bool? dataSharing,
    bool? smartInsights,
    bool? communityFeatures,
    bool? biometricAuth,
    String? theme,
    String? language,
    bool? healthKitSync,
    bool? partnerSharing,
  }) {
    return UserPreferences(
      notifications: notifications ?? this.notifications,
      reminders: reminders ?? this.reminders,
      dataSharing: dataSharing ?? this.dataSharing,
      smartInsights: smartInsights ?? this.smartInsights,
      communityFeatures: communityFeatures ?? this.communityFeatures,
      biometricAuth: biometricAuth ?? this.biometricAuth,
      theme: theme ?? this.theme,
      language: language ?? this.language,
      healthKitSync: healthKitSync ?? this.healthKitSync,
      partnerSharing: partnerSharing ?? this.partnerSharing,
    );
  }
}

/// Social profile model
class SocialProfile {
  final bool isPublic;
  final bool allowPartnerInvitations;
  final String? partnerId;
  final List<String> communityGroups;
  final int friendsCount;
  final String privacyLevel;

  const SocialProfile({
    this.isPublic = false,
    this.allowPartnerInvitations = true,
    this.partnerId,
    this.communityGroups = const [],
    this.friendsCount = 0,
    this.privacyLevel = 'private',
  });

  factory SocialProfile.fromMap(Map<String, dynamic> data) {
    return SocialProfile(
      isPublic: data['isPublic'] ?? false,
      allowPartnerInvitations: data['allowPartnerInvitations'] ?? true,
      partnerId: data['partnerId'],
      communityGroups: List<String>.from(data['communityGroups'] ?? []),
      friendsCount: data['friendsCount'] ?? 0,
      privacyLevel: data['privacyLevel'] ?? 'private',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isPublic': isPublic,
      'allowPartnerInvitations': allowPartnerInvitations,
      'partnerId': partnerId,
      'communityGroups': communityGroups,
      'friendsCount': friendsCount,
      'privacyLevel': privacyLevel,
    };
  }

  SocialProfile copyWith({
    bool? isPublic,
    bool? allowPartnerInvitations,
    String? partnerId,
    List<String>? communityGroups,
    int? friendsCount,
    String? privacyLevel,
  }) {
    return SocialProfile(
      isPublic: isPublic ?? this.isPublic,
      allowPartnerInvitations:
          allowPartnerInvitations ?? this.allowPartnerInvitations,
      partnerId: partnerId ?? this.partnerId,
      communityGroups: communityGroups ?? this.communityGroups,
      friendsCount: friendsCount ?? this.friendsCount,
      privacyLevel: privacyLevel ?? this.privacyLevel,
    );
  }
}

/// User statistics model
class UserStats {
  final DateTime joinDate;
  final int totalLogins;
  final DateTime lastActive;
  final int cycleDaysTracked;
  final int symptomsRecorded;
  final int aiInsightsReceived;
  final bool hasCompletedOnboarding;
  final DateTime? onboardingCompletedAt;
  final String appVersion;

  const UserStats({
    required this.joinDate,
    this.totalLogins = 0,
    required this.lastActive,
    this.cycleDaysTracked = 0,
    this.symptomsRecorded = 0,
    this.aiInsightsReceived = 0,
    this.hasCompletedOnboarding = false,
    this.onboardingCompletedAt,
    this.appVersion = '1.0.0',
  });

  factory UserStats.fromMap(Map<String, dynamic> data) {
    return UserStats(
      joinDate: data['joinDate'] is Timestamp
          ? (data['joinDate'] as Timestamp).toDate()
          : DateTime.tryParse(data['joinDate']?.toString() ?? '') ??
                DateTime.now(),
      totalLogins: data['totalLogins'] ?? 0,
      lastActive: data['lastActive'] is Timestamp
          ? (data['lastActive'] as Timestamp).toDate()
          : DateTime.tryParse(data['lastActive']?.toString() ?? '') ??
                DateTime.now(),
      cycleDaysTracked: data['cycleDaysTracked'] ?? 0,
      symptomsRecorded: data['symptomsRecorded'] ?? 0,
      aiInsightsReceived: data['aiInsightsReceived'] ?? 0,
      hasCompletedOnboarding: data['hasCompletedOnboarding'] ?? false,
      onboardingCompletedAt: data['onboardingCompletedAt'] is Timestamp
          ? (data['onboardingCompletedAt'] as Timestamp).toDate()
          : DateTime.tryParse(data['onboardingCompletedAt']?.toString() ?? ''),
      appVersion: data['appVersion'] ?? '1.0.0',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'joinDate': Timestamp.fromDate(joinDate),
      'totalLogins': totalLogins,
      'lastActive': Timestamp.fromDate(lastActive),
      'cycleDaysTracked': cycleDaysTracked,
      'symptomsRecorded': symptomsRecorded,
      'aiInsightsReceived': aiInsightsReceived,
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'onboardingCompletedAt': onboardingCompletedAt != null
          ? Timestamp.fromDate(onboardingCompletedAt!)
          : null,
      'appVersion': appVersion,
    };
  }

  Map<String, dynamic> toLocalStorageMap() {
    return {
      'joinDate': joinDate.toIso8601String(),
      'totalLogins': totalLogins,
      'lastActive': lastActive.toIso8601String(),
      'cycleDaysTracked': cycleDaysTracked,
      'symptomsRecorded': symptomsRecorded,
      'aiInsightsReceived': aiInsightsReceived,
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'onboardingCompletedAt': onboardingCompletedAt?.toIso8601String(),
      'appVersion': appVersion,
    };
  }

  UserStats copyWith({
    DateTime? joinDate,
    int? totalLogins,
    DateTime? lastActive,
    int? cycleDaysTracked,
    int? symptomsRecorded,
    int? aiInsightsReceived,
    bool? hasCompletedOnboarding,
    DateTime? onboardingCompletedAt,
    String? appVersion,
  }) {
    return UserStats(
      joinDate: joinDate ?? this.joinDate,
      totalLogins: totalLogins ?? this.totalLogins,
      lastActive: lastActive ?? this.lastActive,
      cycleDaysTracked: cycleDaysTracked ?? this.cycleDaysTracked,
      symptomsRecorded: symptomsRecorded ?? this.symptomsRecorded,
      aiInsightsReceived: aiInsightsReceived ?? this.aiInsightsReceived,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      onboardingCompletedAt:
          onboardingCompletedAt ?? this.onboardingCompletedAt,
      appVersion: appVersion ?? this.appVersion,
    );
  }
}
