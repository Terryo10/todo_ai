
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/bloc/subscription_bloc/subscription_bloc.dart';
import '../../../domain/bloc/todo_bloc/todo_bloc.dart';
import '../../../domain/model/subscription_model.dart';
import '../../../routes/router.gr.dart';

class ProfileInfoCards extends StatelessWidget {
  const ProfileInfoCards({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final todoState = context.watch<TodoBloc>().state;
    final subscriptionState = context.watch<SubscriptionBloc>().state;
    
    String usersTodos = '0';
    String accountType = 'Free';
    String collaborators = '0';

    if (todoState is TodoLoaded) {
      usersTodos = todoState.todos.length.toString();
    }
    
    if (subscriptionState is SubscriptionLoaded) {
      // Update account type based on subscription plan
      switch (subscriptionState.subscription.plan) {
        case SubscriptionPlan.monthly:
          accountType = 'Premium (Monthly)';
          break;
        case SubscriptionPlan.annual:
          accountType = 'Premium (Annual)';
          break;
        case SubscriptionPlan.free:
        accountType = 'Free';
          
      }
      
      // Max collaborators based on subscription
      collaborators = subscriptionState.subscription.maxCollaborators.toString();
    }

    // Create items list with dynamic data
    final List<ProfileInfoItem> items = [
      ProfileInfoItem(
        "Account Type", 
        accountType, 
        Icons.workspace_premium,
        onTap: () => _navigateToSubscription(context),
      ),
      ProfileInfoItem("Todos", usersTodos, Icons.check_circle),
      ProfileInfoItem("Collaborators", collaborators, Icons.people),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text(
              "Your Profile",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return _InfoCard(items[index]);
            },
          ),
          
          // Only show subscription info for premium users
          if (subscriptionState is SubscriptionLoaded && 
              subscriptionState.subscription.plan != SubscriptionPlan.free)
            _buildSubscriptionInfo(context, subscriptionState.subscription),
          
          // Call to action for free users
          if (subscriptionState is SubscriptionLoaded && 
              subscriptionState.subscription.plan == SubscriptionPlan.free)
            _buildUpgradeCard(context),
        ],
      ),
    );
  }
  
  Widget _buildSubscriptionInfo(BuildContext context, Subscription subscription) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
            child: Text(
              "Subscription Status",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),
          ),
          Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "AI Generations",
                        style: theme.textTheme.titleSmall,
                      ),
                      Text(
                        "${subscription.aiTaskGenerationsRemaining}/${subscription.maxGenerationsPerMonth}",
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: subscription.aiTaskGenerationsRemaining / 
                           subscription.maxGenerationsPerMonth,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    color: theme.colorScheme.primary,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Show expiration date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Valid Until",
                        style: theme.textTheme.titleSmall,
                      ),
                      Text(
                        "${subscription.endDate.day}/${subscription.endDate.month}/${subscription.endDate.year}",
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Manage subscription button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _navigateToSubscription(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                        side: BorderSide(color: theme.colorScheme.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Manage Subscription"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildUpgradeCard(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(top: 24, left: 4, right: 4),
      color: theme.colorScheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.star,
                  color: theme.colorScheme.onPrimary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  "Upgrade to Premium",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "Get unlimited collaborators, AI task generation, and more!",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _navigateToSubscription(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.onPrimary,
                  foregroundColor: theme.colorScheme.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Upgrade Now",
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _navigateToSubscription(BuildContext context) {
    context.navigateTo(SubscriptionRoute());
  }
}

// Update the ProfileInfoItem class to include optional tap function
class ProfileInfoItem {
  final String title;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  const ProfileInfoItem(this.title, this.value, this.icon, {this.onTap});
}

// Update the _InfoCard class to handle taps
class _InfoCard extends StatelessWidget {
  final ProfileInfoItem item;

  const _InfoCard(this.item);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: item.onTap,
      child: Card(
        elevation: 4,
        shadowColor: theme.colorScheme.shadow.withOpacity(0.3),
        color: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: theme.colorScheme.primary.withOpacity(0.2),
            width: 1.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item.icon,
                size: 32,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                item.value.toString(),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              if (item.onTap != null)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: theme.colorScheme.primary.withOpacity(0.5),
                ),
            ],
          ),
        ),
      ),
    );
  }
}