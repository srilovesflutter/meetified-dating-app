import 'package:uuid/uuid.dart';
import '../models/chat_model.dart';
import '../models/profile_model.dart';
import '../models/user_model.dart';
import '../constants/app_constants.dart';
import 'openai_service.dart';
import 'firebase_service.dart';
import 'logger_service.dart';

class AIChatService {
  static const String _aiUserId = 'ai_assistant';
  static final Uuid _uuid = const Uuid();

  // Start AI chat session for profile building
  static Future<ConversationContext> startProfileBuildingSession(String userId) async {
    try {
      LoggerService.log('AIChatService', 'startProfileBuildingSession', 'Starting session for user: $userId');

      ConversationContext context = ConversationContext(
        sessionId: _uuid.v4(),
        userId: userId,
        conversationHistory: [],
        userProfile: {},
        aiPersonality: const AIPersonality(
          gender: 'neutral',
          tone: 'friendly',
          context: 'profile_building',
        ),
        memory: const ContextMemory(
          keyInsights: [],
          importantTopics: [],
          userPreferences: {},
        ),
        tokenCount: 0,
        lastUpdated: DateTime.now(),
      );

      // Send initial greeting
      String initialMessage = _getInitialGreeting();
      await _addMessageToContext(context, _aiUserId, initialMessage, MessageType.text);

      LoggerService.success('AIChatService', 'startProfileBuildingSession', 'Session started successfully');
      return context;
    } catch (e) {
      LoggerService.error('AIChatService', 'startProfileBuildingSession', 'Failed to start session: $e');
      rethrow;
    }
  }

  // Process user message and generate AI response
  static Future<String> processUserMessage(
    String userId,
    String userMessage,
    ConversationContext context,
  ) async {
    try {
      LoggerService.log('AIChatService', 'processUserMessage', 'Processing message from user: $userId');

      // Add user message to context
      await _addMessageToContext(context, userId, userMessage, MessageType.text);

      // Check if context needs pruning
      if (context.tokenCount > AppConstants.contextTokenLimit) {
        context = await _pruneContext(context);
      }

      // Generate AI response
      String aiResponse = await OpenAIService.generateProfileResponse(userId, userMessage, context);

      // Add AI response to context
      await _addMessageToContext(context, _aiUserId, aiResponse, MessageType.text);

      // Save context to Firebase
      await _saveContext(context);

      // Extract and update profile data
      await _updateProfileFromConversation(userId, context);

      LoggerService.success('AIChatService', 'processUserMessage', 'Message processed successfully');
      return aiResponse;
    } catch (e) {
      LoggerService.error('AIChatService', 'processUserMessage', 'Failed to process message: $e');
      return _getFallbackResponse();
    }
  }

  // Start question exchange between users
  static Future<void> initiateQuestionExchange(String userId, String partnerUserId) async {
    try {
      LoggerService.log('AIChatService', 'initiateQuestionExchange', 
          'Initiating question exchange between $userId and $partnerUserId');

      // Get user profiles
      ProfileModel? userProfile = await _getUserProfile(userId);
      ProfileModel? partnerProfile = await _getUserProfile(partnerUserId);

      if (userProfile == null || partnerProfile == null) {
        throw Exception('User profiles not found');
      }

      // Generate questions for partner
      List<String> questions = await OpenAIService.generateQuestions(
        userId,
        userProfile,
        partnerProfile,
      );

      // Send questions to partner as AI messages
      await _sendQuestionsToUser(partnerUserId, userId, questions);

      LoggerService.success('AIChatService', 'initiateQuestionExchange', 'Question exchange initiated');
    } catch (e) {
      LoggerService.error('AIChatService', 'initiateQuestionExchange', 'Failed to initiate exchange: $e');
      rethrow;
    }
  }

  // Handle user questions and send them anonymously
  static Future<void> handleUserQuestionRequest(
    String userId,
    String otherUserId,
    List<String> userQuestions,
  ) async {
    try {
      LoggerService.log('AIChatService', 'handleUserQuestionRequest', 
          'Handling question request from $userId to $otherUserId');

      // Refine questions to be more conversational
      List<String> refinedQuestions = await OpenAIService.refineQuestions(userQuestions);

      // Send refined questions to the other user
      await _sendQuestionsToUser(otherUserId, userId, refinedQuestions);

      LoggerService.success('AIChatService', 'handleUserQuestionRequest', 'Questions sent successfully');
    } catch (e) {
      LoggerService.error('AIChatService', 'handleUserQuestionRequest', 'Failed to handle request: $e');
      rethrow;
    }
  }

  // Generate AI emoji suggestions
  static Future<List<String>> getEmojiSuggestions(String message) async {
    try {
      return await OpenAIService.suggestEmojis(message);
    } catch (e) {
      LoggerService.error('AIChatService', 'getEmojiSuggestions', 'Failed to get suggestions: $e');
      return ['😊', '👍', '❤️'];
    }
  }

  // Generate AI reaction to message
  static Future<String> generateReaction(String message) async {
    try {
      return await OpenAIService.generateAIReaction(message);
    } catch (e) {
      LoggerService.error('AIChatService', 'generateReaction', 'Failed to generate reaction: $e');
      return 'That\'s interesting!';
    }
  }

