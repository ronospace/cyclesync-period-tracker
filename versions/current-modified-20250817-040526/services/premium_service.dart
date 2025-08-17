import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumService extends ChangeNotifier {
  static final PremiumService _instance = PremiumService._internal();
  factory PremiumService() => _instance;
  PremiumService._internal();

  // Product IDs - These should match your App Store Connect / Google Play Console
  static const String monthlyPremiumId = 'cyclesync_premium_monthly';
  static const String yearlyPremiumId = 'cyclesync_premium_yearly';
  static const String lifetimePremiumId = 'cyclesync_premium_lifetime';

  // Premium features flags
  bool _isPremium = false;
  bool _hasAdvancedAnalytics = false;
  bool _hasAIInsights = false;
  bool _hasExportFeatures = false;
  bool _hasCustomizationFeatures = false;
  bool _hasAdFreeExperience = false;

  // In-app purchase objects
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  bool _purchasePending = false;

  // Getters
  bool get isPremium => _isPremium;
  bool get hasAdvancedAnalytics => _hasAdvancedAnalytics;
  bool get hasAIInsights => _hasAIInsights;
  bool get hasExportFeatures => _hasExportFeatures;
  bool get hasCustomizationFeatures => _hasCustomizationFeatures;
  bool get hasAdFreeExperience => _hasAdFreeExperience;
  bool get isAvailable => _isAvailable;
  bool get purchasePending => _purchasePending;
  List<ProductDetails> get products => _products;

  /// Initialize premium service
  Future<void> initialize() async {
    _isAvailable = await _inAppPurchase.isAvailable();
    
    if (_isAvailable) {
      await _loadProducts();
      await _loadPurchases();
      _listenToPurchaseUpdated();
    }
    
    await _loadPremiumStatus();
    debugPrint('💎 Premium service initialized - Premium: $_isPremium');
  }

  /// Load available products
  Future<void> _loadProducts() async {
    const Set<String> identifiers = {
      monthlyPremiumId,
      yearlyPremiumId,
      lifetimePremiumId,
    };

    final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(identifiers);
    
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('💎 Products not found: ${response.notFoundIDs}');
    }
    
    _products = response.productDetails;
    debugPrint('💎 Loaded ${_products.length} products');
  }

  /// Load existing purchases
  Future<void> _loadPurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
      debugPrint('💎 Purchases restoration completed');
    } catch (e) {
      debugPrint('💎 Failed to load existing purchases: $e');
    }
  }

  /// Listen to purchase updates
  void _listenToPurchaseUpdated() {
    _subscription = _inAppPurchase.purchaseStream.listen(
      (List<PurchaseDetails> purchaseDetailsList) {
        _handlePurchaseUpdates(purchaseDetailsList);
      },
      onDone: () {
        _subscription.cancel();
      },
      onError: (error) {
        debugPrint('💎 Purchase stream error: $error');
      },
    );
  }

  /// Handle purchase updates
  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) async {
    for (PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        _purchasePending = true;
        notifyListeners();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          debugPrint('💎 Purchase error: ${purchaseDetails.error}');
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                   purchaseDetails.status == PurchaseStatus.restored) {
          await _handlePurchase(purchaseDetails);
        }
        
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
        
        _purchasePending = false;
        notifyListeners();
      }
    }
  }

  /// Handle successful purchase
  Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.productID == monthlyPremiumId ||
        purchaseDetails.productID == yearlyPremiumId ||
        purchaseDetails.productID == lifetimePremiumId) {
      
      await _upgradeToPremium();
      debugPrint('💎 Premium purchase confirmed: ${purchaseDetails.productID}');
    }
  }

  /// Upgrade to premium
  Future<void> _upgradeToPremium() async {
    _isPremium = true;
    _hasAdvancedAnalytics = true;
    _hasAIInsights = true;
    _hasExportFeatures = true;
    _hasCustomizationFeatures = true;
    _hasAdFreeExperience = true;
    
    await _savePremiumStatus();
    notifyListeners();
    
    debugPrint('💎 User upgraded to premium - all features unlocked');
  }

  /// Purchase premium subscription
  Future<bool> purchasePremium(String productId) async {
    if (!_isAvailable) {
      debugPrint('💎 In-app purchases not available');
      return false;
    }

    ProductDetails? productDetails;
    try {
      productDetails = _products.firstWhere(
        (product) => product.id == productId,
      );
    } catch (e) {
      debugPrint('💎 Product not found: $productId');
      return false;
    }

    if (productDetails == null) {
      debugPrint('💎 Product details not found for: $productId');
      return false;
    }

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
    
    try {
      final bool success = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      debugPrint('💎 Purchase initiated for $productId: $success');
      return success;
    } catch (e) {
      debugPrint('💎 Purchase failed: $e');
      return false;
    }
  }

  /// Restore purchases
  Future<void> restorePurchases() async {
    if (!_isAvailable) {
      debugPrint('💎 In-app purchases not available');
      return;
    }

    try {
      await _inAppPurchase.restorePurchases();
      debugPrint('💎 Purchases restored successfully');
    } catch (e) {
      debugPrint('💎 Failed to restore purchases: $e');
    }
  }

  /// Check if user can access premium feature
  bool canAccessFeature(PremiumFeature feature) {
    if (_isPremium) return true;
    
    switch (feature) {
      case PremiumFeature.advancedAnalytics:
        return _hasAdvancedAnalytics;
      case PremiumFeature.aiInsights:
        return _hasAIInsights;
      case PremiumFeature.exportFeatures:
        return _hasExportFeatures;
      case PremiumFeature.customization:
        return _hasCustomizationFeatures;
      case PremiumFeature.adFree:
        return _hasAdFreeExperience;
      case PremiumFeature.basicTracking:
        return true; // Always available
    }
  }

  /// Get premium features list
  List<String> getPremiumFeatures() {
    return [
      '📊 Advanced Analytics & Insights',
      '🤖 AI-Powered Cycle Predictions',
      '📈 Detailed Health Reports',
      '📋 Data Export (PDF, CSV)',
      '🎨 Custom Themes & Layouts',
      '🚫 Ad-Free Experience',
      '📱 Multiple Device Sync',
      '🔒 Enhanced Privacy Controls',
      '⚡ Priority Support',
      '🎯 Personalized Recommendations',
    ];
  }

  /// Get pricing information
  String getPricing(String productId) {
    try {
      final product = _products.firstWhere(
        (p) => p.id == productId,
      );
      return product.price;
    } catch (e) {
      debugPrint('💎 Product not found for pricing: $productId');
      return 'N/A';
    }
  }

  /// Save premium status to local storage
  Future<void> _savePremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium', _isPremium);
    await prefs.setBool('has_advanced_analytics', _hasAdvancedAnalytics);
    await prefs.setBool('has_ai_insights', _hasAIInsights);
    await prefs.setBool('has_export_features', _hasExportFeatures);
    await prefs.setBool('has_customization_features', _hasCustomizationFeatures);
    await prefs.setBool('has_ad_free_experience', _hasAdFreeExperience);
  }

  /// Load premium status from local storage
  Future<void> _loadPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool('is_premium') ?? false;
    _hasAdvancedAnalytics = prefs.getBool('has_advanced_analytics') ?? false;
    _hasAIInsights = prefs.getBool('has_ai_insights') ?? false;
    _hasExportFeatures = prefs.getBool('has_export_features') ?? false;
    _hasCustomizationFeatures = prefs.getBool('has_customization_features') ?? false;
    _hasAdFreeExperience = prefs.getBool('has_ad_free_experience') ?? false;
    notifyListeners();
  }

  /// Reset premium status (for testing)
  Future<void> resetPremiumStatus() async {
    _isPremium = false;
    _hasAdvancedAnalytics = false;
    _hasAIInsights = false;
    _hasExportFeatures = false;
    _hasCustomizationFeatures = false;
    _hasAdFreeExperience = false;
    
    await _savePremiumStatus();
    notifyListeners();
    debugPrint('💎 Premium status reset');
  }

  /// Grant premium for testing (remove in production)
  Future<void> grantPremiumForTesting() async {
    await _upgradeToPremium();
    debugPrint('💎 Premium granted for testing');
  }

  /// Dispose
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Premium features enum
enum PremiumFeature {
  basicTracking,
  advancedAnalytics,
  aiInsights,
  exportFeatures,
  customization,
  adFree,
}
