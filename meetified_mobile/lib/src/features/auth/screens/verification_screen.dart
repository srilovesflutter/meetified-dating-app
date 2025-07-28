import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/logger_service.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const VerificationScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  bool _isLoading = false;
  bool _isResending = false;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Auto-focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  String get _verificationCode {
    return _controllers.map((controller) => controller.text).join();
  }

  bool get _isCodeComplete {
    return _verificationCode.length == 6;
  }

  Future<void> _verifyCode() async {
    if (!_isCodeComplete) return;

    setState(() {
      _isLoading = true;
    });

    try {
      LoggerService.userAction('VerificationScreen', '_verifyCode', 
          'Verifying SMS code');

      final result = await ref.read(phoneVerificationControllerProvider.notifier)
          .verifySMSCode(_verificationCode);

      if (result != null && mounted) {
        // Check if user profile exists
        final userExists = await _checkUserExists(result.user!.uid);
        
        if (userExists) {
          context.go('/home');
        } else {
          context.go('/profile-building');
        }
      }
    } catch (e) {
      LoggerService.error('VerificationScreen', '_verifyCode', 
          'Verification failed: $e');
      
      if (mounted) {
        _showErrorDialog('Verification Failed', 
            'Invalid verification code. Please try again.');
        _clearCode();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _checkUserExists(String userId) async {
    try {
      // This would check if user profile exists in Firestore
      // For now, return false to always go to profile building
      return false;
    } catch (e) {
      LoggerService.error('VerificationScreen', '_checkUserExists', 
          'Failed to check user existence: $e');
      return false;
    }
  }

  Future<void> _resendCode() async {
    setState(() {
      _isResending = true;
    });

    try {
      LoggerService.userAction('VerificationScreen', '_resendCode', 
          'Resending verification code');

      await ref.read(phoneVerificationControllerProvider.notifier)
          .verifyPhoneNumber(widget.phoneNumber);

      if (mounted) {
        _showSuccessSnackBar('Verification code sent');
        _clearCode();
      }
    } catch (e) {
      LoggerService.error('VerificationScreen', '_resendCode', 
          'Resend failed: $e');
      
      if (mounted) {
        _showErrorDialog('Resend Failed', 
            'Unable to resend verification code. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  void _clearCode() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _onCodeChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Auto-verify when code is complete
    if (_isCodeComplete && !_isLoading) {
      _verifyCode();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
        title: const Text('Verify Phone'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/auth'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.largePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),

              // Header
              Text(
                'Enter verification code',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              Text(
                'We\'ve sent a 6-digit code to',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onBackground.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                widget.phoneNumber,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Code input
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 48,
                    height: 56,
                    child: TextFormField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(1),
                      ],
                      onChanged: (value) => _onCodeChanged(value, index),
                      onTap: () {
                        // Clear field when tapped
                        _controllers[index].clear();
                      },
                    ),
                  );
                }),
              ),

              const SizedBox(height: 32),

              // Loading indicator
              if (_isLoading)
                Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Verifying code...',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onBackground.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),

              const Spacer(),

              // Resend section
              Column(
                children: [
                  Text(
                    'Didn\'t receive the code?',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  TextButton(
                    onPressed: _isResending ? null : _resendCode,
                    child: _isResending
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Resend Code'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Verify button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isCodeComplete && !_isLoading ? _verifyCode : null,
                  child: const Text('Verify'),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}