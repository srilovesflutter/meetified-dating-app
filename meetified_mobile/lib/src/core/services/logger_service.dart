import 'package:logger/logger.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class LoggerService {
  static late Logger _logger;
  
  static void initialize() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
    );
  }
  
  static void log(String className, String methodName, String message) {
    _logger.i('$className.$methodName: $message');
  }
  
  static void debug(String className, String methodName, String message) {
    _logger.d('$className.$methodName: $message');
  }
  
  static void warning(String className, String methodName, String message) {
    _logger.w('$className.$methodName: $message');
  }
  
  static void error(String className, String methodName, String error, [StackTrace? stackTrace]) {
    _logger.e('$className.$methodName: $error', stackTrace: stackTrace);
    
    // Report to Crashlytics
    FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
      information: ['Class: $className', 'Method: $methodName'],
    );
  }
  
  static void success(String className, String methodName, String message) {
    _logger.i('✅ $className.$methodName: $message');
  }
  
  static void apiCall(String className, String methodName, String endpoint) {
    _logger.i('🌐 $className.$methodName: API call to $endpoint');
  }
  
  static void apiResponse(String className, String methodName, String endpoint, int statusCode) {
    _logger.i('📥 $className.$methodName: API response from $endpoint - Status: $statusCode');
  }
  
  static void userAction(String className, String methodName, String action) {
    _logger.i('👤 $className.$methodName: User action - $action');
  }
  
  static void payment(String className, String methodName, String transactionId, double amount) {
    _logger.i('💳 $className.$methodName: Payment - Transaction: $transactionId, Amount: ₹$amount');
  }
  
  static void match(String className, String methodName, String matchId, double compatibilityScore) {
    _logger.i('💕 $className.$methodName: Match created - ID: $matchId, Score: $compatibilityScore');
  }
  
  static void aiInteraction(String className, String methodName, String userId, int tokenCount) {
    _logger.i('🤖 $className.$methodName: AI interaction - User: $userId, Tokens: $tokenCount');
  }
}