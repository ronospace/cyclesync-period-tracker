import 'package:flutter/foundation.dart';

class UserProvider extends ChangeNotifier {
  String? _userId;
  Map<String, dynamic> _userProfile = {};
  bool _isLoading = false;
  String? _error;

  // Getters
  String? get userId => _userId;
  Map<String, dynamic> get userProfile => Map.unmodifiable(_userProfile);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _userId != null;

  // User authentication
  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate authentication delay
      await Future.delayed(const Duration(seconds: 1));
      
      // In a real app, this would authenticate with Firebase or another service
      _userId = 'test_user_${DateTime.now().millisecondsSinceEpoch}';
      _userProfile = {
        'email': email,
        'displayName': email.split('@')[0],
        'createdAt': DateTime.now().toIso8601String(),
        'preferences': {
          'theme': 'dark',
          'notifications': true,
          'analytics': true,
        },
      };
    } catch (e) {
      _error = 'Sign in failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp(String email, String password, String displayName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate authentication delay
      await Future.delayed(const Duration(seconds: 1));
      
      // In a real app, this would create a new user account
      _userId = 'new_user_${DateTime.now().millisecondsSinceEpoch}';
      _userProfile = {
        'email': email,
        'displayName': displayName,
        'createdAt': DateTime.now().toIso8601String(),
        'preferences': {
          'theme': 'dark',
          'notifications': true,
          'analytics': true,
        },
      };
    } catch (e) {
      _error = 'Sign up failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void signOut() {
    _userId = null;
    _userProfile.clear();
    _error = null;
    notifyListeners();
  }

  // Update user profile
  void updateProfile(Map<String, dynamic> updates) {
    _userProfile.addAll(updates);
    notifyListeners();
  }

  // Update user preferences
  void updatePreferences(Map<String, dynamic> preferences) {
    _userProfile['preferences'] = {
      ...(_userProfile['preferences'] as Map<String, dynamic>? ?? {}),
      ...preferences,
    };
    notifyListeners();
  }

  // Get user preference
  T? getPreference<T>(String key, [T? defaultValue]) {
    final preferences = _userProfile['preferences'] as Map<String, dynamic>?;
    return preferences?[key] as T? ?? defaultValue;
  }

  // Initialize user (for testing)
  void initializeTestUser() {
    _userId = 'test_user';
    _userProfile = {
      'email': 'test@example.com',
      'displayName': 'Test User',
      'createdAt': DateTime.now().toIso8601String(),
      'preferences': {
        'theme': 'dark',
        'notifications': true,
        'analytics': true,
      },
    };
    notifyListeners();
  }
}
