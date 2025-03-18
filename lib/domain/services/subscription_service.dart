import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
// Import the purchase plugin (you'll need to add this to pubspec.yaml)
import 'package:in_app_purchase/in_app_purchase.dart';

import '../model/subscription_model.dart';

class SubscriptionException implements Exception {
  final String message;

  SubscriptionException(this.message);

  @override
  String toString() => 'SubscriptionException: $message';
}

class SubscriptionService {
  final FirebaseFirestore _firestore;
  final InAppPurchase _inAppPurchase;
  final _uuid = const Uuid();

  SubscriptionService({
    FirebaseFirestore? firestore,
    InAppPurchase? inAppPurchase,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _inAppPurchase = inAppPurchase ?? InAppPurchase.instance;

  // Collection reference
  CollectionReference<Map<String, dynamic>> get _subscriptions =>
      _firestore.collection('subscriptions');

  // Product IDs for the subscription plans
  static const String monthlyProductId = 'com.yourapp.subscription.monthly';
  static const String annualProductId = 'com.yourapp.subscription.annual';

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
        await saveSubscription(freeSubscription);
        return freeSubscription;
      }

      final subscriptionData = querySnapshot.docs.first.data();
      final subscription = Subscription.fromMap(subscriptionData);

      // Check if the subscription is expired but still marked as active
      if (!subscription.isValid && subscription.isActive) {
        // Deactivate the subscription if it's expired
        await _subscriptions.doc(subscription.id).update({'isActive': false});

        // Return a new free subscription
        final freeSubscription = Subscription.createFree(userId);
        await saveSubscription(freeSubscription);
        return freeSubscription;
      }

      return subscription;
    } catch (e) {
      throw SubscriptionException('Failed to fetch subscription: $e');
    }
  }

  // Save subscription to Firestore
  Future<void> saveSubscription(Subscription subscription) async {
    try {
      await _subscriptions.doc(subscription.id).set(subscription.toMap());
    } catch (e) {
      throw SubscriptionException('Failed to save subscription: $e');
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

        await saveSubscription(updated);
        return updated;
      }

      return subscription;
    } catch (e) {
      throw SubscriptionException('Failed to update subscription usage: $e');
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

        await saveSubscription(updated);
      }
    } catch (e) {
      throw SubscriptionException('Failed to reset monthly quota: $e');
    }
  }

  // Check if user can use AI generations
  Future<bool> canUseAiGeneration(String userId) async {
    try {
      final subscription = await getUserSubscription(userId);
      print(
          'Subscription check: isValid=${subscription.isValid}, aiTaskGenerationsRemaining=${subscription.aiTaskGenerationsRemaining}');
      return subscription.isValid &&
          subscription.aiTaskGenerationsRemaining > 0;
    } catch (e) {
      throw SubscriptionException('Failed to check AI usage eligibility: $e');
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
      throw SubscriptionException('Failed to check collaborator limit: $e');
    }
  }

  // Start the subscription purchase flow
  Future<void> purchaseSubscription(
      String userId, SubscriptionPlan plan) async {
    try {
      // Determine the product ID based on the plan
      final productId =
          plan == SubscriptionPlan.monthly ? monthlyProductId : annualProductId;

      // Check availability
      final available = await _inAppPurchase.isAvailable();
      if (!available) {
        throw SubscriptionException('Store is not available');
      }

      // Load product details
      final response = await _inAppPurchase.queryProductDetails({productId});
      if (response.notFoundIDs.isNotEmpty) {
        throw SubscriptionException('Product not found: $productId');
      }

      final products = response.productDetails;
      if (products.isEmpty) {
        throw SubscriptionException('No products available');
      }

      // Purchase
      final purchaseParam = PurchaseParam(productDetails: products.first);
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);

      // The purchase will be completed via a listener
      // See the complete implementation for handling purchase updates
    } catch (e) {
      throw SubscriptionException('Failed to initiate purchase: $e');
    }
  }

  // Process a successful purchase and update the subscription
  Future<Subscription> processSuccessfulPurchase(
      String userId, String purchaseId, SubscriptionPlan plan) async {
    try {
      final now = DateTime.now();

      // Calculate subscription end date
      final endDate = plan == SubscriptionPlan.monthly
          ? now.add(const Duration(days: 30))
          : now.add(const Duration(days: 365));

      // Set collaborators limit based on plan
      final maxCollaborators = plan == SubscriptionPlan.free
          ? 1
          : plan == SubscriptionPlan.monthly
              ? 5 // Monthly plan gets 5 collaborators
              : 10; // Annual plan gets 10 collaborators

      // Get max generations per month based on plan
      final generations = plan == SubscriptionPlan.free
          ? 5
          : plan == SubscriptionPlan.monthly
              ? 100
              : 500; // Annual plan

      // Create new subscription
      final subscription = Subscription(
        id: _uuid.v4(),
        userId: userId,
        plan: plan,
        startDate: now,
        endDate: endDate,
        paymentId: purchaseId,
        isActive: true,
        aiTaskGenerationsRemaining: generations, // Use the value we calculated
        maxCollaborators: maxCollaborators,
      );

      // Deactivate current subscription if exists
      final currentSubscription = await getUserSubscription(userId);
      if (currentSubscription.id.isNotEmpty &&
          currentSubscription.plan != SubscriptionPlan.free) {
        await _subscriptions
            .doc(currentSubscription.id)
            .update({'isActive': false});
      }

      // Save new subscription
      await saveSubscription(subscription);

      return subscription;
    } catch (e) {
      throw SubscriptionException('Failed to process purchase: $e');
    }
  }

  // Cancel subscription
  Future<void> cancelSubscription(String userId, String subscriptionId) async {
    try {
      // Mark the subscription as inactive
      await _subscriptions.doc(subscriptionId).update({
        'isActive': false,
      });

      // Create a new free subscription
      final freeSubscription = Subscription.createFree(userId);
      await saveSubscription(freeSubscription);

      // Note: In a real app, you would also handle the platform-specific
      // cancellation through Google Play or App Store
    } catch (e) {
      throw SubscriptionException('Failed to cancel subscription: $e');
    }
  }
}
