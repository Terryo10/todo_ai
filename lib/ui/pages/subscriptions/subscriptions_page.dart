import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_ai/domain/bloc/auth_bloc/auth_bloc.dart';
import 'package:todo_ai/domain/bloc/subscription_bloc/subscription_bloc.dart';
import 'package:todo_ai/domain/model/subscription_model.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

@RoutePage()
class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  int _currentBenefitIndex = 0;
  bool _isYearlySelected = false;

  // Defined benefit items for the carousel
  final List<SubscriptionBenefit> _benefits = [
    SubscriptionBenefit(
      title: 'Collaborate with Team',
      description:
          'Invite teammates to work together on shared tasks and projects',
      icon: Icons.people_alt_rounded,
    ),
    SubscriptionBenefit(
      title: 'AI Task Generation',
      description:
          'Get AI-powered suggestions for organizing your tasks effectively',
      icon: Icons.smart_toy_rounded,
    ),
    SubscriptionBenefit(
      title: 'Task Assignment',
      description: 'Assign tasks to team members and track progress',
      icon: Icons.assignment_ind_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();

    // Load user's subscription details
    final userId = context.read<AuthBloc>().state is AuthAuthenticatedState
        ? (context.read<AuthBloc>().state as AuthAuthenticatedState).userId
        : null;

    if (userId != null) {
      context.read<SubscriptionBloc>().add(LoadSubscription(userId: userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Subscription'),
        elevation: 0,
      ),
      body: BlocBuilder<SubscriptionBloc, SubscriptionState>(
        builder: (context, state) {
          if (state is SubscriptionLoading || state is SubscriptionProcessing) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Subscription Header
                  _buildHeader(context),

                  const SizedBox(height: 24),

                  // Benefits Carousel
                  _buildBenefitsCarousel(context),

                  const SizedBox(height: 16),

                  // Dots Indicator for the carousel
                  _buildDotsIndicator(context),

                  const SizedBox(height: 32),

                  // Subscription Plans
                  _buildSubscriptionPlans(context, state),

                  const SizedBox(height: 24),

                  // Current Plan Info
                  if (state is SubscriptionLoaded)
                    _buildCurrentPlanInfo(context, state.subscription),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Icon(
          Icons.workspace_premium_rounded,
          size: 64,
          color: colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'Unlock Premium Features',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onBackground,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Elevate your productivity with advanced features designed for teams and professionals',
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onBackground.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBenefitsCarousel(BuildContext context) {
    final theme = Theme.of(context);

    return CarouselSlider.builder(
      carouselController: _carouselController,
      itemCount: _benefits.length,
      options: CarouselOptions(
        // height: 200, // Reduced height
        viewportFraction: 0.9,
        enlargeCenterPage: true,
        onPageChanged: (index, reason) {
          setState(() {
            _currentBenefitIndex = index;
          });
        },
      ),
      itemBuilder: (context, index, realIndex) {
        final benefit = _benefits[index];

        return Card(
          elevation: 4,
          shadowColor: theme.colorScheme.shadow.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  benefit.icon,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  benefit.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  benefit.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDotsIndicator(BuildContext context) {
    return AnimatedSmoothIndicator(
      activeIndex: _currentBenefitIndex,
      count: _benefits.length,
      effect: ExpandingDotsEffect(
        activeDotColor: Theme.of(context).colorScheme.primary,
        dotColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        dotHeight: 8,
        dotWidth: 8,
        spacing: 6,
      ),
      onDotClicked: (index) {
        _carouselController.animateToPage(index);
      },
    );
  }

  Widget _buildSubscriptionPlans(
      BuildContext context, SubscriptionState state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Toggle between monthly and yearly billing
    Widget billingToggle = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PlanToggleButton(
            text: 'Monthly',
            isSelected: !_isYearlySelected,
            onTap: () => setState(() => _isYearlySelected = false),
          ),
          const SizedBox(width: 8),
          _PlanToggleButton(
            text: 'Yearly',
            isSelected: _isYearlySelected,
            onTap: () => setState(() => _isYearlySelected = true),
          ),
        ],
      ),
    );

    // Show current pricing based on selection
    final monthlyPrice = 4.99;
    final yearlyPrice = 49.99;
    final currentPrice = _isYearlySelected ? yearlyPrice : monthlyPrice;
    final savePercentage =
        ((monthlyPrice * 12 - yearlyPrice) / (monthlyPrice * 12) * 100).round();

    return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Toggle
            billingToggle,

            const SizedBox(height: 8),

            // Savings label for yearly plan
            if (_isYearlySelected)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Save $savePercentage%',
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Premium plan card
            Card(
              elevation: 8,
              shadowColor: theme.colorScheme.shadow.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(
                  color: colorScheme.primary,
                  width: 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      'Premium',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '\$${currentPrice.toStringAsFixed(2)}',
                            style: textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          TextSpan(
                            text: _isYearlySelected ? '/year' : '/month',
                            style: textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Features list
                    ..._buildFeaturesList(context),

                    const SizedBox(height: 24),

                    // Subscribe button
                    _buildSubscribeButton(context, state),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  List<Widget> _buildFeaturesList(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    final features = [
      'Unlimited task collaborators',
      _isYearlySelected
          ? '500 AI task generations/month'
          : '100 AI task generations/month',
      'Task assignment',
      'Priority support',
      'Advanced analytics'
    ];

    return features.map((feature) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                feature,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildSubscribeButton(BuildContext context, SubscriptionState state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final userId = context.read<AuthBloc>().state is AuthAuthenticatedState
        ? (context.read<AuthBloc>().state as AuthAuthenticatedState).userId
        : '';

    bool isCurrentPlan = false;
    if (state is SubscriptionLoaded) {
      isCurrentPlan = _isYearlySelected
          ? state.subscription.plan == SubscriptionPlan.annual
          : state.subscription.plan == SubscriptionPlan.monthly;
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            isCurrentPlan ? null : () => _handleSubscription(context, userId),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Platform.isIOS ? Icons.apple : Icons.account_balance_wallet),
            const SizedBox(width: 8),
            Text(
              isCurrentPlan ? 'Current Plan' : 'Subscribe Now',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPlanInfo(
      BuildContext context, Subscription subscription) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    String planName;
    switch (subscription.plan) {
      case SubscriptionPlan.free:
        planName = 'Free';
        break;
      case SubscriptionPlan.monthly:
        planName = 'Monthly Premium';
        break;
      case SubscriptionPlan.annual:
        planName = 'Annual Premium';
        break;

    }

    // Only show end date for premium plans
    final bool showEndDate = subscription.plan != SubscriptionPlan.free;
    final endDateFormatted = showEndDate
        ? '${subscription.endDate.day}/${subscription.endDate.month}/${subscription.endDate.year}'
        : '';

    return Card(
      elevation: 2,
      shadowColor: theme.colorScheme.shadow.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Plan',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  planName,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                if (showEndDate)
                  Text(
                    'Expires: $endDateFormatted',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // AI Generations remaining
            LinearProgressIndicator(
              value: subscription.plan == SubscriptionPlan.free
                  ? subscription.aiTaskGenerationsRemaining / 5
                  : subscription.plan == SubscriptionPlan.monthly
                      ? subscription.aiTaskGenerationsRemaining / 100
                      : subscription.aiTaskGenerationsRemaining / 500,
              backgroundColor: colorScheme.primary.withOpacity(0.1),
              color: colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              '${subscription.aiTaskGenerationsRemaining} AI generations remaining',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),

            // Cancel button for premium plans
            if (subscription.plan != SubscriptionPlan.free)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: TextButton(
                  onPressed: () =>
                      _handleCancelSubscription(context, subscription),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.error,
                  ),
                  child: const Text('Cancel Subscription'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleSubscription(BuildContext context, String userId) {
    final plan =
        _isYearlySelected ? SubscriptionPlan.annual : SubscriptionPlan.monthly;

    context.read<SubscriptionBloc>().add(
          PurchaseSubscription(
            userId: userId,
            plan: plan,
          ),
        );

    // Show processing dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _ProcessingDialog(),
    );
  }

  void _handleCancelSubscription(
      BuildContext context, Subscription subscription) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Subscription'),
        content: const Text(
          'Are you sure you want to cancel your premium subscription? You\'ll lose access to premium features when your current billing period ends.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No, Keep it'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();

              final userId = context.read<AuthBloc>().state
                      is AuthAuthenticatedState
                  ? (context.read<AuthBloc>().state as AuthAuthenticatedState)
                      .userId
                  : '';

              context.read<SubscriptionBloc>().add(
                    CancelSubscription(
                      userId: userId,
                      subscriptionId: subscription.id,
                    ),
                  );

              // Show processing dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const _ProcessingDialog(),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}

// Helper class for subscription benefits
class SubscriptionBenefit {
  final String title;
  final String description;
  final IconData icon;

  SubscriptionBenefit({
    required this.title,
    required this.description,
    required this.icon,
  });
}

// Toggle button for plan selection
class _PlanToggleButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlanToggleButton({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface.withOpacity(0.7),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// Dialog shown during processing of subscription
class _ProcessingDialog extends StatelessWidget {
  const _ProcessingDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Processing Payment',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait while we process your subscription...',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
