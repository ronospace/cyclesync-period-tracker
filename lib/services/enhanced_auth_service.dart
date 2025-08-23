import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'biometric_auth_service.dart';
import 'retry_service.dart';
import 'cache_service.dart';

/// Authentication provider types
enum AuthProvider { email, google, apple, biometric }

/// User registration data
class UserRegistrationData {
  final String email;
  final String password;
  final String displayName;
  final String? username;
  final AuthProvider provider;
  final Map<String, dynamic>? additionalData;

  const UserRegistrationData({
    required this.email,
    required this.password,
    required this.displayName,
    this.username,
    this.provider = AuthProvider.email,
    this.additionalData,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'password': password, // Never stored in plain text
      'displayName': displayName,
      'username': username,
      'provider': provider.name,
      'additionalData': additionalData,
    };
  }
}

/// Authentication result with enhanced information
class AuthResult {
  final bool success;
  final User? user;
  final String? error;
  final AuthProvider? provider;
  final Map<String, dynamic>? additionalInfo;

  const AuthResult({
    required this.success,
    this.user,
    this.error,
    this.provider,
    this.additionalInfo,
  });

  factory AuthResult.success(
    User user,
    AuthProvider provider, [
    Map<String, dynamic>? info,
  ]) {
    return AuthResult(
      success: true,
      user: user,
      provider: provider,
      additionalInfo: info,
    );
  }

  factory AuthResult.failure(String error, [AuthProvider? provider]) {
    return AuthResult(success: false, error: error, provider: provider);
  }
}

/// Enhanced Authentication Service with multiple providers and biometric support
class EnhancedAuthService {
  static final EnhancedAuthService _instance = EnhancedAuthService._internal();
  factory EnhancedAuthService() => _instance;
  EnhancedAuthService._internal();

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // GoogleSignIn instance (singleton in v7.x+)
  static GoogleSignIn get _googleSignIn => GoogleSignIn.instance;

  final BiometricAuthService _biometricService = BiometricAuthService.instance;
  SharedPreferences? _prefs;
  bool _biometricEnabled = false;
  bool _initialized = false;

  // Cache keys
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _storedEmailKey = 'stored_email_for_biometric';
  static const String _authProviderKey = 'last_auth_provider';

  /// Initialize the service
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      _biometricEnabled = _prefs?.getBool(_biometricEnabledKey) ?? false;

      // Load user preferences if signed in
      if (currentUser != null) {
        await _loadUserPreferences();
      }

