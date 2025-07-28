import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../constants/app_constants.dart';
import 'firebase_service.dart';
import 'logger_service.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseService.auth;
  static final FirebaseFirestore _firestore = FirebaseService.firestore;

  // Auth state stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current user
  static User? get currentUser => _auth.currentUser;
  static String? get currentUserId => _auth.currentUser?.uid;

  // Phone authentication
  static Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    try {
      LoggerService.log('AuthService', 'verifyPhoneNumber', 'Starting phone verification for: $phoneNumber');
      
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      LoggerService.error('AuthService', 'verifyPhoneNumber', 'Phone verification failed: $e');
      rethrow;
    }
  }

  // Sign in with phone credential
  static Future<UserCredential> signInWithPhoneCredential(PhoneAuthCredential credential) async {
    try {
      LoggerService.log('AuthService', 'signInWithPhoneCredential', 'Signing in with phone credential');
      
      UserCredential result = await _auth.signInWithCredential(credential);
      
      LoggerService.success('AuthService', 'signInWithPhoneCredential', 
          'Phone sign-in successful for user: ${result.user?.uid}');
      
      return result;
    } catch (e) {
      LoggerService.error('AuthService', 'signInWithPhoneCredential', 'Phone sign-in failed: $e');
      rethrow;
    }
  }

  // Create user profile after authentication
  static Future<void> createUserProfile(UserModel user) async {
    try {
      LoggerService.log('AuthService', 'createUserProfile', 'Creating user profile for: ${user.userId}');
      
      await FirebaseService.userDocument(user.userId).set(user.toJson());
      
      LoggerService.success('AuthService', 'createUserProfile', 
          'User profile created successfully for: ${user.userId}');
    } catch (e) {
      LoggerService.error('AuthService', 'createUserProfile', 'Failed to create user profile: $e');
      rethrow;
    }
  }

  // Get user profile
  static Future<UserModel?> getUserProfile(String userId) async {
    try {
      LoggerService.log('AuthService', 'getUserProfile', 'Fetching user profile for: $userId');
      
      DocumentSnapshot doc = await FirebaseService.userDocument(userId).get();
      
      if (doc.exists) {
        UserModel user = UserModel.fromJson(doc.data() as Map<String, dynamic>);
        LoggerService.success('AuthService', 'getUserProfile', 'User profile fetched successfully');
        return user;
      } else {
        LoggerService.warning('AuthService', 'getUserProfile', 'User profile not found for: $userId');
        return null;
      }
    } catch (e) {
      LoggerService.error('AuthService', 'getUserProfile', 'Failed to fetch user profile: $e');
      return null;
    }
  }

  // Update user profile
  static Future<void> updateUserProfile(String userId, Map<String, dynamic> updates) async {
    try {
      LoggerService.log('AuthService', 'updateUserProfile', 'Updating user profile for: $userId');
      
      updates['lastActive'] = FieldValue.serverTimestamp();
      await FirebaseService.userDocument(userId).update(updates);
      
      LoggerService.success('AuthService', 'updateUserProfile', 'User profile updated successfully');
    } catch (e) {
      LoggerService.error('AuthService', 'updateUserProfile', 'Failed to update user profile: $e');
      rethrow;
    }
  }

  // Update last active timestamp
  static Future<void> updateLastActive() async {
    if (currentUserId == null) return;
    
    try {
      await FirebaseService.userDocument(currentUserId!)
          .update({'lastActive': FieldValue.serverTimestamp()});
    } catch (e) {
      LoggerService.error('AuthService', 'updateLastActive', 'Failed to update last active: $e');
    }
  }

  // Check if user exists
  static Future<bool> userExists(String userId) async {
    try {
      DocumentSnapshot doc = await FirebaseService.userDocument(userId).get();
      return doc.exists;
    } catch (e) {
      LoggerService.error('AuthService', 'userExists', 'Failed to check user existence: $e');
      return false;
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      LoggerService.log('AuthService', 'signOut', 'User signing out');
      
      await _auth.signOut();
      
      LoggerService.success('AuthService', 'signOut', 'User signed out successfully');
    } catch (e) {
      LoggerService.error('AuthService', 'signOut', 'Sign out failed: $e');
      rethrow;
    }
  }

  // Delete user account
  static Future<void> deleteAccount() async {
    try {
      if (currentUser == null) throw Exception('No user signed in');
      
      LoggerService.log('AuthService', 'deleteAccount', 'Deleting user account: ${currentUser!.uid}');
      
      // Delete user data from Firestore
      await FirebaseService.userDocument(currentUser!.uid).delete();
      
      // Delete Firebase Auth account
      await currentUser!.delete();
      
      LoggerService.success('AuthService', 'deleteAccount', 'User account deleted successfully');
    } catch (e) {
      LoggerService.error('AuthService', 'deleteAccount', 'Failed to delete account: $e');
      rethrow;
    }
  }

  // Re-authenticate user (required for sensitive operations)
  static Future<void> reauthenticateWithPhoneCredential(PhoneAuthCredential credential) async {
    try {
      if (currentUser == null) throw Exception('No user signed in');
      
      LoggerService.log('AuthService', 'reauthenticateWithPhoneCredential', 'Re-authenticating user');
      
      await currentUser!.reauthenticateWithCredential(credential);
      
      LoggerService.success('AuthService', 'reauthenticateWithPhoneCredential', 'Re-authentication successful');
    } catch (e) {
      LoggerService.error('AuthService', 'reauthenticateWithPhoneCredential', 'Re-authentication failed: $e');
      rethrow;
    }
  }

  // Get current user stream
  static Stream<UserModel?> getCurrentUserStream() {
    if (currentUserId == null) {
      return Stream.value(null);
    }
    
    return FirebaseService.userDocument(currentUserId!)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  // Check premium status
  static Future<bool> isPremiumUser(String userId) async {
    try {
      UserModel? user = await getUserProfile(userId);
      if (user == null) return false;
      
      if (!user.isPremium) return false;
      
      // Check if premium has expired
      if (user.premiumExpiry != null && user.premiumExpiry!.isBefore(DateTime.now())) {
        // Premium expired, update user
        await updateUserProfile(userId, {
          'isPremium': false,
          'premiumExpiry': null,
        });
        return false;
      }
      
      return true;
    } catch (e) {
      LoggerService.error('AuthService', 'isPremiumUser', 'Failed to check premium status: $e');
      return false;
    }
  }

  // Update premium status
  static Future<void> updatePremiumStatus(String userId, bool isPremium, [DateTime? expiryDate]) async {
    try {
      Map<String, dynamic> updates = {
        'isPremium': isPremium,
        'premiumExpiry': expiryDate,
      };
      
      await updateUserProfile(userId, updates);
      
      LoggerService.success('AuthService', 'updatePremiumStatus', 
          'Premium status updated for user: $userId');
    } catch (e) {
      LoggerService.error('AuthService', 'updatePremiumStatus', 'Failed to update premium status: $e');
      rethrow;
    }
  }
}