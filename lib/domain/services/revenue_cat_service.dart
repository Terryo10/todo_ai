import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_ai/domain/model/subscription_model.dart';

class RevenueCatService {
  final String _appleApiKey = 'appl_BfUrdAnxyPeJRYLvKePknHaOtst';
  final String _androidApiKey = 'goog_zHvbsaUNepJYImXdcBihQdkQkqD';

  static const String _monthlyEntitlementId = 'premium_monthly';
  static const String _annualEntitlementId = 'premium_annual';
  static const String _entitlementIdentifier = 'premium';

  final FirebaseFirestore _firestore;
  bool _isInitialized = false;

  RevenueCatService({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  Future<void> initialize(String userId) async {
    if (_isInitialized) return;

    try {
      // Set up with the appropriate API key for the platform
      await Purchases.setLogLevel(LogLevel.debug);

      PurchasesConfiguration configuration;
      if (defaultTargetPlatform == TargetPlatform.android) {
        configuration = PurchasesConfiguration(_androidApiKey)
          ..appUserID = userId;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        configuration = PurchasesConfiguration(_appleApiKey)
          ..appUserID = userId;
      } else {
        throw Exception('Unsupported platform');
      }

      await Purchases.configure(configuration);

      // Setup purchaser info listener
      Purchases.addCustomerInfoUpdateListener((customerInfo) async {
        // Sync RevenueCat subscription state with Firestore
        await _syncSubscriptionWithFirestore(userId, customerInfo);
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint('Failed to initialize RevenueCat: $e');
      rethrow;
    }
  }

  // Get customer info
  Future<CustomerInfo> getCustomerInfo() async {
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      debugPrint('Failed to get customer info: $e');
      rethrow;
    }
  }

  // Get available packages
  Future<List<Package>> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();

      if (offerings.current == null) {
        debugPrint('No offerings available');
        return [];
      }

      return offerings.current!.availablePackages;
    } catch (e) {
      debugPrint('Failed to get offerings: $e');
      return [];
    }
  }

  // Purchase a package
  Future<CustomerInfo?> purchasePackage(Package package) async {
    try {
      final purchaseResult = await Purchases.purchasePackage(package);
      // The correct way to access CustomerInfo from the purchase result
      return purchaseResult; // The result is already a CustomerInfo object
    } on PurchasesErrorCode catch (e) {
      debugPrint('Error purchasing package: $e');
      rethrow;
    }
  }

  // Restore purchases
  Future<CustomerInfo?> restorePurchases() async {
    try {
      final restoredInfo = await Purchases.restorePurchases();
      return restoredInfo;
    } on PurchasesErrorCode catch (e) {
      debugPrint('Error restoring purchases: $e');
      rethrow;
    }
  }

  // Check if user has active subscription
  Future<bool> hasActiveSubscription() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all[_entitlementIdentifier]?.isActive ??
          false;
    } catch (e) {
      debugPrint('Error checking active subscription: $e');
      return false;
    }
  }

  // Get subscription type based on RevenueCat data
  Future<SubscriptionPlan> getSubscriptionPlan() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final entitlement = customerInfo.entitlements.all[_entitlementIdentifier];

      if (entitlement?.isActive != true) {
        return SubscriptionPlan.free;
      }

      // Check which product ID is active
      final productId = entitlement!.productIdentifier;

      if (productId.contains('monthly')) {
        return SubscriptionPlan.monthly;
      } else if (productId.contains('annual')) {
        return SubscriptionPlan.annual;
      }

      return SubscriptionPlan.free;
    } catch (e) {
      debugPrint('Error determining subscription plan: $e');
      return SubscriptionPlan.free;
    }
  }

  // Sync RevenueCat subscription state with Firestore
  Future<void> _syncSubscriptionWithFirestore(
      String userId, CustomerInfo customerInfo) async {
    try {
      final entitlement = customerInfo.entitlements.all[_entitlementIdentifier];
      final now = DateTime.now();

      // Default to free plan
      SubscriptionPlan plan = SubscriptionPlan.free;
      DateTime? expirationDate;

      if (entitlement?.isActive == true) {
        // Determine plan type
        if (entitlement!.productIdentifier.contains('monthly')) {
          plan = SubscriptionPlan.monthly;
        } else if (entitlement.productIdentifier.contains('annual')) {
          plan = SubscriptionPlan.annual;
        }

        if (entitlement.expirationDate != null) {
          try {
            // Parse the date string - format may vary depending on RevenueCat's implementation
            // Try ISO 8601 format first
            expirationDate = DateTime.parse(entitlement.expirationDate!);
          } catch (e) {
            debugPrint('Failed to parse expiration date: $e');
            // Fallback to current date plus 30 days for monthly or 365 days for annual
            expirationDate = now.add(plan == SubscriptionPlan.monthly
                ? const Duration(days: 30)
                : const Duration(days: 365));
          }
        } else {
          // If no expiration date is provided, use a default
          expirationDate = now.add(plan == SubscriptionPlan.monthly
              ? const Duration(days: 30)
              : const Duration(days: 365));
        }
      }

      // Rest of the method remains the same...
    } catch (e) {
      debugPrint('Error syncing subscription with Firestore: $e');
    }
  }

  // Create a new subscription in Firestore
  Future<void> _createNewSubscription(
    String userId,
    SubscriptionPlan plan,
    DateTime? expirationDate,
  ) async {
    final now = DateTime.now();

    // Base generation limits based on plan
    int aiGenerationsRemaining = 5; // Free plan
    int maxCollaborators = 1; // Free plan

    if (plan == SubscriptionPlan.monthly) {
      aiGenerationsRemaining = 100;
      maxCollaborators = 5;
    } else if (plan == SubscriptionPlan.annual) {
      aiGenerationsRemaining = 500;
      maxCollaborators = 10;
    }

    // Create subscription document
    await _firestore.collection('subscriptions').add({
      'id': _firestore.collection('subscriptions').doc().id,
      'userId': userId,
      'plan': plan.toString().split('.').last,
      'startDate': Timestamp.fromDate(now),
      'endDate': expirationDate != null
          ? Timestamp.fromDate(expirationDate)
          : Timestamp.fromDate(
              now.add(const Duration(days: 3650))), // Default 10 years for free
      'isActive': true,
      'aiTaskGenerationsRemaining': aiGenerationsRemaining,
      'maxCollaborators': maxCollaborators,
    });
  }

  // Update existing subscription in Firestore
  Future<void> _updateExistingSubscription(
    QueryDocumentSnapshot doc,
    SubscriptionPlan newPlan,
    DateTime? expirationDate,
  ) async {
    // Get current subscription data
    final data = doc.data() as Map<String, dynamic>;
    final currentPlan = _planFromString(data['plan'] ?? 'free');

    // If downgrading from premium to free, preserve remaining generations
    int aiGenerationsRemaining = data['aiTaskGenerationsRemaining'] ?? 0;
    int maxCollaborators = 1;

    if (newPlan == SubscriptionPlan.monthly) {
      // Only reset counts if upgrading from free or if count is very low
      if (currentPlan == SubscriptionPlan.free || aiGenerationsRemaining < 10) {
        aiGenerationsRemaining = 100;
      }
      maxCollaborators = 5;
    } else if (newPlan == SubscriptionPlan.annual) {
      // Only reset counts if upgrading from free/monthly or if count is very low
      if (currentPlan != SubscriptionPlan.annual ||
          aiGenerationsRemaining < 50) {
        aiGenerationsRemaining = 500;
      }
      maxCollaborators = 10;
    }

    // Update subscription document
    await doc.reference.update({
      'plan': newPlan.toString().split('.').last,
      'endDate': expirationDate != null
          ? Timestamp.fromDate(expirationDate)
          : FieldValue.serverTimestamp(),
      'aiTaskGenerationsRemaining': aiGenerationsRemaining,
      'maxCollaborators': maxCollaborators,
    });
  }

  // Helper to convert string to SubscriptionPlan
  SubscriptionPlan _planFromString(String plan) {
    switch (plan) {
      case 'monthly':
        return SubscriptionPlan.monthly;
      case 'annual':
        return SubscriptionPlan.annual;
      default:
        return SubscriptionPlan.free;
    }
  }
}
