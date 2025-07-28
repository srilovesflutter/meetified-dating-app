import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/logger_service.dart';

// Auth state provider
final authStateProvider = StreamProvider<User?>((ref) {
  return AuthService.authStateChanges;
});

// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});

// Current user ID provider
final currentUserIdProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.uid;
});

// Is authenticated provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});

// User profile stream provider
final userProfileStreamProvider = StreamProvider.family<UserModel?, String>((ref, userId) {
  if (userId.isEmpty) {
    return Stream.value(null);
  }
  return AuthService.getCurrentUserStream();
});

// Current user profile provider
final currentUserProfileProvider = Provider<AsyncValue<UserModel?>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return const AsyncValue.data(null);
  }
  return ref.watch(userProfileStreamProvider(userId));
});

// Premium status provider
final isPremiumUserProvider = FutureProvider.family<bool, String>((ref, userId) async {
  if (userId.isEmpty) return false;
  return await AuthService.isPremiumUser(userId);
});

// Current user premium status provider
final currentUserPremiumStatusProvider = Provider<AsyncValue<bool>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return const AsyncValue.data(false);
  }
  return ref.watch(isPremiumUserProvider(userId));
});

// Auth controller for managing authentication actions
class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController() : super(const AsyncValue.data(null));

  // Sign out
  Future<void> signOut() async {
    try {
      LoggerService.userAction('AuthController', 'signOut', 'User signing out');
      state = const AsyncValue.loading();
      
      await AuthService.signOut();
      
      state = const AsyncValue.data(null);
      LoggerService.success('AuthController', 'signOut', 'Sign out successful');
    } catch (e, stackTrace) {
      LoggerService.error('AuthController', 'signOut', 'Sign out failed: $e');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Update user profile
  Future<void> updateUserProfile(String userId, Map<String, dynamic> updates) async {
    try {
      LoggerService.userAction('AuthController', 'updateUserProfile', 'Updating profile for: $userId');
      state = const AsyncValue.loading();
      
      await AuthService.updateUserProfile(userId, updates);
      
      state = const AsyncValue.data(null);
      LoggerService.success('AuthController', 'updateUserProfile', 'Profile updated successfully');
    } catch (e, stackTrace) {
      LoggerService.error('AuthController', 'updateUserProfile', 'Profile update failed: $e');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Update premium status
  Future<void> updatePremiumStatus(String userId, bool isPremium, [DateTime? expiryDate]) async {
    try {
      LoggerService.userAction('AuthController', 'updatePremiumStatus', 
          'Updating premium status for: $userId to $isPremium');
      state = const AsyncValue.loading();
      
      await AuthService.updatePremiumStatus(userId, isPremium, expiryDate);
      
      state = const AsyncValue.data(null);
      LoggerService.success('AuthController', 'updatePremiumStatus', 'Premium status updated');
    } catch (e, stackTrace) {
      LoggerService.error('AuthController', 'updatePremiumStatus', 'Premium update failed: $e');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      LoggerService.userAction('AuthController', 'deleteAccount', 'Deleting user account');
      state = const AsyncValue.loading();
      
      await AuthService.deleteAccount();
      
      state = const AsyncValue.data(null);
      LoggerService.success('AuthController', 'deleteAccount', 'Account deleted successfully');
    } catch (e, stackTrace) {
      LoggerService.error('AuthController', 'deleteAccount', 'Account deletion failed: $e');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Update last active
  Future<void> updateLastActive() async {
    try {
      await AuthService.updateLastActive();
    } catch (e) {
      LoggerService.error('AuthController', 'updateLastActive', 'Failed to update last active: $e');
    }
  }
}

// Auth controller provider
final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController();
});

// Phone verification controller
class PhoneVerificationController extends StateNotifier<AsyncValue<void>> {
  PhoneVerificationController() : super(const AsyncValue.data(null));

  String? _verificationId;
  int? _resendToken;

  // Start phone verification
  Future<void> verifyPhoneNumber(String phoneNumber) async {
    try {
      LoggerService.userAction('PhoneVerificationController', 'verifyPhoneNumber', 
          'Starting verification for: $phoneNumber');
      state = const AsyncValue.loading();

      await AuthService.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed
          LoggerService.log('PhoneVerificationController', 'verifyPhoneNumber', 
              'Auto-verification completed');
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          LoggerService.error('PhoneVerificationController', 'verifyPhoneNumber', 
              'Verification failed: ${e.message}');
          state = AsyncValue.error(e, StackTrace.current);
        },
        codeSent: (String verificationId, int? resendToken) {
          LoggerService.log('PhoneVerificationController', 'verifyPhoneNumber', 
              'Code sent successfully');
          _verificationId = verificationId;
          _resendToken = resendToken;
          state = const AsyncValue.data(null);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          LoggerService.log('PhoneVerificationController', 'verifyPhoneNumber', 
              'Auto retrieval timeout');
          _verificationId = verificationId;
        },
      );
    } catch (e, stackTrace) {
      LoggerService.error('PhoneVerificationController', 'verifyPhoneNumber', 
          'Phone verification error: $e');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Verify SMS code
  Future<UserCredential?> verifySMSCode(String smsCode) async {
    try {
      LoggerService.userAction('PhoneVerificationController', 'verifySMSCode', 
          'Verifying SMS code');
      
      if (_verificationId == null) {
        throw Exception('Verification ID not found. Please restart verification.');
      }

      state = const AsyncValue.loading();

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      UserCredential result = await _signInWithCredential(credential);
      
      state = const AsyncValue.data(null);
      LoggerService.success('PhoneVerificationController', 'verifySMSCode', 
          'SMS verification successful');
      
      return result;
    } catch (e, stackTrace) {
      LoggerService.error('PhoneVerificationController', 'verifySMSCode', 
          'SMS verification failed: $e');
      state = AsyncValue.error(e, stackTrace);
      return null;
    }
  }

  Future<UserCredential> _signInWithCredential(PhoneAuthCredential credential) async {
    return await AuthService.signInWithPhoneCredential(credential);
  }

  // Reset state
  void reset() {
    _verificationId = null;
    _resendToken = null;
    state = const AsyncValue.data(null);
  }

  // Getters
  bool get isCodeSent => _verificationId != null;
  String? get verificationId => _verificationId;
}

// Phone verification controller provider
final phoneVerificationControllerProvider = 
    StateNotifierProvider<PhoneVerificationController, AsyncValue<void>>((ref) {
  return PhoneVerificationController();
});

// User creation controller
class UserCreationController extends StateNotifier<AsyncValue<void>> {
  UserCreationController() : super(const AsyncValue.data(null));

  Future<void> createUserProfile(UserModel user) async {
    try {
      LoggerService.userAction('UserCreationController', 'createUserProfile', 
          'Creating profile for: ${user.userId}');
      state = const AsyncValue.loading();

      await AuthService.createUserProfile(user);

      state = const AsyncValue.data(null);
      LoggerService.success('UserCreationController', 'createUserProfile', 
          'User profile created successfully');
    } catch (e, stackTrace) {
      LoggerService.error('UserCreationController', 'createUserProfile', 
          'Profile creation failed: $e');
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

// User creation controller provider
final userCreationControllerProvider = 
    StateNotifierProvider<UserCreationController, AsyncValue<void>>((ref) {
  return UserCreationController();
});