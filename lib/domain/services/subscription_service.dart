import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../model/subscription_model.dart';
import 'revenue_cat_service.dart';

class SubscriptionService {
  final FirebaseFirestore _firestore;
  final RevenueCatService _revenueCatService;
  final _uuid = const Uuid();

  SubscriptionService({
    FirebaseFirestore? firestore,
    RevenueCatService? revenueCatService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _revenueCatService = revenueCatService ?? RevenueCatService(firestore: firestore ?? FirebaseFirestore.instance);

  // Collection reference
  CollectionReference<Map<String, dynamic>> get _subscriptions =>
      _firestore.collection('subscriptions');

  // Initialize RevenueCat
  Future<void> initialize(String userId) async {
    await _revenueCatService.initialize(userId);
  }

  // Fetch the user's current subscription
  Future<Subscription> getUserSubscription(String userId) async {
    try {
      final querySnapshot = await _subscriptions
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .orderBy('endDate', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // Create a new free subscription if none exists
        final freeSubscription = Subscription.createFree(userId);
        await _saveSubscription(freeSubscription);
        return freeSubscription;
      }

      final subscriptionData = querySnapshot.docs.first.data();
      final subscription = Subscription.fromMap(subscriptionData);

      // Sync with RevenueCat to ensure it's up to date
      await _syncWithRevenueCat(userId, subscription);

      return subscription;
    } catch (e) {
      throw Exception('Failed to fetch subscription: $e');
    }
  }

  // Save subscription to Firestore
  Future<void> _saveSubscription(Subscription subscription) async {
    try {
      await _subscriptions.doc(subscription.id).set(subscription.toMap());
    } catch (e) {
      throw Exception('Failed to save subscription: $e');
    }
  }

  // Sync local subscription with RevenueCat
  Future<Subscription> _syncWithRevenueCat(String userId, Subscription currentSubscription) async {
    try {
      // Get current plan from RevenueCat
      final revenueCatPlan = await _revenueCatService.getSubscriptionPlan();
      
      // If plans match, no need to update
      if (revenueCatPlan == currentSubscription.plan) {
        return currentSubscription;
      }
      
      // Plans don't match, update subscription
      final now = DateTime.now();
      DateTime endDate;
      
      if (revenueCatPlan == SubscriptionPlan.monthly) {
        endDate = now.add(const Duration(days: 31));
      } else if (revenueCatPlan == SubscriptionPlan.annual) {
        endDate = now.add(const Duration(days: 366));
      } else {
        // Free plan
        endDate = now.add(const Duration(days: 3650)); // 10 years
      }
      
      // Update subscription
      final updatedSubscription = currentSubscription.copyWith(
        plan: revenueCatPlan,
        startDate: now,
        endDate: endDate,
        aiTaskGenerationsRemaining: _getGenerationsForPlan(revenueCatPlan),
        maxCollaborators: _getCollaboratorsForPlan(revenueCatPlan),
      );
      
      await _saveSubscription(updatedSubscription);
      return updatedSubscription;
    } catch (e) {
      print('Error syncing with RevenueCat: $e');
      return currentSubscription;
    }
  }

  // Helper to get generations based on plan
  int _getGenerationsForPlan(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return 5;
      case SubscriptionPlan.monthly:
        return 100;
      case SubscriptionPlan.annual:
        return 500;
    }
  }
  
  // Helper to get max collaborators based on plan
  int _getCollaboratorsForPlan(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return 1;
      case SubscriptionPlan.monthly:
        return 5;
      case SubscriptionPlan.annual:
        return 10;
    }
  }

  // Update subscription after usage (e.g., decrement AI generations)
  Future<Subscription> updateSubscriptionUsage(
    String userId, {
    int? decrementGenerations,
  }) async {
    try {
      final subscription = await getUserSubscription(userId);

      if (decrementGenerations != null && decrementGenerations > 0) {
        int remaining =
            subscription.aiTaskGenerationsRemaining - decrementGenerations;
        remaining = remaining < 0 ? 0 : remaining;

        final updated = subscription.copyWith(
          aiTaskGenerationsRemaining: remaining,
        );

        await _saveSubscription(updated);
        return updated;
      }

      return subscription;
    } catch (e) {
      throw Exception('Failed to update subscription usage: $e');
    }
  }

  // Reset monthly AI generations quota (to be called by a Cloud Function)
  Future<void> resetMonthlyQuota(String userId) async {
    try {
      final subscription = await getUserSubscription(userId);

      // Only reset if the subscription is still valid
      if (subscription.isValid) {
        final updated = subscription.copyWith(
          aiTaskGenerationsRemaining: subscription.maxGenerationsPerMonth,
        );

        await _saveSubscription(updated);
      }
    } catch (e) {
      throw Exception('Failed to reset monthly quota: $e');
    }
  }

  // Check if user can use AI generations
  Future<bool> canUseAiGeneration(String userId) async {
    try {
      final subscription = await getUserSubscription(userId);
      return subscription.isValid &&
          subscription.aiTaskGenerationsRemaining > 0;
    } catch (e) {
      throw Exception('Failed to check AI usage eligibility: $e');
    }
  }

  // Check if user can add collaborators
  Future<bool> canAddCollaborator(
      String userId, String todoId, int currentCollaboratorsCount) async {
    try {
      final subscription = await getUserSubscription(userId);
      return subscription.isValid &&
          currentCollaboratorsCount < subscription.maxCollaborators;
    } catch (e) {
      throw Exception('Failed to check collaborator limit: $e');
    }
  }

Future<List<Map<String, dynamic>>> getAvailablePackages() async {
  try {
    final packages = await _revenueCatService.getOfferings();
    return packages.map((package) {
      return {
        'identifier': package.identifier,
        // Use presentedOfferingContext instead of offering
        'offeringId': package.presentedOfferingContext.offeringIdentifier,
        // Use toString() for the enum value
        'packageType': package.packageType.toString(),
        'price': package.storeProduct.price,
        'priceString': package.storeProduct.priceString,
        'title': package.storeProduct.title,
        'description': package.storeProduct.description,
      };
    }).toList();
  } catch (e) {
    print('Error getting available packages: $e');
    return [];
  }
}

  // Purchase a subscription package
  Future<bool> purchasePackage(String packageIdentifier) async {
    try {
      final packages = await _revenueCatService.getOfferings();
      final package = packages.firstWhere(
        (p) => p.identifier == packageIdentifier,
        orElse: () => throw Exception('Package not found'),
      );
      
      final result = await _revenueCatService.purchasePackage(package);
      return result != null;
    } catch (e) {
      print('Error purchasing package: $e');
      return false;
    }
  }

  // Restore purchases
  Future<bool> restorePurchases() async {
    try {
      final result = await _revenueCatService.restorePurchases();
      return result != null;
    } catch (e) {
      print('Error restoring purchases: $e');
      return false;
    }
  }
}