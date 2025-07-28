import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/logger_service.dart';

class PhoneAuthScreen extends ConsumerStatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  ConsumerState<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends ConsumerState<PhoneAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _focusNode = FocusNode();
  
  String _selectedCountryCode = '+91';
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _verifyPhoneNumber() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final phoneNumber = '$_selectedCountryCode${_phoneController.text.trim()}';
      
      LoggerService.userAction('PhoneAuthScreen', '_verifyPhoneNumber', 
          'Starting verification for: $phoneNumber');

      await ref.read(phoneVerificationControllerProvider.notifier)
          .verifyPhoneNumber(phoneNumber);

      if (mounted) {
        context.go('/verification', extra: phoneNumber);
      }
    } catch (e) {
      LoggerService.error('PhoneAuthScreen', '_verifyPhoneNumber', 
          'Phone verification failed: $e');
      
      if (mounted) {
        _showErrorDialog('Verification Failed', 
            'Unable to verify phone number. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    
    if (value.length != 10) {
      return 'Please enter a valid 10-digit phone number';
    }
    
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Phone number should contain only digits';
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    ref.listen<AsyncValue<void>>(phoneVerificationControllerProvider, (_, state) {
      state.whenOrNull(
        error: (error, _) {
          _showErrorDialog('Error', error.toString());
        },
      );
    });

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Phone Verification'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/welcome'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.largePadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),

                // Header
                Text(
                  'Enter your phone number',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'We\'ll send you a verification code to confirm your number.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.7),
                  ),
                ),

                const SizedBox(height: 48),

                // Phone input section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Phone Number',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Country code and phone number input
                    Row(
                      children: [
                        // Country code dropdown
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: theme.colorScheme.outline,
                            ),
                            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                            color: theme.colorScheme.surface,
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCountryCode,
                              isDense: true,
                              icon: const Icon(Icons.arrow_drop_down),
                              items: const [
                                DropdownMenuItem(
                                  value: '+91',
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('🇮🇳'),
                                      SizedBox(width: 8),
                                      Text('+91'),
                                    ],
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedCountryCode = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Phone number input
                        Expanded(
                          child: TextFormField(
                            controller: _phoneController,
                            focusNode: _focusNode,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            decoration: const InputDecoration(
                              hintText: 'Enter phone number',
                              counterText: '',
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            validator: _validatePhoneNumber,
                            onFieldSubmitted: (_) => _verifyPhoneNumber(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Information box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'We will send you a verification code via SMS. Standard message rates may apply.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Continue button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyPhoneNumber,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Text('Send Verification Code'),
                  ),
                ),

                const SizedBox(height: 16),

                // Terms and privacy
                Text(
                  'By continuing, you agree to our Terms of Service and Privacy Policy.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}