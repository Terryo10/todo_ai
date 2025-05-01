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
  String? _selectedPackageId;

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

    // Get user ID from auth bloc
    final userId = context.read<AuthBloc>().state is AuthAuthenticatedState
        ? (context.read<AuthBloc>().state as AuthAuthenticatedState).userId
        : null;

    if (userId != null) {
      // Initialize RevenueCat
      context
          .read<SubscriptionBloc>()
          .add(InitializeRevenueCat(userId: userId));

      // Load user's subscription details
      context.read<SubscriptionBloc>().add(LoadSubscription(userId: userId));

      // Load available packages
      context
          .read<SubscriptionBloc>()
          .add(LoadAvailablePackages(userId: userId));
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
        actions: [
          BlocBuilder<SubscriptionBloc, SubscriptionState>(
            builder: (context, state) {
              if (state is SubscriptionLoaded &&
                  state.subscription.plan != SubscriptionPlan.free) {
                return IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Restore Purchases',
                  onPressed: () => _restorePurchases(context),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
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

                  // Subscription Packages
                  _buildSubscriptionPackages(context, state),

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

  Widget _buildSubscriptionPackages(
      BuildContext context, SubscriptionState state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Available packages
    List<Map<String, dynamic>> packages = [];

    if (state is SubscriptionLoaded && state.availablePackages != null) {
      packages = state.availablePackages!;
    }

    // If no packages available yet, show loading
    if (packages.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: packages.length,
      itemBuilder: (context, index) {
        final package = packages[index];
        final isSelected = _selectedPackageId == package['identifier'];
        final isCurrent = state is SubscriptionLoaded &&
            ((state.subscription.plan == SubscriptionPlan.monthly &&
                    package['packageType'] == 'MONTHLY') ||
                (state.subscription.plan == SubscriptionPlan.annual &&
                    package['packageType'] == 'ANNUAL'));

        return Card(
          elevation: isSelected ? 8 : 4,
          shadowColor:
              theme.colorScheme.shadow.withOpacity(isSelected ? 0.5 : 0.3),
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isSelected || isCurrent
                  ? colorScheme.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: InkWell(
            onTap: isCurrent
                ? null
                : () {
                    setState(() {
                      _selectedPackageId = package['identifier'];
                    });
                  },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        package['title'] ?? 'Premium Subscription',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (isCurrent)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Current Plan',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    package['priceString'] ?? '\$0.00',
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    package['description'] ?? 'Premium subscription package',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!isCurrent)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSelected
                            ? () =>
                                _purchasePackage(context, package['identifier'])
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          'Subscribe Now',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
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
          ],
        ),
      ),
    );
  }

  void _purchasePackage(BuildContext context, String packageId) {
    final userId = context.read<AuthBloc>().state is AuthAuthenticatedState
        ? (context.read<AuthBloc>().state as AuthAuthenticatedState).userId
        : null;

    if (userId == null) {
      _showErrorSnackBar(
          context, 'You need to be logged in to purchase a subscription');
      return;
    }

    context.read<SubscriptionBloc>().add(PurchasePackage(
          userId: userId,
          packageIdentifier: packageId,
        ));
  }

  void _restorePurchases(BuildContext context) {
    final userId = context.read<AuthBloc>().state is AuthAuthenticatedState
        ? (context.read<AuthBloc>().state as AuthAuthenticatedState).userId
        : null;

    if (userId == null) {
      _showErrorSnackBar(
          context, 'You need to be logged in to restore purchases');
      return;
    }

    context.read<SubscriptionBloc>().add(RestorePurchases(userId: userId));
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
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
