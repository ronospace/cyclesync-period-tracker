import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppBrandingService extends ChangeNotifier {
  static const String _appBrandingKey = 'app_branding';
  static const String _displayNameKey = 'display_name';
  static const String _compactViewKey = 'compact_view';
  
  String _selectedBranding = 'CycleSync'; // Default to CycleSync
  String _customDisplayName = '';
  bool _compactView = false;
  bool _isInitialized = false;
  
  // Getters
  String get selectedBranding => _selectedBranding;
  String get customDisplayName => _customDisplayName;
  bool get compactView => _compactView;
  bool get isInitialized => _isInitialized;
  
  // App display properties
  bool get isFlowSense => _selectedBranding == 'FlowSense';
  bool get isCycleSync => _selectedBranding == 'CycleSync';
  bool get isCustom => _selectedBranding == 'Custom';
  bool get hasAIFeatures => isFlowSense;
  
  String get appDisplayName {
    switch (_selectedBranding) {
      case 'FlowSense':
        return 'FlowSense AI';
      case 'CycleSync':
        return 'CycleSync';
      case 'Custom':
        return _customDisplayName.isNotEmpty ? _customDisplayName : 'Custom App';
      default:
        return 'CycleSync';
    }
  }
  
  String get appShortName {
    switch (_selectedBranding) {
      case 'FlowSense':
        return 'FlowSense';
      case 'CycleSync':
        return 'CycleSync';
      case 'Custom':
        return _customDisplayName.isNotEmpty ? _customDisplayName : 'Custom';
      default:
        return 'CycleSync';
    }
  }
  
  IconData get appIcon {
    switch (_selectedBranding) {
      case 'FlowSense':
        return Icons.psychology_alt_rounded;
      case 'CycleSync':
        return Icons.sync;
      case 'Custom':
        return Icons.star;
      default:
        return Icons.psychology_alt_rounded;
    }
  }
  
  LinearGradient get appGradient {
    switch (_selectedBranding) {
      case 'FlowSense':
        return LinearGradient(
          colors: [Colors.purple.shade400, Colors.pink.shade400],
        );
      case 'CycleSync':
        return LinearGradient(
          colors: [Colors.pink.shade400, Colors.red.shade400],
        );
      case 'Custom':
        return LinearGradient(
          colors: [Colors.blue.shade400, Colors.cyan.shade400],
        );
      default:
        return LinearGradient(
          colors: [Colors.purple.shade400, Colors.pink.shade400],
        );
    }
  }
  
  Color get primaryColor {
    switch (_selectedBranding) {
      case 'FlowSense':
        return Colors.purple.shade600;
      case 'CycleSync':
        return Colors.pink.shade600;
      case 'Custom':
        return Colors.blue.shade600;
      default:
        return Colors.purple.shade600;
    }
  }
  
  Color get secondaryColor {
    switch (_selectedBranding) {
      case 'FlowSense':
        return Colors.pink.shade400;
      case 'CycleSync':
        return Colors.red.shade400;
      case 'Custom':
        return Colors.cyan.shade400;
      default:
        return Colors.pink.shade400;
    }
  }
  
  /// Initialize the service
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _selectedBranding = prefs.getString(_appBrandingKey) ?? 'CycleSync';
      _customDisplayName = prefs.getString(_displayNameKey) ?? '';
      _compactView = prefs.getBool(_compactViewKey) ?? false;
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing app branding: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }
  
  /// Set the app branding
  Future<void> setBranding(String branding) async {
    if (_selectedBranding == branding) return;
    
    _selectedBranding = branding;
    await _saveSetting(_appBrandingKey, branding);
    notifyListeners();
  }
  
  /// Set custom display name
  Future<void> setCustomDisplayName(String name) async {
    if (_customDisplayName == name) return;
    
    _customDisplayName = name;
    await _saveSetting(_displayNameKey, name);
    
    // If setting custom name, also set branding to Custom
    if (name.isNotEmpty && _selectedBranding != 'Custom') {
      _selectedBranding = 'Custom';
      await _saveSetting(_appBrandingKey, 'Custom');
    }
    
    notifyListeners();
  }
  
  /// Set compact view
  Future<void> setCompactView(bool compact) async {
    if (_compactView == compact) return;
    
    _compactView = compact;
    await _saveSetting(_compactViewKey, compact);
    notifyListeners();
  }
  
  /// Reset to default (CycleSync)
  Future<void> resetToDefault() async {
    _selectedBranding = 'CycleSync';
    _customDisplayName = '';
    _compactView = false;
    
    await _saveSetting(_appBrandingKey, _selectedBranding);
    await _saveSetting(_displayNameKey, _customDisplayName);
    await _saveSetting(_compactViewKey, _compactView);
    
    notifyListeners();
  }
  
  /// Get branding-specific welcome message
  String getWelcomeMessage() {
    switch (_selectedBranding) {
      case 'FlowSense':
        return 'Welcome to FlowSense AI - Your intelligent menstrual health companion';
      case 'CycleSync':
        return 'Welcome to CycleSync - Simple, reliable cycle tracking';
      case 'Custom':
        return 'Welcome to $_customDisplayName - Your personal health tracker';
      default:
        return 'Welcome to CycleSync';
    }
  }
  
  /// Get app tagline
  String getTagline() {
    switch (_selectedBranding) {
      case 'FlowSense':
        return 'AI-Powered Menstrual Health Insights';
      case 'CycleSync':
        return 'Simple Cycle Tracking';
      case 'Custom':
        return 'Your Personal Health Companion';
      default:
        return 'Your Smart Clinical Period Tracker';
    }
  }
  
  /// Get feature descriptions based on branding
  List<String> getFeatureList() {
    final baseFeatures = [
      'Cycle logging and tracking',
      'Period and ovulation calendar',
      'Symptom tracking',
      'Health insights and analytics',
      'Data export and backup',
      'Privacy-focused design',
      'Multi-language support',
      'Dark mode support',
      'Cloud synchronization',
    ];
    
    if (hasAIFeatures) {
      return [
        ...baseFeatures,
        'AI-powered cycle predictions',
        'Smart symptom pattern analysis',
        'Personalized health insights',
        'Intelligent notifications',
        'Fertility window predictions',
        'Health recommendations',
        'Advanced analytics with ML',
      ];
    }
    
    return baseFeatures;
  }
  
  /// Get app-specific settings
  Map<String, dynamic> getAppSettings() {
    return {
      'branding': _selectedBranding,
      'displayName': appDisplayName,
      'shortName': appShortName,
      'hasAI': hasAIFeatures,
      'compactView': _compactView,
      'customName': _customDisplayName,
    };
  }
  
  /// Save setting to SharedPreferences
  Future<void> _saveSetting(String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (value is String) {
        await prefs.setString(key, value);
      } else if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is double) {
        await prefs.setDouble(key, value);
      }
    } catch (e) {
      debugPrint('Error saving app branding setting: $e');
    }
  }
  
  /// Get app metadata for about dialog
  Map<String, String> getAppMetadata() {
    return {
      'name': appDisplayName,
      'version': '1.0.0',
      'description': _getAppDescription(),
      'tagline': getTagline(),
    };
  }
  
  String _getAppDescription() {
    switch (_selectedBranding) {
      case 'FlowSense':
        return 'Advanced AI-powered menstrual health tracking app that provides intelligent insights, predictions, and personalized recommendations for your reproductive health journey.';
      case 'CycleSync':
        return 'A simple, reliable cycle tracking app focused on essential features for monitoring your menstrual cycle, symptoms, and reproductive health patterns.';
      case 'Custom':
        return 'A personalized health tracking app tailored to your preferences, providing essential cycle tracking features with your chosen branding.';
      default:
        return 'A modern menstrual health tracking app built with Flutter.';
    }
  }
  
  /// Check if current branding supports a specific feature
  bool supportsFeature(String feature) {
    switch (feature.toLowerCase()) {
      case 'ai_insights':
      case 'ai_predictions':
      case 'smart_notifications':
      case 'ml_analytics':
      case 'pattern_recognition':
        return hasAIFeatures;
      case 'basic_tracking':
      case 'symptom_logging':
      case 'calendar':
      case 'export':
      case 'themes':
      case 'languages':
        return true;
      default:
        return true; // Default to supported for unknown features
    }
  }
  
  /// Get branding-appropriate colors for charts and UI elements
  Map<String, Color> getBrandingColors() {
    return {
      'primary': primaryColor,
      'secondary': secondaryColor,
      'accent': _selectedBranding == 'FlowSense' 
          ? Colors.deepPurple.shade300 
          : _selectedBranding == 'CycleSync'
              ? Colors.pink.shade300
              : Colors.blue.shade300,
      'success': Colors.green.shade600,
      'warning': Colors.orange.shade600,
      'error': Colors.red.shade600,
      'info': Colors.blue.shade600,
    };
  }
  
  /// Create app logo widget based on branding
  Widget createAppLogo({double size = 40, bool showBadge = false}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: appGradient,
        borderRadius: BorderRadius.circular(size * 0.2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            appIcon,
            color: Colors.white,
            size: size * 0.5,
          ),
          if (showBadge && hasAIFeatures)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                width: size * 0.25,
                height: size * 0.25,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: primaryColor,
                  size: size * 0.15,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
