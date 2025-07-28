import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum MessageType {
  text,
  emoji,
  question,
  answer,
  system,
  aiReaction
}

class ChatModel extends Equatable {
  final String chatId;
  final String matchId;
  final List<MessageModel> messages;
  final bool isAnonymous;
  final bool identityRevealed;
  final DateTime lastMessage;

  const ChatModel({
    required this.chatId,
    required this.matchId,
    required this.messages,
    required this.isAnonymous,
    required this.identityRevealed,
    required this.lastMessage,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      chatId: json['chatId'] as String,
      matchId: json['matchId'] as String,
      messages: (json['messages'] as List)
          .map((messageJson) => MessageModel.fromJson(messageJson as Map<String, dynamic>))
          .toList(),
      isAnonymous: json['isAnonymous'] as bool,
      identityRevealed: json['identityRevealed'] as bool,
      lastMessage: (json['lastMessage'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'matchId': matchId,
      'messages': messages.map((message) => message.toJson()).toList(),
      'isAnonymous': isAnonymous,
      'identityRevealed': identityRevealed,
      'lastMessage': Timestamp.fromDate(lastMessage),
    };
  }

  ChatModel copyWith({
    String? chatId,
    String? matchId,
    List<MessageModel>? messages,
    bool? isAnonymous,
    bool? identityRevealed,
    DateTime? lastMessage,
  }) {
    return ChatModel(
      chatId: chatId ?? this.chatId,
      matchId: matchId ?? this.matchId,
      messages: messages ?? this.messages,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      identityRevealed: identityRevealed ?? this.identityRevealed,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }

  @override
  List<Object?> get props => [chatId, matchId, messages, isAnonymous, identityRevealed, lastMessage];
}

class MessageModel extends Equatable {
  final String messageId;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final MessageType messageType;
  final List<String> emojis;
  final String? aiReaction;
  final bool isRead;

  const MessageModel({
    required this.messageId,
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.messageType,
    required this.emojis,
    this.aiReaction,
    required this.isRead,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      messageId: json['messageId'] as String,
      senderId: json['senderId'] as String,
      content: json['content'] as String,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      messageType: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == json['messageType'],
        orElse: () => MessageType.text,
      ),
      emojis: List<String>.from(json['emojis'] as List? ?? []),
      aiReaction: json['aiReaction'] as String?,
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'messageType': messageType.toString().split('.').last,
      'emojis': emojis,
      'aiReaction': aiReaction,
      'isRead': isRead,
    };
  }

  MessageModel copyWith({
    String? messageId,
    String? senderId,
    String? content,
    DateTime? timestamp,
    MessageType? messageType,
    List<String>? emojis,
    String? aiReaction,
    bool? isRead,
  }) {
    return MessageModel(
      messageId: messageId ?? this.messageId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      messageType: messageType ?? this.messageType,
      emojis: emojis ?? this.emojis,
      aiReaction: aiReaction ?? this.aiReaction,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  List<Object?> get props => [
        messageId,
        senderId,
        content,
        timestamp,
        messageType,
        emojis,
        aiReaction,
        isRead,
      ];
}

class ConversationContext extends Equatable {
  final String sessionId;
  final String userId;
  final List<MessageModel> conversationHistory;
  final Map<String, dynamic> userProfile;
  final AIPersonality aiPersonality;
  final ContextMemory memory;
  final int tokenCount;
  final DateTime lastUpdated;

  const ConversationContext({
    required this.sessionId,
    required this.userId,
    required this.conversationHistory,
    required this.userProfile,
    required this.aiPersonality,
    required this.memory,
    required this.tokenCount,
    required this.lastUpdated,
  });

  factory ConversationContext.fromJson(Map<String, dynamic> json) {
    return ConversationContext(
      sessionId: json['sessionId'] as String,
      userId: json['userId'] as String,
      conversationHistory: (json['conversationHistory'] as List)
          .map((messageJson) => MessageModel.fromJson(messageJson as Map<String, dynamic>))
          .toList(),
      userProfile: Map<String, dynamic>.from(json['userProfile'] as Map),
      aiPersonality: AIPersonality.fromJson(json['aiPersonality'] as Map<String, dynamic>),
      memory: ContextMemory.fromJson(json['memory'] as Map<String, dynamic>),
      tokenCount: json['tokenCount'] as int,
      lastUpdated: (json['lastUpdated'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'userId': userId,
      'conversationHistory': conversationHistory.map((message) => message.toJson()).toList(),
      'userProfile': userProfile,
      'aiPersonality': aiPersonality.toJson(),
      'memory': memory.toJson(),
      'tokenCount': tokenCount,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  ConversationContext copyWith({
    String? sessionId,
    String? userId,
    List<MessageModel>? conversationHistory,
    Map<String, dynamic>? userProfile,
    AIPersonality? aiPersonality,
    ContextMemory? memory,
    int? tokenCount,
    DateTime? lastUpdated,
  }) {
    return ConversationContext(
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      conversationHistory: conversationHistory ?? this.conversationHistory,
      userProfile: userProfile ?? this.userProfile,
      aiPersonality: aiPersonality ?? this.aiPersonality,
      memory: memory ?? this.memory,
      tokenCount: tokenCount ?? this.tokenCount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
        sessionId,
        userId,
        conversationHistory,
        userProfile,
        aiPersonality,
        memory,
        tokenCount,
        lastUpdated,
      ];
}

class AIPersonality extends Equatable {
  final String gender;
  final String tone;
  final String context;

  const AIPersonality({
    required this.gender,
    required this.tone,
    required this.context,
  });

  factory AIPersonality.fromJson(Map<String, dynamic> json) {
    return AIPersonality(
      gender: json['gender'] as String,
      tone: json['tone'] as String,
      context: json['context'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gender': gender,
      'tone': tone,
      'context': context,
    };
  }

  @override
  List<Object?> get props => [gender, tone, context];
}

class ContextMemory extends Equatable {
  final List<String> keyInsights;
  final List<String> importantTopics;
  final Map<String, dynamic> userPreferences;

  const ContextMemory({
    required this.keyInsights,
    required this.importantTopics,
    required this.userPreferences,
  });

  factory ContextMemory.fromJson(Map<String, dynamic> json) {
    return ContextMemory(
      keyInsights: List<String>.from(json['keyInsights'] as List),
      importantTopics: List<String>.from(json['importantTopics'] as List),
      userPreferences: Map<String, dynamic>.from(json['userPreferences'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'keyInsights': keyInsights,
      'importantTopics': importantTopics,
      'userPreferences': userPreferences,
    };
  }

  ContextMemory copyWith({
    List<String>? keyInsights,
    List<String>? importantTopics,
    Map<String, dynamic>? userPreferences,
  }) {
    return ContextMemory(
      keyInsights: keyInsights ?? this.keyInsights,
      importantTopics: importantTopics ?? this.importantTopics,
      userPreferences: userPreferences ?? this.userPreferences,
    );
  }

  @override
  List<Object?> get props => [keyInsights, importantTopics, userPreferences];
}