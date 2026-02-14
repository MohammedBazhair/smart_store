import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/presentation/theme/app_theme.dart';
import '../../domain/entities/account_status.dart';
import '../../domain/entities/profile.dart';
import '../../domain/entities/status_config.dart';
import '../widgets/account_details_widget.dart';
import '../widgets/continue_button_widget.dart';
import '../widgets/status_card_widget.dart';
import '../widgets/status_icon_widget.dart';

class AccountStatusScreen extends ConsumerStatefulWidget {
  const AccountStatusScreen({
    super.key,
    required this.profile,
  });

  final ProfileEntity profile;

  @override
  ConsumerState<AccountStatusScreen> createState() =>
      _AccountStatusScreenState();
}

class _AccountStatusScreenState extends ConsumerState<AccountStatusScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusConfig =
        StatusConfig.getStatusConfig(widget.profile.accountStatus);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              statusConfig.primaryColor.withOpacity(0.1),
              statusConfig.secondaryColor.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            const SizedBox(height: 40),

                            // Status Icon with Animation
                            ScaleTransition(
                              scale: _scaleAnimation,
                              child: StatusIconWidget(config: statusConfig),
                            ),

                            const SizedBox(height: 32),

                            // Welcome Text
                            SlideTransition(
                              position: _slideAnimation,
                              child: Column(
                                children: [
                                  Text(
                                    'مرحباً بك',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          color: AppTheme.textSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.profile.username,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textPrimary,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 48),

                            // Status Card
                            SlideTransition(
                              position: _slideAnimation,
                              child: StatusCardWidget(config: statusConfig),
                            ),

                            const SizedBox(height: 32),

                            // Account Details
                            SlideTransition(
                              position: _slideAnimation,
                              child: AccountDetailsWidget(
                                profile: widget.profile,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Continue Button
                    SlideTransition(
                      position: _slideAnimation,
                      child: ContinueButtonWidget(
                        config: statusConfig,
                        canContinue: widget.profile.accountStatus == AccountStatus.active,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
