import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/chat_model.dart';
import '../models/profile_model.dart';
import 'logger_service.dart';

class OpenAIService {
  static late String _apiKey;
  static const String _baseUrl = AppConstants.openAIBaseUrl;
  static const String _model = AppConstants.gptModel;

  static void initialize(String apiKey) {
    _apiKey = apiKey;
    LoggerService.log('OpenAIService', 'initialize', 'OpenAI service initialized');
  }

  // Generate AI response for profile building
  static Future<String> generateProfileResponse(
    String userId,
    String userMessage,
    ConversationContext context,
  ) async {
    try {
      LoggerService.aiInteraction('OpenAIService', 'generateProfileResponse', userId, context.tokenCount);

      String prompt = _buildProfileBuildingPrompt(userMessage, context);
      
      Map<String, dynamic> response = await _makeOpenAIRequest(prompt);
      String aiResponse = response['choices'][0]['message']['content'] as String;

      LoggerService.success('OpenAIService', 'generateProfileResponse', 'AI response generated successfully');
      return aiResponse;
    } catch (e) {
      LoggerService.error('OpenAIService', 'generateProfileResponse', 'Failed to generate response: $e');
      return _getFallbackResponse(userMessage);
    }
  }

  // Generate questions for potential partners
  static Future<List<String>> generateQuestions(
    String userId,
    ProfileModel userProfile,
    ProfileModel partnerProfile,
  ) async {
    try {
      LoggerService.log('OpenAIService', 'generateQuestions', 'Generating questions for user: $userId');

      String prompt = _buildQuestionGenerationPrompt(userProfile, partnerProfile);
      
      Map<String, dynamic> response = await _makeOpenAIRequest(prompt);
      String aiResponse = response['choices'][0]['message']['content'] as String;

      List<String> questions = _parseQuestionsFromResponse(aiResponse);
      
      LoggerService.success('OpenAIService', 'generateQuestions', 'Generated ${questions.length} questions');
      return questions;
    } catch (e) {
      LoggerService.error('OpenAIService', 'generateQuestions', 'Failed to generate questions: $e');
      return _getFallbackQuestions();
    }
  }

  // Refine user questions to be more conversational
  static Future<List<String>> refineQuestions(List<String> rawQuestions) async {
    try {
      LoggerService.log('OpenAIService', 'refineQuestions', 'Refining ${rawQuestions.length} questions');

      String prompt = _buildQuestionRefinementPrompt(rawQuestions);
      
      Map<String, dynamic> response = await _makeOpenAIRequest(prompt);
      String aiResponse = response['choices'][0]['message']['content'] as String;

      List<String> refinedQuestions = _parseQuestionsFromResponse(aiResponse);
      
      LoggerService.success('OpenAIService', 'refineQuestions', 'Refined questions successfully');
      return refinedQuestions.isNotEmpty ? refinedQuestions : rawQuestions;
    } catch (e) {
      LoggerService.error('OpenAIService', 'refineQuestions', 'Failed to refine questions: $e');
      return rawQuestions; // Return original questions if refinement fails
    }
  }

  // Extract profile data from conversation
  static Future<Map<String, dynamic>> extractProfileData(
    String userId,
    List<MessageModel> conversationHistory,
  ) async {
    try {
      LoggerService.log('OpenAIService', 'extractProfileData', 'Extracting profile data for user: $userId');

      String prompt = _buildProfileExtractionPrompt(conversationHistory);
      
      Map<String, dynamic> response = await _makeOpenAIRequest(prompt);
      String aiResponse = response['choices'][0]['message']['content'] as String;

      Map<String, dynamic> profileData = _parseProfileDataFromResponse(aiResponse);
      
      LoggerService.success('OpenAIService', 'extractProfileData', 'Profile data extracted successfully');
      return profileData;
    } catch (e) {
      LoggerService.error('OpenAIService', 'extractProfileData', 'Failed to extract profile data: $e');
      return {};
    }
  }

