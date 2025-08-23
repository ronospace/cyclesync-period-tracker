import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../models/user_profile.dart';
import 'cache_service.dart';
import 'error_service.dart';

/// Persistent user data service that handles both local and cloud storage
/// Ensures user information is always available and synchronized
class PersistentUserService {
  static final PersistentUserService _instance =
      PersistentUserService._internal();
  factory PersistentUserService() => _instance;
  PersistentUserService._internal();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  SharedPreferences? _prefs;
  UserProfile? _cachedUserProfile;
  bool _initialized = false;

  // Storage keys
  static const String _userProfileKey = 'stored_user_profile';
  static const String _lastSyncKey = 'last_user_sync';
  static const String _userDisplayNameKey = 'user_display_name';
  static const String _userEmailKey = 'user_email';
  static const String _userUidKey = 'user_uid';
  static const String _userPreferencesKey = 'user_preferences';
  static const String _isFirstLaunchKey = 'is_first_launch';

  /// Initialize the service
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();

      // Load cached user profile if available
      await _loadCachedUserProfile();

      // If user is signed in, sync with cloud
      if (_auth.currentUser != null) {
        await _syncUserData();
      }

      _initialized = true;
      debugPrint('✅ PersistentUserService initialized');
    } catch (e, stackTrace) {
      ErrorService.logError(
        e,
        stackTrace: stackTrace,
        context: 'PersistentUserService.initialize',
        severity: ErrorSeverity.fatal,
      );
    }
  }

  /// Get current user profile (from cache or storage)
  Future<UserProfile?> getCurrentUserProfile() async {
    await initialize();

    // Return cached profile if available
    if (_cachedUserProfile != null) {
      return _cachedUserProfile;
    }

    // Try to load from SharedPreferences
    await _loadCachedUserProfile();
    if (_cachedUserProfile != null) {
      return _cachedUserProfile;
    }

    // Try to load from Firestore if user is signed in
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      return await getUserProfileFromCloud(currentUser.uid);
    }

    return null;
  }

  /// Save user profile to both local and cloud storage
  Future<void> saveUserProfile(UserProfile userProfile) async {
    await initialize();

    try {
      // Update cached profile
      _cachedUserProfile = userProfile;

      // Save to local storage
      await _saveToLocalStorage(userProfile);

      // Save essential user data separately for quick access
      await _saveEssentialUserData(userProfile);

      // Save to cloud storage
      await _saveToCloudStorage(userProfile);

      // Update last sync timestamp
      await _prefs?.setString(_lastSyncKey, DateTime.now().toIso8601String());

      debugPrint('✅ User profile saved: ${userProfile.displayName}');
    } catch (e, stackTrace) {
      ErrorService.logError(
        e,
        stackTrace: stackTrace,
        context: 'PersistentUserService.saveUserProfile',
        severity: ErrorSeverity.fatal,
      );
      rethrow;
    }
  }

  /// Update user profile with new data
  Future<UserProfile?> updateUserProfile(Map<String, dynamic> updates) async {
    await initialize();

    try {
      final currentProfile = await getCurrentUserProfile();
      if (currentProfile == null) return null;

      // Create updated profile
      final updatedProfile = UserProfile.fromMap({
        ...currentProfile.toMap(),
        ...updates,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Save updated profile
      await saveUserProfile(updatedProfile);

      return updatedProfile;
    } catch (e, stackTrace) {
      ErrorService.logError(
        e,
        stackTrace: stackTrace,
        context: 'PersistentUserService.updateUserProfile',
        severity: ErrorSeverity.fatal,
      );
      return null;
    }
  }

  /// Update user display name (most common update)
  Future<bool> updateDisplayName(String displayName) async {
    await initialize();

    try {
      // Update Firebase Auth profile
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
      }

      // Update stored profile
      await updateUserProfile({'displayName': displayName});

      // Update quick access storage
      await _prefs?.setString(_userDisplayNameKey, displayName);

      return true;
    } catch (e, stackTrace) {
      ErrorService.logError(
        e,
        stackTrace: stackTrace,
        context: 'PersistentUserService.updateDisplayName',
        severity: ErrorSeverity.warning,
      );
      return false;
    }
  }

  /// Get user display name quickly (without full profile load)
  Future<String?> getDisplayName() async {
    await initialize();

    // Try quick access first
    final storedName = _prefs?.getString(_userDisplayNameKey);
    if (storedName != null && storedName.isNotEmpty) {
      return storedName;
    }

    // Try from cached profile
    if (_cachedUserProfile != null) {
      return _cachedUserProfile!.displayName;
    }

    // Try from Firebase Auth
    final user = _auth.currentUser;
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      // Cache it for next time
      await _prefs?.setString(_userDisplayNameKey, user.displayName!);
      return user.displayName;
    }

    // Load full profile as last resort
    final profile = await getCurrentUserProfile();
    return profile?.displayName;
  }

  /// Get user email quickly
  Future<String?> getUserEmail() async {
    await initialize();

    // Try quick access first
    final storedEmail = _prefs?.getString(_userEmailKey);
    if (storedEmail != null && storedEmail.isNotEmpty) {
      return storedEmail;
    }

    // Try from Firebase Auth
    final user = _auth.currentUser;
    final userEmail = user?.email;
    if (userEmail != null) {
      // Cache it for next time
      await _prefs?.setString(_userEmailKey, userEmail);
      return userEmail;
    }

    return null;
  }

  /// Get user preferences quickly
  Future<UserPreferences?> getUserPreferences() async {
    await initialize();

    // Try quick access first
    final storedPrefsJson = _prefs?.getString(_userPreferencesKey);
    if (storedPrefsJson != null) {
      try {
        final prefsMap = jsonDecode(storedPrefsJson) as Map<String, dynamic>;
        return UserPreferences.fromMap(prefsMap);
      } catch (e) {
        // Ignore parse error, fall back to full profile
      }
    }

    // Try from cached profile
    if (_cachedUserProfile != null) {
      return _cachedUserProfile!.preferences;
    }

    // Load full profile
    final profile = await getCurrentUserProfile();
    return profile?.preferences;
  }

  /// Update user preferences
  Future<bool> updateUserPreferences(UserPreferences preferences) async {
    await initialize();

    try {
      // Update quick access storage
      await _prefs?.setString(
        _userPreferencesKey,
        jsonEncode(preferences.toMap()),
      );

      // Update full profile
      await updateUserProfile({'preferences': preferences.toMap()});

      return true;
    } catch (e, stackTrace) {
      ErrorService.logError(
        e,
        stackTrace: stackTrace,
        context: 'PersistentUserService.updateUserPreferences',
        severity: ErrorSeverity.warning,
      );
      return false;
    }
  }

  /// Check if this is the first app launch
  Future<bool> isFirstLaunch() async {
    await initialize();
    return !(_prefs?.getBool(_isFirstLaunchKey) ?? false);
  }

  /// Mark first launch as complete
  Future<void> markFirstLaunchComplete() async {
    await initialize();
    await _prefs?.setBool(_isFirstLaunchKey, true);
  }

  /// Sync user data with cloud storage
  Future<void> syncUserData() async {
    await initialize();
    await _syncUserData();
  }

  /// Get user profile from cloud storage
  Future<UserProfile?> getUserProfileFromCloud(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        return null;
      }

      final profile = UserProfile.fromFirestore(doc);

      // Cache the profile locally
      _cachedUserProfile = profile;
      await _saveToLocalStorage(profile);
      await _saveEssentialUserData(profile);

      return profile;
    } catch (e, stackTrace) {
      ErrorService.logError(
        e,
        stackTrace: stackTrace,
        context: 'PersistentUserService.getUserProfileFromCloud',
        severity: ErrorSeverity.warning,
      );
      return null;
    }
  }

  /// Create initial user profile after sign up
  Future<UserProfile?> createUserProfile({
    required String uid,
    required String email,
    required String displayName,
    String? firstName,
    String? lastName,
    String authProvider = 'email',
  }) async {
    await initialize();

    try {
      final now = DateTime.now();

      final userProfile = UserProfile(
        uid: uid,
        email: email,
        displayName: displayName,
        firstName: firstName,
        lastName: lastName,
        createdAt: now,
        lastSignIn: now,
        authProvider: authProvider,
        language: 'en', // Default to English, can be updated later
        cycleData: const CycleTrackingData(),
        preferences: const UserPreferences(),
        socialProfile: const SocialProfile(),
        stats: UserStats(joinDate: now, lastActive: now, totalLogins: 1),
      );

      await saveUserProfile(userProfile);

      debugPrint('✅ User profile created for: $displayName');
      return userProfile;
    } catch (e, stackTrace) {
      ErrorService.logError(
        e,
        stackTrace: stackTrace,
        context: 'PersistentUserService.createUserProfile',
        severity: ErrorSeverity.fatal,
      );
      return null;
    }
  }

  /// Clear all stored user data (for sign out)
  Future<void> clearUserData() async {
    await initialize();

    try {
      // Clear cached profile
      _cachedUserProfile = null;

      // Clear local storage
      await _prefs?.remove(_userProfileKey);
      await _prefs?.remove(_userDisplayNameKey);
      await _prefs?.remove(_userEmailKey);
      await _prefs?.remove(_userUidKey);
      await _prefs?.remove(_userPreferencesKey);
      await _prefs?.remove(_lastSyncKey);

      // Clear cache service
      await CacheService().removePattern('user:.*');

      debugPrint('✅ User data cleared');
    } catch (e, stackTrace) {
      ErrorService.logError(
        e,
        stackTrace: stackTrace,
        context: 'PersistentUserService.clearUserData',
        severity: ErrorSeverity.info,
      );
    }
  }

  /// Record user activity (login, app usage, etc.)
  Future<void> recordUserActivity() async {
    await initialize();

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Update last active timestamp
      await updateUserProfile({'lastSignIn': DateTime.now().toIso8601String()});

      // Update stats
      final profile = await getCurrentUserProfile();
      if (profile != null) {
        final updatedStats = profile.stats.copyWith(
          totalLogins: profile.stats.totalLogins + 1,
          lastActive: DateTime.now(),
        );

        await updateUserProfile({'stats': updatedStats.toMap()});
      }
    } catch (e, stackTrace) {
      ErrorService.logError(
        e,
        stackTrace: stackTrace,
        context: 'PersistentUserService.recordUserActivity',
        severity: ErrorSeverity.info,
      );
    }
  }

  // Private helper methods

  Future<void> _loadCachedUserProfile() async {
    try {
      final profileJson = _prefs?.getString(_userProfileKey);
      if (profileJson != null && profileJson.isNotEmpty) {
        final profileMap = jsonDecode(profileJson) as Map<String, dynamic>;
        _cachedUserProfile = UserProfile.fromMap(profileMap);
      }
    } catch (e) {
      // Ignore parse errors, profile will be loaded from cloud
      debugPrint('Failed to parse cached user profile: $e');
    }
  }

  Future<void> _saveToLocalStorage(UserProfile userProfile) async {
    try {
      final profileJson = jsonEncode(userProfile.toLocalStorageMap());
      await _prefs?.setString(_userProfileKey, profileJson);
    } catch (e, stackTrace) {
      ErrorService.logError(
        e,
        stackTrace: stackTrace,
        context: 'PersistentUserService._saveToLocalStorage',
        severity: ErrorSeverity.warning,
      );
    }
  }

  Future<void> _saveEssentialUserData(UserProfile userProfile) async {
    try {
      await _prefs?.setString(_userDisplayNameKey, userProfile.displayName);
      await _prefs?.setString(_userEmailKey, userProfile.email);
      await _prefs?.setString(_userUidKey, userProfile.uid);
      await _prefs?.setString(
        _userPreferencesKey,
        jsonEncode(userProfile.preferences.toMap()),
      );
    } catch (e, stackTrace) {
      ErrorService.logError(
        e,
        stackTrace: stackTrace,
        context: 'PersistentUserService._saveEssentialUserData',
        severity: ErrorSeverity.info,
      );
    }
  }

  Future<void> _saveToCloudStorage(UserProfile userProfile) async {
    try {
      await _firestore
          .collection('users')
          .doc(userProfile.uid)
          .set(userProfile.toMap(), SetOptions(merge: true));
    } catch (e, stackTrace) {
      ErrorService.logError(
        e,
        stackTrace: stackTrace,
        context: 'PersistentUserService._saveToCloudStorage',
        severity: ErrorSeverity.fatal,
      );
      // Don't rethrow - local storage is still successful
    }
  }

  Future<void> _syncUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Get latest profile from cloud
      final cloudProfile = await getUserProfileFromCloud(user.uid);

      if (cloudProfile != null) {
        // Update local cache
        _cachedUserProfile = cloudProfile;
        await _saveToLocalStorage(cloudProfile);
        await _saveEssentialUserData(cloudProfile);

        debugPrint('✅ User data synced from cloud');
      }
    } catch (e, stackTrace) {
      ErrorService.logError(
        e,
        stackTrace: stackTrace,
        context: 'PersistentUserService._syncUserData',
        severity: ErrorSeverity.warning,
      );
    }
  }
}
