import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../constants/app_constants.dart';
import 'logger_service.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Auth getters
  static FirebaseAuth get auth => _auth;
  static User? get currentUser => _auth.currentUser;
  static String? get currentUserId => _auth.currentUser?.uid;
  
  // Firestore getters
  static FirebaseFirestore get firestore => _firestore;
  static FirebaseStorage get storage => _storage;
  static FirebaseMessaging get messaging => _messaging;
  
  // Collection references
  static CollectionReference get usersCollection => 
      _firestore.collection(AppConstants.usersCollection);
  
  static CollectionReference get profilesCollection => 
      _firestore.collection(AppConstants.profilesCollection);
  
  static CollectionReference get matchesCollection => 
      _firestore.collection(AppConstants.matchesCollection);
  
  static CollectionReference get chatsCollection => 
      _firestore.collection(AppConstants.chatsCollection);
  
  static CollectionReference get transactionsCollection => 
      _firestore.collection(AppConstants.transactionsCollection);

  // Initialize Firebase services
  static Future<void> initialize() async {
    try {
      LoggerService.log('FirebaseService', 'initialize', 'Initializing Firebase services');
      
      // Request notification permissions
      await requestNotificationPermissions();
      
      // Setup message handlers
      setupMessageHandlers();
      
      LoggerService.success('FirebaseService', 'initialize', 'Firebase services initialized');
    } catch (e) {
      LoggerService.error('FirebaseService', 'initialize', 'Failed to initialize: $e');
      rethrow;
    }
  }

  // Notification permissions
  static Future<void> requestNotificationPermissions() async {
    try {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      LoggerService.log('FirebaseService', 'requestNotificationPermissions', 
          'Permission status: ${settings.authorizationStatus}');
    } catch (e) {
      LoggerService.error('FirebaseService', 'requestNotificationPermissions', 
          'Failed to request permissions: $e');
    }
  }

  // Message handlers
  static void setupMessageHandlers() {
    try {
      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        LoggerService.log('FirebaseService', 'onMessage', 
            'Received foreground message: ${message.notification?.title}');
        // Handle foreground notification
      });

      // Handle background message tap
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        LoggerService.log('FirebaseService', 'onMessageOpenedApp', 
            'App opened from notification: ${message.notification?.title}');
        // Handle notification tap
      });

      LoggerService.success('FirebaseService', 'setupMessageHandlers', 
          'Message handlers setup complete');
    } catch (e) {
      LoggerService.error('FirebaseService', 'setupMessageHandlers', 
          'Failed to setup handlers: $e');
    }
  }

  // Get FCM token
  static Future<String?> getFCMToken() async {
    try {
      String? token = await _messaging.getToken();
      LoggerService.log('FirebaseService', 'getFCMToken', 'FCM token retrieved');
      return token;
    } catch (e) {
      LoggerService.error('FirebaseService', 'getFCMToken', 'Failed to get token: $e');
      return null;
    }
  }

  // Document reference helpers
  static DocumentReference userDocument(String userId) {
    return usersCollection.doc(userId);
  }

  static DocumentReference profileDocument(String userId) {
    return profilesCollection.doc(userId);
  }

  static DocumentReference matchDocument(String matchId) {
    return matchesCollection.doc(matchId);
  }

  static DocumentReference chatDocument(String chatId) {
    return chatsCollection.doc(chatId);
  }

  static DocumentReference transactionDocument(String transactionId) {
    return transactionsCollection.doc(transactionId);
  }

  // Batch operations
  static WriteBatch createBatch() {
    return _firestore.batch();
  }

  // Transaction operations
  static Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) updateFunction,
  ) async {
    return await _firestore.runTransaction(updateFunction);
  }

  // Server timestamp
  static FieldValue get serverTimestamp => FieldValue.serverTimestamp();

  // Array operations
  static FieldValue arrayUnion(List<dynamic> elements) {
    return FieldValue.arrayUnion(elements);
  }

  static FieldValue arrayRemove(List<dynamic> elements) {
    return FieldValue.arrayRemove(elements);
  }

  // Increment
  static FieldValue increment(num value) {
    return FieldValue.increment(value);
  }
}