  // Generate emoji suggestions
  static Future<List<String>> suggestEmojis(String message) async {
    try {
      LoggerService.log('OpenAIService', 'suggestEmojis', 'Generating emoji suggestions');

      String prompt = _buildEmojiSuggestionPrompt(message);
      
      Map<String, dynamic> response = await _makeOpenAIRequest(prompt);
      String aiResponse = response['choices'][0]['message']['content'] as String;

      List<String> emojis = _parseEmojisFromResponse(aiResponse);
      
      LoggerService.success('OpenAIService', 'suggestEmojis', 'Generated ${emojis.length} emoji suggestions');
      return emojis;
    } catch (e) {
      LoggerService.error('OpenAIService', 'suggestEmojis', 'Failed to suggest emojis: $e');
      return ['😊', '👍', '❤️']; // Fallback emojis
    }
  }

  // Generate AI reaction to user message
  static Future<String> generateAIReaction(String userMessage) async {
    try {
      LoggerService.log('OpenAIService', 'generateAIReaction', 'Generating AI reaction');

      String prompt = _buildAIReactionPrompt(userMessage);
      
      Map<String, dynamic> response = await _makeOpenAIRequest(prompt);
      String aiResponse = response['choices'][0]['message']['content'] as String;

      LoggerService.success('OpenAIService', 'generateAIReaction', 'AI reaction generated');
      return aiResponse.trim();
    } catch (e) {
      LoggerService.error('OpenAIService', 'generateAIReaction', 'Failed to generate reaction: $e');
      return 'That\'s interesting!';
    }
  }

  // Calculate token count for a message
  static int calculateTokenCount(String text) {
    // Rough estimation: 1 token ≈ 4 characters for English text
    return (text.length / 4).ceil();
  }

  // Private helper methods

  static Future<Map<String, dynamic>> _makeOpenAIRequest(String prompt) async {
    LoggerService.apiCall('OpenAIService', '_makeOpenAIRequest', '$_baseUrl/chat/completions');

    final response = await http.post(
      Uri.parse('$_baseUrl/chat/completions'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': _model,
        'messages': [
          {
            'role': 'system',
            'content': 'You are a helpful AI assistant for a dating app. Be friendly, engaging, and natural in your responses.',
          },
          {
            'role': 'user',
            'content': prompt,
          }
        ],
        'max_tokens': AppConstants.maxTokens,
        'temperature': AppConstants.temperature,
      }),
    ).timeout(AppConstants.apiTimeout);