  // Get conversation context for user
  static Future<ConversationContext?> getConversationContext(String userId) async {
    try {
      LoggerService.log('AIChatService', 'getConversationContext', 'Getting context for user: $userId');

      var doc = await FirebaseService.firestore
          .collection('ai_contexts')
          .doc(userId)
          .get();

      if (doc.exists) {
        return ConversationContext.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      LoggerService.error('AIChatService', 'getConversationContext', 'Failed to get context: $e');
      return null;
    }
  }

  // Check if profile building is complete
  static Future<bool> isProfileBuildingComplete(String userId) async {
    try {
      ProfileModel? profile = await _getUserProfile(userId);
      if (profile == null) return false;

      // Check if essential profile data is present
      bool hasBasicInfo = profile.presented.name.isNotEmpty &&
          profile.presented.age > 0 &&
          profile.presented.location.isNotEmpty &&
          profile.presented.occupation.isNotEmpty &&
          profile.presented.bio.isNotEmpty;

      bool hasInterests = profile.presented.interests.length >= 3;
      bool hasValues = profile.presented.values.length >= 2;

      return hasBasicInfo && hasInterests && hasValues;
    } catch (e) {
      LoggerService.error('AIChatService', 'isProfileBuildingComplete', 'Failed to check completion: $e');
      return false;
    }
  }

  // Private helper methods

  static Future<void> _addMessageToContext(
    ConversationContext context,
    String senderId,
    String content,
    MessageType messageType,
  ) async {
    MessageModel message = MessageModel(
      messageId: _uuid.v4(),
      senderId: senderId,
      content: content,
      timestamp: DateTime.now(),
      messageType: messageType,
      emojis: [],
      isRead: false,
    );

    context.conversationHistory.add(message);
    context.tokenCount += OpenAIService.calculateTokenCount(content);
  }

  static Future<ConversationContext> _pruneContext(ConversationContext context) async {
    LoggerService.log('AIChatService', '_pruneContext', 'Pruning context for token limit');

    // Keep the most recent messages and important context
    List<MessageModel> recentMessages = context.conversationHistory.reversed.take(20).toList().reversed.toList();
    
    // Calculate new token count
    int newTokenCount = 0;
    for (MessageModel message in recentMessages) {
      newTokenCount += OpenAIService.calculateTokenCount(message.content);
    }

    return context.copyWith(
      conversationHistory: recentMessages,
      tokenCount: newTokenCount,
      lastUpdated: DateTime.now(),
    );
  }

  static Future<void> _saveContext(ConversationContext context) async {
    try {
      await FirebaseService.firestore
          .collection('ai_contexts')
          .doc(context.userId)
          .set(context.toJson());
    } catch (e) {
      LoggerService.error('AIChatService', '_saveContext', 'Failed to save context: $e');
    }
  }

  static Future<void> _updateProfileFromConversation(String userId, ConversationContext context) async {
    try {
      if (context.conversationHistory.length < 5) return; // Wait for more conversation

      Map<String, dynamic> extractedData = await OpenAIService.extractProfileData(
        userId,
        context.conversationHistory,
      );

      if (extractedData.isNotEmpty) {
        await FirebaseService.profileDocument(userId).update({
          'derived': extractedData,
          'lastUpdated': FirebaseService.serverTimestamp,
        });

        LoggerService.success('AIChatService', '_updateProfileFromConversation', 
            'Profile updated with extracted data');
      }
    } catch (e) {
      LoggerService.error('AIChatService', '_updateProfileFromConversation', 
          'Failed to update profile: $e');
    }
  }

  static Future<ProfileModel?> _getUserProfile(String userId) async {
    try {
      var doc = await FirebaseService.profileDocument(userId).get();
      if (doc.exists) {
        return ProfileModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      LoggerService.error('AIChatService', '_getUserProfile', 'Failed to get profile: $e');
      return null;
    }
  }

  static Future<void> _sendQuestionsToUser(
    String targetUserId,
    String fromUserId,
    List<String> questions,
  ) async {
    try {
      ConversationContext? context = await getConversationContext(targetUserId);
      
      if (context == null) {
        context = await startProfileBuildingSession(targetUserId);
      }

      // Send introduction message
      String introMessage = "I'd like to know more about you before we make a match. Could you help me understand you better?";
      await _addMessageToContext(context, _aiUserId, introMessage, MessageType.question);

      // Send each question
      for (String question in questions) {
        String conversationalQuestion = "Also, $question";
        await _addMessageToContext(context, _aiUserId, conversationalQuestion, MessageType.question);
      }

      // Save updated context
      await _saveContext(context);

      LoggerService.success('AIChatService', '_sendQuestionsToUser', 
          'Sent ${questions.length} questions to user: $targetUserId');
    } catch (e) {
      LoggerService.error('AIChatService', '_sendQuestionsToUser', 'Failed to send questions: $e');
      rethrow;
    }
  }

  static String _getInitialGreeting() {
    List<String> greetings = [
      "Hi there! I'm here to help you create an amazing profile. Let's start by getting to know you better. What are some things you're passionate about?",
      "Hello! I'm excited to help you build your profile. To start, could you tell me about your hobbies and interests?",
      "Welcome! I'm your AI assistant, and I'll help you create a profile that truly represents you. What do you love doing in your free time?",
      "Hi! I'm here to help you showcase the best version of yourself. Let's begin - what are some activities that make you happy?",
    ];
    
    return greetings[DateTime.now().millisecond % greetings.length];
  }

  static String _getFallbackResponse() {
    List<String> fallbackResponses = [
      "I'm sorry, I didn't quite catch that. Could you tell me more?",
      "That's interesting! I'd love to hear more about your thoughts.",
      "Thanks for sharing! What else would you like to tell me about yourself?",
      "I'm learning so much about you! What other interests do you have?",
    ];
    
    return fallbackResponses[DateTime.now().millisecond % fallbackResponses.length];
  }
}