      _initialized = true;
      debugPrint('✅ EnhancedAuthService initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize EnhancedAuthService: $e');
    }
  }

  /// Current user getter
  User? get currentUser => _auth.currentUser;

  /// User ID getter
  String? get userId => _auth.currentUser?.uid;

  /// Check if biometric is available and enabled
  Future<bool> get isBiometricEnabled async {
    if (!await _biometricService.isBiometricAvailable()) return false;
    return _biometricEnabled;
  }

  /// Get supported authentication methods
  Future<List<AuthProvider>> getSupportedAuthMethods() async {
    final methods = [AuthProvider.email];

    // Check Google Sign-In availability
    try {
      methods.add(AuthProvider.google);
    } catch (e) {
      debugPrint('Google Sign-In not available: $e');
    }

    // Check Apple Sign-In availability (iOS only)
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      if (await SignInWithApple.isAvailable()) {
        methods.add(AuthProvider.apple);
      }
    }

    // Check biometric availability
    if (await _biometricService.isBiometricAvailable()) {
      methods.add(AuthProvider.biometric);
    }

    return methods;
  }

  /// Enhanced user registration with multiple providers
  Future<AuthResult> registerUser(UserRegistrationData data) async {
    if (!_initialized) await initialize();

    try {
      UserCredential? result;

      switch (data.provider) {
        case AuthProvider.email:
          result = await _registerWithEmail(data);
          break;
        case AuthProvider.google:
          result = await _registerWithGoogle(data);
          break;
        case AuthProvider.apple:
          result = await _registerWithApple(data);
          break;
        case AuthProvider.biometric:
          return AuthResult.failure(
            'Cannot register with biometric authentication',
          );
      }

      if (result?.user != null) {
        // Create enhanced user profile
        await _createEnhancedUserProfile(result!.user!, data);

        // Initialize biometric if requested
        if (data.additionalData?['enableBiometric'] == true) {
          await enableBiometricAuth();
        }

        // Cache authentication info
        await _cacheAuthInfo(data.provider);

        return AuthResult.success(result.user!, data.provider);
      }

      return AuthResult.failure('Registration failed');
    } catch (e) {
      debugPrint('User registration error: $e');
      return AuthResult.failure(e.toString(), data.provider);
    }
  }

  /// Enhanced sign in with multiple authentication methods
  Future<AuthResult> signIn(
    String email,
    String password, {
    bool tryBiometric = false,
  }) async {
    if (!_initialized) await initialize();

    try {
      // Try biometric first if enabled and requested
      if (tryBiometric && _biometricEnabled) {
        final biometricResult = await signInWithBiometric();
        if (biometricResult.success) {
          return biometricResult;
        }
      }

      final result = await RetryService().execute(
        'email_sign_in',
        () =>
            _auth.signInWithEmailAndPassword(email: email, password: password),
      );

      if (result.user != null) {
        await _updateLastSignIn(result.user!);
        await _cacheAuthInfo(AuthProvider.email);
        return AuthResult.success(result.user!, AuthProvider.email);
      }

      return AuthResult.failure('Sign in failed');
    } catch (e) {
      debugPrint('Sign in error: $e');
      return AuthResult.failure(e.toString(), AuthProvider.email);
    }
  }

  /// Sign in with Google
  Future<AuthResult> signInWithGoogle() async {
    if (!_initialized) await initialize();

    try {
      // Initialize if needed
      await _googleSignIn.initialize();
      
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate(
        scopeHint: ['email', 'profile'],
      );

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        // Note: GoogleSignIn 7.x+ authentication doesn't provide accessToken
        // For Firebase Auth, idToken is usually sufficient
      );

      final UserCredential result = await _auth.signInWithCredential(
        credential,
      );

      if (result.user != null) {
        // Create or update user profile
        await _createOrUpdateGoogleUserProfile(result.user!, googleUser);
        await _cacheAuthInfo(AuthProvider.google);

        return AuthResult.success(result.user!, AuthProvider.google, {
          'googleUser': googleUser,
          'isNewUser': result.additionalUserInfo?.isNewUser ?? false,
        });
      }

      return AuthResult.failure('Google authentication failed');
    } catch (e) {
      debugPrint('Google sign in error: $e');
      return AuthResult.failure(e.toString(), AuthProvider.google);
    }
  }

  /// Sign in with Apple ID
  Future<AuthResult> signInWithApple() async {
    if (!_initialized) await initialize();

    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: 'com.cyclesync.app', // Replace with your client ID
          redirectUri: Uri.parse('https://cyclesync.app/auth/callback'),
        ),
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final UserCredential result = await _auth.signInWithCredential(
        oauthCredential,
      );

      if (result.user != null) {
        // Create or update user profile
        await _createOrUpdateAppleUserProfile(result.user!, appleCredential);
        await _cacheAuthInfo(AuthProvider.apple);

        return AuthResult.success(result.user!, AuthProvider.apple, {
          'appleCredential': appleCredential,
          'isNewUser': result.additionalUserInfo?.isNewUser ?? false,
        });
      }

      return AuthResult.failure('Apple authentication failed');
    } catch (e) {
      debugPrint('Apple sign in error: $e');
      return AuthResult.failure(e.toString(), AuthProvider.apple);
    }
  }

  /// Sign in with biometric authentication
  Future<AuthResult> signInWithBiometric() async {
    if (!_biometricEnabled) {
      return AuthResult.failure('Biometric authentication not enabled');
    }

    try {
      final success = await _biometricService.authenticateWithBiometric();
      if (success) {
        final storedEmail = await _getStoredEmail();
        if (storedEmail != null && currentUser?.email == storedEmail) {
          // User is already signed in, just verified biometric
          await _updateLastSignIn(currentUser!);
          return AuthResult.success(currentUser!, AuthProvider.biometric);
        } else if (storedEmail != null) {
          // Try to sign in with stored credentials (would need secure storage for this)
          return AuthResult.failure(
            'Biometric verification successful but re-authentication required',
          );
        }
      }
      return AuthResult.failure('Biometric authentication failed');
    } catch (e) {
      debugPrint('Biometric sign in error: $e');
      return AuthResult.failure(e.toString(), AuthProvider.biometric);
    }
  }

  /// Check if username is unique
  Future<bool> isUsernameAvailable(String username) async {
    if (username.isEmpty || username.length < 3) return false;

    try {
      final doc = await _firestore
          .collection('usernames')
          .doc(username.toLowerCase())
          .get();
      return !doc.exists;
    } catch (e) {
      debugPrint('Error checking username availability: $e');
      return false;
    }
  }

  /// Update user username
  Future<bool> updateUsername(String newUsername) async {
    if (userId == null) return false;

    try {
      final isAvailable = await isUsernameAvailable(newUsername);
      if (!isAvailable) return false;

      // Get current username
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final currentUsername = userDoc.data()?['username'];

      // Update username in user document
      await _firestore.collection('users').doc(userId).update({
        'username': newUsername,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update username mapping
      await _firestore
          .collection('usernames')
          .doc(newUsername.toLowerCase())
          .set({'uid': userId, 'createdAt': FieldValue.serverTimestamp()});

      // Remove old username mapping if exists
      if (currentUsername != null) {
        await _firestore
            .collection('usernames')
            .doc(currentUsername.toLowerCase())
            .delete();
      }

      return true;
    } catch (e) {
      debugPrint('Error updating username: $e');
      return false;
    }
  }

  /// Setup biometric authentication
  Future<bool> enableBiometricAuth() async {
    try {
      final isAvailable = await _biometricService.isBiometricAvailable();
      if (!isAvailable) return false;

      final success = await _biometricService.enableBiometricAuth();
      if (success) {
        _biometricEnabled = true;
        await _prefs?.setBool(_biometricEnabledKey, true);

        // Store email for biometric login
        final user = currentUser;
        if (user?.email != null) {
          await _storeEmailForBiometric(user!.email!);
        }

        // Update user preferences
        if (userId != null) {
          await _firestore.collection('users').doc(userId).update({
            'preferences.biometricAuth': true,
            'biometricEnabled': true,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      return success;
    } catch (e) {
      debugPrint('Error setting up biometric auth: $e');
      return false;
    }
  }

  /// Disable biometric authentication
  Future<bool> disableBiometricAuth() async {
    try {
      await _biometricService.disableBiometricAuth();
      _biometricEnabled = false;
      await _prefs?.setBool(_biometricEnabledKey, false);
      await _prefs?.remove(_storedEmailKey);

      // Update user preferences
      if (userId != null) {
        await _firestore.collection('users').doc(userId).update({
          'preferences.biometricAuth': false,
          'biometricEnabled': false,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      return true;
    } catch (e) {
      debugPrint('Error disabling biometric auth: $e');
      return false;
    }
  }

  /// Verify email
  Future<bool> sendEmailVerification() async {
    try {
      final user = currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Email verification error: $e');
      return false;
    }
  }

  /// Reset password
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      debugPrint('Password reset error: $e');
      return false;
    }
  }

  /// Update password
  Future<bool> updatePassword(String newPassword) async {
    try {
      final user = currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Password update error: $e');
      return false;
    }
  }

  /// Update display name
  Future<bool> updateDisplayName(String displayName) async {
    try {
      final user = currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);

        // Update in Firestore
        await _firestore.collection('users').doc(user.uid).update({
          'displayName': displayName,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Display name update error: $e');
      return false;
    }
  }

  /// Enhanced sign out with cleanup
  Future<void> signOut() async {
    try {
      // Sign out from Google
      await _googleSignIn.signOut();

      // Clear biometric data if needed (but keep enabled status)
      // await _biometricService.clearBiometricData();

      // Clear cached auth info
      await _clearAuthCache();

      // Sign out from Firebase
      await _auth.signOut();

      debugPrint('User signed out successfully');
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }

  /// Delete user account with comprehensive cleanup
  Future<bool> deleteAccount() async {
    try {
      final user = currentUser;
      if (user == null) return false;

      // Get user data first
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data();
      final username = userData?['username'];

      // Delete related data
      await _deleteUserRelatedData(user.uid);

      // Delete username mapping if exists
      if (username != null) {
        await _firestore
            .collection('usernames')
            .doc(username.toLowerCase())
            .delete();
      }

      // Delete user profile
      await _firestore.collection('users').doc(user.uid).delete();

      // Clear biometric data
      await _biometricService.clearBiometricData();
      await disableBiometricAuth();

      // Sign out from third-party providers
      await _googleSignIn.disconnect();

      // Clear all cached data
      await _clearAuthCache();
      await CacheService().removePattern('user:${user.uid}:.*');

      // Delete Firebase Auth account
      await user.delete();

      debugPrint('User account deleted successfully');
      return true;
    } catch (e) {
      debugPrint('Delete account error: $e');
      return false;
    }
  }

  /// Get user profile data
  Future<Map<String, dynamic>?> getUserProfile([String? uid]) async {
    try {
      final targetUid = uid ?? userId;
      if (targetUid == null) return null;

      final cacheKey = 'user_profile:$targetUid';
      final cached = await CacheService().get<Map<String, dynamic>>(cacheKey);
      if (cached != null) return cached;

      final doc = await _firestore.collection('users').doc(targetUid).get();
      final data = doc.data();

      if (data != null) {
        await CacheService().set(
          cacheKey,
          data,
          policy: CacheExpiryPolicy.hourly,
        );
      }

      return data;
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      return null;
    }
  }

  // Private helper methods

  Future<UserCredential> _registerWithEmail(UserRegistrationData data) async {
    return await _auth.createUserWithEmailAndPassword(
      email: data.email,
      password: data.password,
    );
  }

  Future<UserCredential> _registerWithGoogle(UserRegistrationData data) async {
    // For Google registration, we use the sign-in flow
    // Initialize if needed
    await _googleSignIn.initialize();
    
    final GoogleSignInAccount googleUser = await _googleSignIn.authenticate(
      scopeHint: ['email', 'profile'],
    );

    final GoogleSignInAuthentication googleAuth = googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      // Note: GoogleSignIn 7.x+ authentication doesn't provide accessToken
    );

    return await _auth.signInWithCredential(credential);
  }

  Future<UserCredential> _registerWithApple(UserRegistrationData data) async {
    // For Apple registration, we use the sign-in flow
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      webAuthenticationOptions: WebAuthenticationOptions(
        clientId: 'com.cyclesync.app', // Replace with your client ID
        redirectUri: Uri.parse('https://cyclesync.app/auth/callback'),
      ),
    );

    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    return await _auth.signInWithCredential(oauthCredential);
  }

  Future<void> _createEnhancedUserProfile(
    User user,
    UserRegistrationData data,
  ) async {
    try {
      // Check if username is unique
      if (data.username != null) {
        final isUnique = await isUsernameAvailable(data.username!);
        if (!isUnique) {
          throw Exception('Username "${data.username}" is already taken');
        }
      }

      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': data.displayName,
        'username': data.username?.toLowerCase(),
        'photoURL': user.photoURL,
        'authProvider': data.provider.name,
        'createdAt': FieldValue.serverTimestamp(),
        'lastSignIn': FieldValue.serverTimestamp(),
        'isEmailVerified': user.emailVerified,
        'biometricEnabled': data.additionalData?['enableBiometric'] ?? false,
        'cycleData': {
          'averageCycleLength': 28,
          'averagePeriodLength': 5,
          'trackingStartDate': null,
          'lastPeriodDate': null,
        },
        'preferences': {
          'notifications': true,
          'reminders': true,
          'dataSharing': false,
          'language': 'en',
          'theme': 'system',
          'biometricAuth': data.additionalData?['enableBiometric'] ?? false,
        },
        'socialProfile': {'isPublic': false, 'allowPartnerInvitations': true},
        'additionalData': data.additionalData ?? {},
      });

      // Create username mapping if provided
      if (data.username != null) {
        await _firestore
            .collection('usernames')
            .doc(data.username!.toLowerCase())
            .set({'uid': user.uid, 'createdAt': FieldValue.serverTimestamp()});
      }

      debugPrint('Enhanced user profile created for ${user.uid}');
    } catch (e) {
      debugPrint('Error creating enhanced user profile: $e');
      rethrow;
    }
  }

  Future<void> _createOrUpdateGoogleUserProfile(
    User user,
    GoogleSignInAccount googleUser,
  ) async {
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        // Update existing profile
        await _firestore.collection('users').doc(user.uid).update({
          'lastSignIn': FieldValue.serverTimestamp(),
          'displayName': user.displayName ?? googleUser.displayName,
          'photoURL': user.photoURL,
          'isEmailVerified': user.emailVerified,
        });
      } else {
        // Create new profile
        final data = UserRegistrationData(
          email: user.email ?? googleUser.email,
          password: '', // Not needed for Google
          displayName: user.displayName ?? googleUser.displayName ?? 'User',
          provider: AuthProvider.google,
        );
        await _createEnhancedUserProfile(user, data);
      }
    } catch (e) {
      debugPrint('Error creating/updating Google user profile: $e');
    }
  }

  Future<void> _createOrUpdateAppleUserProfile(
    User user,
    AuthorizationCredentialAppleID appleCredential,
  ) async {
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();

      String displayName = user.displayName ?? 'User';
      if (appleCredential.givenName != null &&
          appleCredential.familyName != null) {
        displayName =
            '${appleCredential.givenName} ${appleCredential.familyName}';
      }

      if (doc.exists) {
        // Update existing profile
        await _firestore.collection('users').doc(user.uid).update({
          'lastSignIn': FieldValue.serverTimestamp(),
          'displayName': displayName,
          'isEmailVerified': user.emailVerified,
        });
      } else {
        // Create new profile
        final data = UserRegistrationData(
          email: user.email ?? '',
          password: '', // Not needed for Apple
          displayName: displayName,
          provider: AuthProvider.apple,
        );
        await _createEnhancedUserProfile(user, data);
      }
    } catch (e) {
      debugPrint('Error creating/updating Apple user profile: $e');
    }
  }

  Future<void> _updateLastSignIn(User user) async {
    try {
      await _firestore.collection('users').doc(user.uid).update({
        'lastSignIn': FieldValue.serverTimestamp(),
      });

      // Invalidate user profile cache
      await CacheService().remove('user_profile:${user.uid}');
    } catch (e) {
      debugPrint('Error updating last sign in: $e');
    }
  }

  Future<void> _loadUserPreferences() async {
    try {
      final profile = await getUserProfile();
      if (profile != null) {
        _biometricEnabled = profile['biometricEnabled'] ?? false;
      }
    } catch (e) {
      debugPrint('Error loading user preferences: $e');
    }
  }

  Future<void> _storeEmailForBiometric(String email) async {
    await _prefs?.setString(_storedEmailKey, email);
  }

  Future<String?> _getStoredEmail() async {
    return _prefs?.getString(_storedEmailKey);
  }

  Future<void> _cacheAuthInfo(AuthProvider provider) async {
    await _prefs?.setString(_authProviderKey, provider.name);
  }

  Future<void> _clearAuthCache() async {
    await _prefs?.remove(_authProviderKey);
    await _prefs?.remove(_storedEmailKey);
  }

  Future<void> _deleteUserRelatedData(String uid) async {
    try {
      // Delete user's cycles
      final cyclesQuery = await _firestore
          .collection('cycles')
          .where('userId', isEqualTo: uid)
          .get();

      for (final doc in cyclesQuery.docs) {
        await doc.reference.delete();
      }

      // Delete partner relationships
      final partnershipsQuery = await _firestore
          .collection('partnerships')
          .where('userId', isEqualTo: uid)
          .get();

      for (final doc in partnershipsQuery.docs) {
        await doc.reference.delete();
      }

      // Delete community memberships
      final membershipsQuery = await _firestore
          .collection('memberships')
          .where('userId', isEqualTo: uid)
          .get();

      for (final doc in membershipsQuery.docs) {
        await doc.reference.delete();
      }

      // Delete other user-related collections as needed
      debugPrint('User related data deleted for $uid');
    } catch (e) {
      debugPrint('Error deleting user related data: $e');
    }
  }
}

/// Extension for easier access to enhanced auth
extension EnhancedAuthExtension on User {
  /// Get the user's custom username
  Future<String?> getUsername() async {
    try {
      final profile = await EnhancedAuthService().getUserProfile(uid);
      return profile?['username'];
    } catch (e) {
      return null;
    }
  }

  /// Check if user has biometric enabled
  Future<bool> hasBiometricEnabled() async {
    try {
      final profile = await EnhancedAuthService().getUserProfile(uid);
      return profile?['biometricEnabled'] ?? false;
    } catch (e) {
      return false;
    }
  }
}