    LoggerService.apiResponse('OpenAIService', '_makeOpenAIRequest', 
        '$_baseUrl/chat/completions', response.statusCode);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw HttpException('OpenAI API error: ${response.statusCode} - ${response.body}');
    }
  }

  static String _buildProfileBuildingPrompt(String userMessage, ConversationContext context) {
    return '''
You are an AI assistant helping users build their dating profile through natural conversation.

User's message: "$userMessage"

Previous conversation context:
${context.conversationHistory.map((msg) => "${msg.senderId}: ${msg.content}").join('\n')}

Instructions:
1. Respond naturally and conversationally
2. Ask follow-up questions to learn more about the user
3. Focus on interests, values, lifestyle, and personality
4. Keep responses friendly and engaging
5. Don't be too formal or robotic
6. Limit response to 2-3 sentences

Generate a natural, friendly response that continues the conversation and helps build their profile.
''';
  }

  static String _buildQuestionGenerationPrompt(ProfileModel userProfile, ProfileModel partnerProfile) {
    return '''
Generate 3-5 thoughtful questions that a user would want to ask their potential match to better understand compatibility.

User's interests: ${userProfile.presented.interests.join(', ')}
User's values: ${userProfile.presented.values.join(', ')}
User's occupation: ${userProfile.presented.occupation}

Potential match's interests: ${partnerProfile.presented.interests.join(', ')}
Potential match's values: ${partnerProfile.presented.values.join(', ')}
Potential match's occupation: ${partnerProfile.presented.occupation}

Generate questions that:
1. Are specific and thoughtful
2. Help understand compatibility
3. Are conversational and natural
4. Focus on values, lifestyle, and relationship goals
5. Are appropriate for a dating context

Format: Return only the questions, one per line, numbered 1-5.
''';
  }

  static String _buildQuestionRefinementPrompt(List<String> rawQuestions) {
    return '''
Refine these questions to be more conversational and engaging, as if the AI is genuinely curious about the user:

${rawQuestions.map((q) => "- $q").join('\n')}

Make them:
1. Sound natural and friendly
2. More conversational (less formal)
3. Show genuine curiosity
4. Appropriate for a dating context
5. Easy to answer

Format: Return only the refined questions, one per line, numbered 1-${rawQuestions.length}.
''';
  }

  static String _buildProfileExtractionPrompt(List<MessageModel> conversationHistory) {
    String conversation = conversationHistory
        .map((msg) => "${msg.senderId}: ${msg.content}")
        .join('\n');

    return '''
Extract profile information from this conversation:

$conversation

Extract and return a JSON object with the following structure:
{
  "interests": ["interest1", "interest2"],
  "values": ["value1", "value2"],
  "personality_traits": {
    "openness": 0.7,
    "conscientiousness": 0.8,
    "extraversion": 0.6,
    "agreeableness": 0.9,
    "neuroticism": 0.3
  },
  "communication_style": "friendly|formal|casual|humorous",
  "relationship_goals": "serious|casual|friendship|marriage",
  "lifestyle_preferences": {
    "social_level": "high|medium|low",
    "activity_level": "high|medium|low",
    "travel_interest": "high|medium|low"
  }
}

Only extract information that is clearly mentioned or can be reasonably inferred. Use null for missing information.
''';
  }

  static String _buildEmojiSuggestionPrompt(String message) {
    return '''
Suggest 3-5 appropriate emojis for this message: "$message"

Return only the emojis separated by spaces, no other text.
Example format: 😊 👍 ❤️ 🎉 😄
''';
  }

  static String _buildAIReactionPrompt(String userMessage) {
    return '''
Generate a brief, friendly AI reaction to this user message: "$userMessage"

The reaction should be:
1. 1-2 words maximum
2. Friendly and encouraging
3. Appropriate for a dating app context
4. Natural and conversational

Examples: "That's cool!", "Interesting!", "Nice!", "Awesome!", "Great choice!"
''';
  }

  static List<String> _parseQuestionsFromResponse(String response) {
    List<String> questions = [];
    List<String> lines = response.split('\n');
    
    for (String line in lines) {
      line = line.trim();
      if (line.isNotEmpty) {
        // Remove numbering if present
        if (RegExp(r'^\d+\.?\s*').hasMatch(line)) {
          line = line.replaceFirst(RegExp(r'^\d+\.?\s*'), '');
        }
        // Remove bullet points if present
        if (line.startsWith('- ')) {
          line = line.substring(2);
        }
        if (line.isNotEmpty) {
          questions.add(line);
        }
      }
    }
    
    return questions.take(5).toList(); // Limit to 5 questions
  }

  static Map<String, dynamic> _parseProfileDataFromResponse(String response) {
    try {
      // Try to parse as JSON
      return jsonDecode(response) as Map<String, dynamic>;
    } catch (e) {
      LoggerService.warning('OpenAIService', '_parseProfileDataFromResponse', 
          'Failed to parse JSON response: $e');
      return {};
    }
  }

  static List<String> _parseEmojisFromResponse(String response) {
    List<String> emojis = [];
    
    // Split by spaces and filter emoji characters
    List<String> parts = response.split(' ');
    for (String part in parts) {
      part = part.trim();
      if (part.isNotEmpty && _isEmoji(part)) {
        emojis.add(part);
      }
    }
    
    return emojis.take(5).toList(); // Limit to 5 emojis
  }

  static bool _isEmoji(String text) {
    // Simple emoji detection (this is basic, could be improved)
    RegExp emojiRegex = RegExp(
      r'[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{1F1E0}-\u{1F1FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]',
      unicode: true,
    );
    return emojiRegex.hasMatch(text);
  }

  static String _getFallbackResponse(String userMessage) {
    List<String> fallbackResponses = [
      "That's really interesting! Tell me more about that.",
      "I'd love to hear more about your thoughts on this.",
      "That sounds great! What else would you like to share?",
      "Thanks for sharing that with me. What else interests you?",
      "That's fascinating! I'm learning so much about you.",
    ];
    
    return fallbackResponses[DateTime.now().millisecond % fallbackResponses.length];
  }

  static List<String> _getFallbackQuestions() {
    return [
      "What do you value most in a relationship?",
      "How do you like to spend your free time?",
      "What are your thoughts on work-life balance?",
      "What kind of adventures do you enjoy?",
      "What's important to you in a life partner?",
    ];
  }
}