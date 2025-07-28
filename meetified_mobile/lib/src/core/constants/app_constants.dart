class AppConstants {
  // App Information
  static const String appName = 'Meetified';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'AI-powered dating app';
  
  // API Configuration
  static const String openAIBaseUrl = 'https://api.openai.com/v1';
  static const String gptModel = 'gpt-3.5-turbo';
  static const int maxTokens = 500;
  static const double temperature = 0.7;
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String profilesCollection = 'profiles';
  static const String matchesCollection = 'matches';
  static const String chatsCollection = 'chats';
  static const String messagesCollection = 'messages';
  static const String transactionsCollection = 'transactions';
  
  // Storage Keys
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String onboardingKey = 'onboarding_completed';
  static const String premiumKey = 'premium_status';
  
  // UPI Configuration
  static const String upiId = 'meetified@test'; // Development UPI ID
  static const String merchantName = 'Meetified';
  static const double premiumPrice = 99.0;
  
  // AI Configuration
  static const int contextTokenLimit = 4000;
  static const int maxConversationHistory = 50;
  
  // Match Configuration
  static const int dailyMatchLimit = 5;
  static const int maxActiveMatches = 10;
  static const double minCompatibilityScore = 0.6;
  
  // Chat Configuration
  static const int maxMessageLength = 500;
  static const int maxQuestionsPerUser = 5;
  
  // UI Configuration
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;
  
  // Animation Durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  
  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration messageTimeout = Duration(seconds: 15);
  
  // Age Configuration
  static const int minAge = 18;
  static const int maxAge = 65;
  static const int defaultMinAge = 25;
  static const int defaultMaxAge = 35;
  
  // Location Configuration
  static const double defaultLocationRadius = 50.0; // km
  static const double maxLocationRadius = 200.0; // km
}