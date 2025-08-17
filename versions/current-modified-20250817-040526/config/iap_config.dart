import 'package:flutter/foundation.dart';

class IAPConfig {
  // Environment detection
  static bool get isProduction => kReleaseMode;
  static bool get isDevelopment => kDebugMode;
  static bool get isStaging => kProfileMode;

  // Production Product IDs - Replace with your actual App Store Connect / Google Play Console IDs
  static const Map<String, String> _productionProductIds = {
    // Monthly subscription
    'monthly_premium': 'com.cyclesync.premium.monthly', // Replace with your actual product ID
    
    // Yearly subscription (typically 60-70% of monthly * 12 for better value)
    'yearly_premium': 'com.cyclesync.premium.yearly', // Replace with your actual product ID
    
    // Lifetime purchase (one-time payment)
    'lifetime_premium': 'com.cyclesync.premium.lifetime', // Replace with your actual product ID
    
    // Additional premium tiers (optional)
    'premium_plus_monthly': 'com.cyclesync.premiumplus.monthly',
    'premium_plus_yearly': 'com.cyclesync.premiumplus.yearly',
  };

  // Test Product IDs for development/testing
  static const Map<String, String> _testProductIds = {
    'monthly_premium': 'cyclesync_premium_monthly_test',
    'yearly_premium': 'cyclesync_premium_yearly_test',
    'lifetime_premium': 'cyclesync_premium_lifetime_test',
    'premium_plus_monthly': 'cyclesync_premiumplus_monthly_test',
    'premium_plus_yearly': 'cyclesync_premiumplus_yearly_test',
  };

  // Get product IDs based on environment
  static Map<String, String> getProductIds() {
    return isProduction ? _productionProductIds : _testProductIds;
  }

  // Individual product ID getters
  static String get monthlyPremiumId => getProductIds()['monthly_premium']!;
  static String get yearlyPremiumId => getProductIds()['yearly_premium']!;
  static String get lifetimePremiumId => getProductIds()['lifetime_premium']!;
  static String get premiumPlusMonthlyId => getProductIds()['premium_plus_monthly']!;
  static String get premiumPlusYearlyId => getProductIds()['premium_plus_yearly']!;

  // Product pricing configuration (for display purposes)
  static const Map<String, Map<String, dynamic>> productPricing = {
    'monthly_premium': {
      'displayPrice': '\$9.99',
      'pricePerMonth': 9.99,
      'description': 'Full premium features',
      'features': [
        'Ad-Free Experience',
        'Advanced Analytics',
        'AI Health Coach',
        'Data Export',
        'Custom Themes',
        'Priority Support'
      ],
    },
    'yearly_premium': {
      'displayPrice': '\$79.99',
      'pricePerMonth': 6.67, // 79.99 / 12
      'description': 'Best value - 33% savings',
      'savings': '33%',
      'features': [
        'All Monthly Premium features',
        '33% discount vs monthly',
        'Advanced AI Insights',
        'Cycle Prediction ML',
        'Health Reports',
      ],
    },
    'lifetime_premium': {
      'displayPrice': '\$199.99',
      'pricePerMonth': 0, // One-time payment
      'description': 'Pay once, own forever',
      'features': [
        'All Premium features forever',
        'Future updates included',
        'No recurring charges',
        'Exclusive lifetime benefits',
        'Priority feature requests',
      ],
    },
    'premium_plus_monthly': {
      'displayPrice': '\$14.99',
      'pricePerMonth': 14.99,
      'description': 'Ultimate health tracking',
      'features': [
        'All Premium features',
        'Personal health consultant',
        'Advanced AI predictions',
        'Wearable device sync',
        'Telehealth integration',
      ],
    },
    'premium_plus_yearly': {
      'displayPrice': '\$119.99',
      'pricePerMonth': 10.00, // 119.99 / 12
      'description': 'Ultimate plan - 33% savings',
      'savings': '33%',
      'features': [
        'All Premium Plus features',
        '33% discount vs monthly',
        'Exclusive health insights',
        'Priority medical consultations',
      ],
    },
  };

  // Subscription durations
  static const Map<String, String> subscriptionDurations = {
    'monthly_premium': 'P1M', // ISO 8601 duration format
    'yearly_premium': 'P1Y',
    'premium_plus_monthly': 'P1M',
    'premium_plus_yearly': 'P1Y',
    'lifetime_premium': 'LIFETIME',
  };

