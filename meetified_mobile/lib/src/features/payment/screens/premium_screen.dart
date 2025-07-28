import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';

class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Premium'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Premium header
            Container(
              padding: const EdgeInsets.all(AppConstants.largePadding),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.amber.shade400,
                    Colors.orange.shade400,
                  ],
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.star,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Upgrade to Premium',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Unlock all features and enhance your dating experience',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Features list
            Padding(
              padding: const EdgeInsets.all(AppConstants.largePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Premium Features',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildFeatureItem(
                    theme,
                    Icons.visibility,
                    'Instant Identity Reveals',
                    'See your matches\' identities immediately without waiting for mutual interest',
                  ),
                  
                  _buildFeatureItem(
                    theme,
                    Icons.favorite,
                    'Unlimited Matches',
                    'Get unlimited daily matches instead of the standard 5 per day',
                  ),
                  
                  _buildFeatureItem(
                    theme,
                    Icons.psychology,
                    'Advanced AI Insights',
                    'Get deeper compatibility analysis and personalized matching tips',
                  ),
                  
                  _buildFeatureItem(
                    theme,
                    Icons.priority_high,
                    'Priority Matching',
                    'Your profile gets priority in the matching algorithm',
                  ),
                  
                  _buildFeatureItem(
                    theme,
                    Icons.undo,
                    'Undo Actions',
                    'Change your mind? Undo passes and revisit potential matches',
                  ),
                  
                  _buildFeatureItem(
                    theme,
                    Icons.emoji_emotions,
                    'Enhanced Chat Features',
                    'Send voice messages, high-quality photos, and premium emojis',
                  ),
                  
                  _buildFeatureItem(
                    theme,
                    Icons.shield,
                    'Money-Back Guarantee',
                    'Not satisfied with your matches? Get your money back within 30 days',
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Pricing
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.amber,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.amber.withOpacity(0.1),
                          Colors.orange.withOpacity(0.1),
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '₹${AppConstants.premiumPrice.toInt()}',
                          style: theme.textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade700,
                          ),
                        ),
                        Text(
                          'per month',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.amber.shade700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '7-day free trial',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Payment options
                  Text(
                    'Payment Method',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.account_balance,
                            color: Colors.blue,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'UPI Payment',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Pay securely with any UPI app',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'GPay • PhonePe • Paytm',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Subscribe button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _subscribeToPremium,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                        ),
                      ),
                      child: _isProcessing
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.star, size: 24),
                                const SizedBox(width: 8),
                                Text(
                                  'Start Free Trial',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Terms
                  Text(
                    'By subscribing, you agree to our Terms of Service. Your subscription will automatically renew unless cancelled at least 24 hours before the end of the current period.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    ThemeData theme,
    IconData icon,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              icon,
              color: Colors.amber.shade700,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _subscribeToPremium() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        _showUPIPaymentDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showUPIPaymentDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('UPI Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Pay ₹99 for Premium subscription'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'UPI ID: ${AppConstants.upiId}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Amount: ₹99'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Complete the payment using any UPI app and we\'ll verify it automatically.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showPaymentSuccessDialog();
            },
            child: const Text('Payment Done'),
          ),
        ],
      ),
    );
  }

  void _showPaymentSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 28,
            ),
            const SizedBox(width: 8),
            const Text('Payment Successful!'),
          ],
        ),
        content: const Text(
          'Welcome to Premium! You now have access to all premium features. Enjoy your enhanced dating experience!',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to previous screen
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}