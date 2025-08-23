import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';
import 'persistent_user_service.dart';
import 'user_profile_service.dart';
import 'error_service.dart';

/// Comprehensive user service that combines persistent storage and profile management
/// This service acts as a facade for all user-related operations
class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  static UserService get instance => _instance;
  UserService._internal();

  final PersistentUserService _persistentService = PersistentUserService();
  bool _initialized = false;

  /// Initialize the user service
  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      await _persistentService.initialize();
      _initialized = true;
      debugPrint('✅ UserService initialized');
    } catch (e, stackTrace) {
      ErrorService.logError(
        e,
        stackTrace: stackTrace,
        context: 'UserService.initialize',
        severity: ErrorSeverity.error,
      );
    }
  }

  /// Get current user profile
  Future<UserProfile?> getCurrentUserProfile() async {
    await initialize();
    return await _persistentService.getCurrentUserProfile();
  }

  /// Save user profile
  Future<void> saveUserProfile(UserProfile profile) async {
    await initialize();
    await _persistentService.saveUserProfile(profile);
  }

  /// Update user profile
  Future<UserProfile?> updateUserProfile(Map<String, dynamic> updates) async {
    await initialize();
    return await _persistentService.updateUserProfile(updates);
  }

  /// Create user profile
  Future<UserProfile?> createUserProfile({
    required String uid,
    required String email,
    required String displayName,
    String? firstName,
    String? lastName,
    String? authProvider,
  }) async {
    await initialize();
    return await _persistentService.createUserProfile(
      uid: uid,
      email: email,
      displayName: displayName,
      firstName: firstName,
      lastName: lastName,
      authProvider: authProvider ?? 'email',
    );
  }

  /// Get user display name
  Future<String?> getDisplayName() async {
    await initialize();
    return await _persistentService.getDisplayName();
  }

  /// Update display name
  Future<bool> updateDisplayName(String displayName) async {
    await initialize();
    return await _persistentService.updateDisplayName(displayName);
  }

  /// Check if user has completed onboarding
  Future<bool> hasCompletedOnboarding() async {
    await initialize();
    return await UserProfileService.hasCompletedOnboarding();
  }

  /// Complete onboarding
  Future<void> completeOnboarding() async {
    await initialize();
    await UserProfileService.completeOnboarding();
  }

  /// Check if user has display name
  Future<bool> hasDisplayName() async {
    await initialize();
    return await UserProfileService.hasDisplayName();
  }

  /// Clear user data (for logout)
  Future<void> clearUserData() async {
    await initialize();
    await _persistentService.clearUserData();
  }

  /// Record user activity
  Future<void> recordUserActivity() async {
    await initialize();
    await _persistentService.recordUserActivity();
  }

  /// Get user preferences
  Future<Map<String, dynamic>?> getUserPreferences() async {
    await initialize();
    final profile = await getCurrentUserProfile();
    return profile?.preferences.toMap();
  }

  /// Update user preferences
  Future<void> updatePreferences(Map<String, dynamic> preferences) async {
    await initialize();
    await UserProfileService.updatePreferences(preferences);
    
    // Also update in persistent storage
    await updateUserProfile({'preferences': preferences});
  }

  /// Get current user ID
  String? getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  /// Get current user email
  String? getCurrentUserEmail() {
    return FirebaseAuth.instance.currentUser?.email;
  }

  /// Check if user is authenticated
  bool get isAuthenticated {
    return FirebaseAuth.instance.currentUser != null;
  }

  /// Get Firebase Auth user
  User? get currentFirebaseUser {
    return FirebaseAuth.instance.currentUser;
  }

  /// Alias for currentFirebaseUser for compatibility
  User? get currentUser {
    return FirebaseAuth.instance.currentUser;
  }
}