  // Feature access configuration
  static const Map<String, List<String>> productFeatures = {
    'basic': [
      'cycle_tracking',
      'basic_calendar',
      'simple_reminders',
    ],
    'monthly_premium': [
      'cycle_tracking',
      'advanced_analytics',
      'ai_insights',
      'data_export',
      'custom_themes',
      'ad_free',
      'priority_support',
      'advanced_calendar',
      'health_reports',
    ],
    'yearly_premium': [
      'cycle_tracking',
      'advanced_analytics',
      'ai_insights',
      'data_export',
      'custom_themes',
      'ad_free',
      'priority_support',
      'advanced_calendar',
      'health_reports',
      'cycle_prediction_ml',
      'symptom_pattern_analysis',
    ],
    'lifetime_premium': [
      'cycle_tracking',
      'advanced_analytics',
      'ai_insights',
      'data_export',
      'custom_themes',
      'ad_free',
      'priority_support',
      'advanced_calendar',
      'health_reports',
      'cycle_prediction_ml',
      'symptom_pattern_analysis',
      'future_features',
    ],
    'premium_plus_monthly': [
      'cycle_tracking',
      'advanced_analytics',
      'ai_insights',
      'data_export',
      'custom_themes',
      'ad_free',
      'priority_support',
      'advanced_calendar',
      'health_reports',
      'cycle_prediction_ml',
      'symptom_pattern_analysis',
      'personal_health_consultant',
      'wearable_sync',
      'telehealth_integration',
    ],
    'premium_plus_yearly': [
      'cycle_tracking',
      'advanced_analytics',
      'ai_insights',
      'data_export',
      'custom_themes',
      'ad_free',
      'priority_support',
      'advanced_calendar',
      'health_reports',
      'cycle_prediction_ml',
      'symptom_pattern_analysis',
      'personal_health_consultant',
      'wearable_sync',
      'telehealth_integration',
      'priority_medical_consultations',
    ],
  };

  // A/B testing configurations
  static const Map<String, Map<String, dynamic>> abTestConfigurations = {
    'pricing_test_a': {
      'monthly_premium': 9.99,
      'yearly_premium': 79.99,
      'lifetime_premium': 199.99,
    },
    'pricing_test_b': {
      'monthly_premium': 12.99,
      'yearly_premium': 99.99,
      'lifetime_premium': 249.99,
    },
    'pricing_test_c': {
      'monthly_premium': 7.99,
      'yearly_premium': 59.99,
      'lifetime_premium': 149.99,
    },
  };

  // Validate product IDs
  static bool validateProductIds() {
    try {
      final productIds = getProductIds();
      
      if (isProduction) {
        // Check if production IDs follow proper format
        for (final entry in productIds.entries) {
          if (!entry.value.contains('com.cyclesync.') || entry.value.contains('test')) {
            debugPrint('⚠️ IAP Warning: Production product ID "${entry.key}" may not be properly configured');
            return false;
          }
        }
      }

      debugPrint('✅ IAP: All product IDs validated successfully');
      debugPrint('🎯 Environment: ${isProduction ? "Production" : isDevelopment ? "Development" : "Staging"}');
      debugPrint('💎 Products available: ${productIds.length}');
      
      return true;
    } catch (e) {
      debugPrint('❌ IAP: Product ID validation failed: $e');
      return false;
    }
  }

  // Get product features for a given subscription
  static List<String> getFeaturesForProduct(String productId) {
    return productFeatures[productId] ?? productFeatures['basic']!;
  }

  // Check if user has access to a specific feature
  static bool hasFeatureAccess(List<String> userFeatures, String feature) {
    return userFeatures.contains(feature);
  }

  // Get pricing info for a product
  static Map<String, dynamic>? getPricingInfo(String productId) {
    return productPricing[productId];
  }

  // Get all available subscription options
  static List<String> getAvailableSubscriptions() {
    return getProductIds().keys.toList();
  }

  // Get recommended subscription (for marketing)
  static String getRecommendedSubscription() {
    return 'yearly_premium'; // Best value proposition
  }

  // Get trial configuration
  static Map<String, dynamic> getTrialConfiguration() {
    return {
      'trialPeriodDays': 7,
      'trialProductId': monthlyPremiumId,
      'autoRenew': true,
      'trialFeatures': productFeatures['monthly_premium'],
    };
  }
}
