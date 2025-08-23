import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../models/user_profile.dart';
import '../services/persistent_user_service.dart';
import '../services/enhanced_auth_service.dart';
import '../services/avatar_service.dart';
import 'dart:typed_data';

class UserProvider extends ChangeNotifier {
  final PersistentUserService _persistentUserService = PersistentUserService();
  final EnhancedAuthService _authService = EnhancedAuthService();
  final AvatarService _avatarService = AvatarService();

  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _error;
  bool _initialized = false;

  // Getters
  UserProfile? get userProfile => _userProfile;
  String? get userId => _userProfile?.uid;
  String? get displayName => _userProfile?.displayName;
  String? get email => _userProfile?.email;
  String? get preferredName => _userProfile?.preferredName;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn =>
      _userProfile != null && FirebaseAuth.instance.currentUser != null;
  bool get isProfileComplete => _userProfile?.isProfileComplete ?? false;

  /// Initialize the UserProvider
  Future<void> initialize() async {
    if (_initialized) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Initialize services
      await _persistentUserService.initialize();
      await _authService.initialize();

      // Load existing user profile if available
      final profile = await _persistentUserService.getCurrentUserProfile();
      if (profile != null) {
        _userProfile = profile;
        debugPrint('✅ User profile loaded: ${profile.displayName}');
      }

      _initialized = true;
    } catch (e) {
      _error = 'Failed to initialize user data: $e';
      debugPrint('❌ UserProvider initialization failed: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Enhanced sign in with persistent storage
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Use enhanced auth service for sign in
      final authResult = await _authService.signIn(email, password);

      if (authResult.success && authResult.user != null) {
        // Record user activity
        await _persistentUserService.recordUserActivity();

        // Load or create user profile
        UserProfile? profile = await _persistentUserService
            .getCurrentUserProfile();

        if (profile == null) {
          // Create new profile from auth user
          profile = await _persistentUserService.createUserProfile(
            uid: authResult.user!.uid,
            email: authResult.user!.email ?? email,
            displayName: authResult.user!.displayName ?? email.split('@')[0],
            authProvider: authResult.provider?.name ?? 'email',
          );
        }

        if (profile != null) {
          _userProfile = profile;
          debugPrint('✅ User signed in: ${profile.displayName}');
          return true;
        }
      } else {
        _error = authResult.error ?? 'Sign in failed';
      }

      return false;
    } catch (e) {
      _error = 'Sign in failed: $e';
      debugPrint('❌ Sign in error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Enhanced sign up with persistent storage
  Future<bool> signUp(
    String email,
    String password,
    String displayName, {
    String? firstName,
    String? lastName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Create registration data
      final registrationData = UserRegistrationData(
        email: email,
        password: password,
        displayName: displayName,
        provider: AuthProvider.email,
        additionalData: {'firstName': firstName, 'lastName': lastName},
      );

      // Use enhanced auth service for registration
      final authResult = await _authService.registerUser(registrationData);

      if (authResult.success && authResult.user != null) {
        // Create comprehensive user profile
        final profile = await _persistentUserService.createUserProfile(
          uid: authResult.user!.uid,
          email: authResult.user!.email ?? email,
          displayName: displayName,
          firstName: firstName,
          lastName: lastName,
          authProvider: authResult.provider?.name ?? 'email',
        );

        if (profile != null) {
          _userProfile = profile;
          debugPrint('✅ User registered: ${profile.displayName}');
          return true;
        }
      } else {
        _error = authResult.error ?? 'Sign up failed';
      }

      return false;
    } catch (e) {
      _error = 'Sign up failed: $e';
      debugPrint('❌ Sign up error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign out with data cleanup
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Sign out from auth service
      await _authService.signOut();

      // Clear persistent data
      await _persistentUserService.clearUserData();

      // Clear local state
      _userProfile = null;
      _error = null;

      debugPrint('✅ User signed out');
    } catch (e) {
      _error = 'Sign out failed: $e';
      debugPrint('❌ Sign out error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user display name
  Future<bool> updateDisplayName(String displayName) async {
    try {
      final success = await _persistentUserService.updateDisplayName(
        displayName,
      );
      if (success) {
        // Reload profile to reflect changes
        final updatedProfile = await _persistentUserService
            .getCurrentUserProfile();
        if (updatedProfile != null) {
          _userProfile = updatedProfile;
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      _error = 'Failed to update display name: $e';
      notifyListeners();
      return false;
    }
  }

  /// Update user preferences
  Future<bool> updatePreferences(UserPreferences preferences) async {
    try {
      final success = await _persistentUserService.updateUserPreferences(
        preferences,
      );
      if (success) {
        // Reload profile to reflect changes
        final updatedProfile = await _persistentUserService
            .getCurrentUserProfile();
        if (updatedProfile != null) {
          _userProfile = updatedProfile;
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      _error = 'Failed to update preferences: $e';
      notifyListeners();
      return false;
    }
  }

  /// Update user profile with arbitrary data
  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    try {
      final updatedProfile = await _persistentUserService.updateUserProfile(
        updates,
      );
      if (updatedProfile != null) {
        _userProfile = updatedProfile;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to update profile: $e';
      notifyListeners();
      return false;
    }
  }

  /// Get user preference value
  T? getPreference<T>(String key, [T? defaultValue]) {
    if (_userProfile?.preferences == null) return defaultValue;

    final preferencesMap = _userProfile!.preferences.toMap();
    return preferencesMap[key] as T? ?? defaultValue;
  }

  /// Sync user data with cloud
  Future<void> syncUserData() async {
    try {
      await _persistentUserService.syncUserData();

      // Reload profile after sync
      final syncedProfile = await _persistentUserService
          .getCurrentUserProfile();
      if (syncedProfile != null) {
        _userProfile = syncedProfile;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to sync user data: $e';
      notifyListeners();
    }
  }

  /// Check if user needs onboarding
  bool get needsOnboarding => _userProfile?.needsOnboarding ?? true;

  /// Get user's preferred name for display
  String getGreetingName() {
    if (_userProfile == null) return 'User';
    return _userProfile!.preferredName;
  }

  /// Initialize test user for development
  Future<void> initializeTestUser([String displayName = 'Ronos']) async {
    try {
      final testProfile = UserProfile(
        uid: 'test_user_${DateTime.now().millisecondsSinceEpoch}',
        email: 'ronos@example.com',
        displayName: displayName,
        firstName: displayName.split(' ').first,
        createdAt: DateTime.now(),
        lastSignIn: DateTime.now(),
        authProvider: 'test',
        isEmailVerified: true,
        cycleData: const CycleTrackingData(),
        preferences: const UserPreferences(),
        socialProfile: const SocialProfile(),
        stats: UserStats(
          joinDate: DateTime.now(),
          lastActive: DateTime.now(),
          totalLogins: 1,
          hasCompletedOnboarding: true,
        ),
      );

      _userProfile = testProfile;
      await _persistentUserService.saveUserProfile(testProfile);
      notifyListeners();

      debugPrint('✅ Test user initialized: $displayName');
    } catch (e) {
      _error = 'Failed to initialize test user: $e';
      notifyListeners();
    }
  }

  // Avatar Management Methods

  /// Pick avatar from gallery
  Future<bool> pickAvatarFromGallery() async {
    if (_userProfile == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _avatarService.pickFromGallery();

      if (result.success && result.data != null) {
        // Upload avatar to cloud storage
        final photoURL = await _avatarService.uploadAvatar(
          result.data!,
          _userProfile!.uid,
        );

        if (photoURL != null) {
          // Update user profile with new photo URL
          final success = await updateProfile({'photoURL': photoURL});
          if (success) {
            debugPrint('✅ Avatar updated from gallery');
            return true;
          }
        }
      } else if (result.cancelled) {
        debugPrint('🚫 Avatar selection cancelled');
      } else {
        _error = result.error;
      }

      return false;
    } catch (e) {
      _error = 'Failed to update avatar: $e';
      debugPrint('❌ Avatar update error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Take photo with camera for avatar
  Future<bool> takeAvatarPhoto() async {
    if (_userProfile == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _avatarService.takePhoto();

      if (result.success && result.data != null) {
        // Upload avatar to cloud storage
        final photoURL = await _avatarService.uploadAvatar(
          result.data!,
          _userProfile!.uid,
        );

        if (photoURL != null) {
          // Update user profile with new photo URL
          final success = await updateProfile({'photoURL': photoURL});
          if (success) {
            debugPrint('✅ Avatar updated from camera');
            return true;
          }
        }
      } else if (result.cancelled) {
        debugPrint('🚫 Photo capture cancelled');
      } else {
        _error = result.error;
      }

      return false;
    } catch (e) {
      _error = 'Failed to update avatar: $e';
      debugPrint('❌ Avatar update error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get user avatar data
  Future<Uint8List?> getAvatarData() async {
    if (_userProfile?.photoURL == null) return null;

    try {
      return await _avatarService.getAvatar(
        _userProfile!.photoURL,
        _userProfile!.uid,
      );
    } catch (e) {
      debugPrint('❌ Failed to load avatar: $e');
      return null;
    }
  }

  /// Delete user avatar
  Future<bool> deleteAvatar() async {
    if (_userProfile?.photoURL == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // Delete from cloud storage
      final deleted = await _avatarService.deleteAvatar(
        _userProfile!.photoURL!,
        _userProfile!.uid,
      );

      if (deleted) {
        // Update profile to remove photo URL
        final success = await updateProfile({'photoURL': null});
        if (success) {
          debugPrint('✅ Avatar deleted successfully');
          return true;
        }
      }

      return false;
    } catch (e) {
      _error = 'Failed to delete avatar: $e';
      debugPrint('❌ Avatar deletion error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get user initials for default avatar
  String getUserInitials() {
    if (_userProfile == null) return 'U';

    final firstName = _userProfile!.firstName;
    final lastName = _userProfile!.lastName;
    final displayName = _userProfile!.displayName;

    if (firstName != null && lastName != null) {
      return '${firstName[0]}${lastName[0]}'.toUpperCase();
    }

    if (displayName.isNotEmpty) {
      final parts = displayName.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return displayName[0].toUpperCase();
    }

    return 'U';
  }

  /// Check if user has custom avatar
  bool get hasCustomAvatar => _userProfile?.photoURL != null;

  /// Get avatar cache size
  int getAvatarCacheSize() {
    return _avatarService.getCacheSize();
  }

  /// Clear avatar cache
  void clearAvatarCache() {
    _avatarService.clearCache();
  }
}
