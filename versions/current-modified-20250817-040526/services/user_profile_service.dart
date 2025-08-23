import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Enterprise-grade Service for managing user profile data and onboarding status
class UserProfileService extends ChangeNotifier {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Check if current user has completed onboarding
  static Future<bool> hasCompletedOnboarding() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) return false;

      final data = userDoc.data() as Map<String, dynamic>;
      return data['onboardingCompleted'] == true;
    } catch (e) {
      debugPrint('Error checking onboarding status: $e');
      return false;
    }
  }

  /// Check if user has set their display name
  static Future<bool> hasDisplayName() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Check Firebase Auth profile first
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        return true;
      }

      // Check Firestore profile as backup
      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) return false;

      final data = userDoc.data() as Map<String, dynamic>;
      final displayName = data['displayName'] as String?;
      
      return displayName != null && displayName.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking display name: $e');
      return false;
    }
  }

  /// Get user's display name
  static Future<String?> getDisplayName() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      // Check Firebase Auth profile first
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        return user.displayName;
      }

      // Check Firestore profile as backup
      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) return null;

      final data = userDoc.data() as Map<String, dynamic>;
      return data['displayName'] as String?;
    } catch (e) {
      debugPrint('Error getting display name: $e');
      return null;
    }
  }

  /// Get user profile data
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        // Create basic profile if it doesn't exist
        await createUserProfile();
        return {
          'displayName': user.displayName,
          'email': user.email,
          'onboardingCompleted': false,
          'createdAt': DateTime.now().toIso8601String(),
        };
      }

      return userDoc.data() as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      return null;
    }
  }

  /// Create user profile in Firestore
  static Future<void> createUserProfile({String? displayName}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final profileData = {
        'displayName': displayName ?? user.displayName,
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'onboardingCompleted': false,
        'profileSetup': {
          'displayNameSet': displayName != null || user.displayName != null,
          'completedAt': displayName != null || user.displayName != null 
              ? FieldValue.serverTimestamp() 
              : null,
        },
        'preferences': {
          'notifications': true,
          'smartInsights': true,
          'communityFeatures': true,
          'dataSharing': false,
        },
        'stats': {
          'joinDate': FieldValue.serverTimestamp(),
          'totalLogins': 1,
          'lastActive': FieldValue.serverTimestamp(),
        },
      };

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(profileData, SetOptions(merge: true));

    } catch (e) {
      debugPrint('Error creating user profile: $e');
      rethrow;
    }
  }

  /// Update display name
  static Future<void> updateDisplayName(String displayName) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Update Firebase Auth profile
      await user.updateDisplayName(displayName);

      // Update Firestore profile
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set({
        'displayName': displayName,
        'profileSetup': {
          'displayNameSet': true,
          'completedAt': FieldValue.serverTimestamp(),
        },
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

    } catch (e) {
      debugPrint('Error updating display name: $e');
      rethrow;
    }
  }

  /// Mark onboarding as completed
  static Future<void> completeOnboarding() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set({
        'onboardingCompleted': true,
        'onboardingCompletedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

    } catch (e) {
      debugPrint('Error completing onboarding: $e');
      rethrow;
    }
  }

  /// Update user preferences
  static Future<void> updatePreferences(Map<String, dynamic> preferences) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set({
        'preferences': preferences,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

    } catch (e) {
      debugPrint('Error updating preferences: $e');
      rethrow;
    }
  }

  /// Record user activity
  static Future<void> recordActivity() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set({
        'stats': {
          'lastActive': FieldValue.serverTimestamp(),
          'totalLogins': FieldValue.increment(1),
        },
      }, SetOptions(merge: true));

    } catch (e) {
      debugPrint('Error recording activity: $e');
      // Don't rethrow as this is not critical
    }
  }

  /// Delete user profile
  static Future<void> deleteUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Delete Firestore profile
      await _firestore
          .collection('users')
          .doc(user.uid)
          .delete();

      // Delete Firebase Auth account
      await user.delete();

    } catch (e) {
      debugPrint('Error deleting user profile: $e');
      rethrow;
    }
  }

  /// Check if user needs onboarding
  static Future<bool> needsOnboarding() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final hasCompleted = await hasCompletedOnboarding();
      final hasName = await hasDisplayName();

      return !hasCompleted || !hasName;
    } catch (e) {
      debugPrint('Error checking onboarding needs: $e');
      return true; // Default to showing onboarding if unsure
    }
  }

  /// Initialize user profile after signup
  static Future<void> initializeNewUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Check if profile already exists
      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        // Profile exists, just record activity
        await recordActivity();
        return;
      }

      // Create new profile
      await createUserProfile();
      
    } catch (e) {
      debugPrint('Error initializing new user: $e');
      rethrow;
    }
  }
}

