import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ProfileModel extends Equatable {
  final String userId;
  final PresentedData presented;
  final DerivedData derived;
  final AIContext aiContext;
  final DateTime lastUpdated;

  const ProfileModel({
    required this.userId,
    required this.presented,
    required this.derived,
    required this.aiContext,
    required this.lastUpdated,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      userId: json['userId'] as String,
      presented: PresentedData.fromJson(json['presented'] as Map<String, dynamic>),
      derived: DerivedData.fromJson(json['derived'] as Map<String, dynamic>),
      aiContext: AIContext.fromJson(json['aiContext'] as Map<String, dynamic>),
      lastUpdated: (json['lastUpdated'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'presented': presented.toJson(),
      'derived': derived.toJson(),
      'aiContext': aiContext.toJson(),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  ProfileModel copyWith({
    String? userId,
    PresentedData? presented,
    DerivedData? derived,
    AIContext? aiContext,
    DateTime? lastUpdated,
  }) {
    return ProfileModel(
      userId: userId ?? this.userId,
      presented: presented ?? this.presented,
      derived: derived ?? this.derived,
      aiContext: aiContext ?? this.aiContext,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [userId, presented, derived, aiContext, lastUpdated];
}

class PresentedData extends Equatable {
  final String name;
  final int age;
  final String location;
  final String occupation;
  final String bio;
  final List<String> photos;
  final List<String> interests;
  final List<String> values;

  const PresentedData({
    required this.name,
    required this.age,
    required this.location,
    required this.occupation,
    required this.bio,
    required this.photos,
    required this.interests,
    required this.values,
  });

  factory PresentedData.fromJson(Map<String, dynamic> json) {
    return PresentedData(
      name: json['name'] as String,
      age: json['age'] as int,
      location: json['location'] as String,
      occupation: json['occupation'] as String,
      bio: json['bio'] as String,
      photos: List<String>.from(json['photos'] as List),
      interests: List<String>.from(json['interests'] as List),
      values: List<String>.from(json['values'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'location': location,
      'occupation': occupation,
      'bio': bio,
      'photos': photos,
      'interests': interests,
      'values': values,
    };
  }

  PresentedData copyWith({
    String? name,
    int? age,
    String? location,
    String? occupation,
    String? bio,
    List<String>? photos,
    List<String>? interests,
    List<String>? values,
  }) {
    return PresentedData(
      name: name ?? this.name,
      age: age ?? this.age,
      location: location ?? this.location,
      occupation: occupation ?? this.occupation,
      bio: bio ?? this.bio,
      photos: photos ?? this.photos,
      interests: interests ?? this.interests,
      values: values ?? this.values,
    );
  }

  @override
  List<Object?> get props => [name, age, location, occupation, bio, photos, interests, values];
}

class DerivedData extends Equatable {
  final PersonalityTraits personality;
  final String communicationStyle;
  final Map<String, dynamic> lifestylePreferences;
  final String relationshipGoals;
  final Map<String, dynamic> emotionalPatterns;
  final List<String> conversationTopics;
  final Map<String, dynamic> responsePatterns;

  const DerivedData({
    required this.personality,
    required this.communicationStyle,
    required this.lifestylePreferences,
    required this.relationshipGoals,
    required this.emotionalPatterns,
    required this.conversationTopics,
    required this.responsePatterns,
  });

  factory DerivedData.fromJson(Map<String, dynamic> json) {
    return DerivedData(
      personality: PersonalityTraits.fromJson(json['personality'] as Map<String, dynamic>),
      communicationStyle: json['communicationStyle'] as String,
      lifestylePreferences: Map<String, dynamic>.from(json['lifestylePreferences'] as Map),
      relationshipGoals: json['relationshipGoals'] as String,
      emotionalPatterns: Map<String, dynamic>.from(json['emotionalPatterns'] as Map),
      conversationTopics: List<String>.from(json['conversationTopics'] as List),
      responsePatterns: Map<String, dynamic>.from(json['responsePatterns'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'personality': personality.toJson(),
      'communicationStyle': communicationStyle,
      'lifestylePreferences': lifestylePreferences,
      'relationshipGoals': relationshipGoals,
      'emotionalPatterns': emotionalPatterns,
      'conversationTopics': conversationTopics,
      'responsePatterns': responsePatterns,
    };
  }

  DerivedData copyWith({
    PersonalityTraits? personality,
    String? communicationStyle,
    Map<String, dynamic>? lifestylePreferences,
    String? relationshipGoals,
    Map<String, dynamic>? emotionalPatterns,
    List<String>? conversationTopics,
    Map<String, dynamic>? responsePatterns,
  }) {
    return DerivedData(
      personality: personality ?? this.personality,
      communicationStyle: communicationStyle ?? this.communicationStyle,
      lifestylePreferences: lifestylePreferences ?? this.lifestylePreferences,
      relationshipGoals: relationshipGoals ?? this.relationshipGoals,
      emotionalPatterns: emotionalPatterns ?? this.emotionalPatterns,
      conversationTopics: conversationTopics ?? this.conversationTopics,
      responsePatterns: responsePatterns ?? this.responsePatterns,
    );
  }

  @override
  List<Object?> get props => [
        personality,
        communicationStyle,
        lifestylePreferences,
        relationshipGoals,
        emotionalPatterns,
        conversationTopics,
        responsePatterns,
      ];
}

class PersonalityTraits extends Equatable {
  final double openness;
  final double conscientiousness;
  final double extraversion;
  final double agreeableness;
  final double neuroticism;

  const PersonalityTraits({
    required this.openness,
    required this.conscientiousness,
    required this.extraversion,
    required this.agreeableness,
    required this.neuroticism,
  });

  factory PersonalityTraits.fromJson(Map<String, dynamic> json) {
    return PersonalityTraits(
      openness: (json['openness'] as num).toDouble(),
      conscientiousness: (json['conscientiousness'] as num).toDouble(),
      extraversion: (json['extraversion'] as num).toDouble(),
      agreeableness: (json['agreeableness'] as num).toDouble(),
      neuroticism: (json['neuroticism'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'openness': openness,
      'conscientiousness': conscientiousness,
      'extraversion': extraversion,
      'agreeableness': agreeableness,
      'neuroticism': neuroticism,
    };
  }

  @override
  List<Object?> get props => [openness, conscientiousness, extraversion, agreeableness, neuroticism];
}

class AIContext extends Equatable {
  final List<Map<String, dynamic>> sessionHistory;
  final Map<String, dynamic> personalityInsights;
  final String conversationStyle;
  final int tokenCount;

  const AIContext({
    required this.sessionHistory,
    required this.personalityInsights,
    required this.conversationStyle,
    required this.tokenCount,
  });

  factory AIContext.fromJson(Map<String, dynamic> json) {
    return AIContext(
      sessionHistory: List<Map<String, dynamic>>.from(json['sessionHistory'] as List),
      personalityInsights: Map<String, dynamic>.from(json['personalityInsights'] as Map),
      conversationStyle: json['conversationStyle'] as String,
      tokenCount: json['tokenCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionHistory': sessionHistory,
      'personalityInsights': personalityInsights,
      'conversationStyle': conversationStyle,
      'tokenCount': tokenCount,
    };
  }

  AIContext copyWith({
    List<Map<String, dynamic>>? sessionHistory,
    Map<String, dynamic>? personalityInsights,
    String? conversationStyle,
    int? tokenCount,
  }) {
    return AIContext(
      sessionHistory: sessionHistory ?? this.sessionHistory,
      personalityInsights: personalityInsights ?? this.personalityInsights,
      conversationStyle: conversationStyle ?? this.conversationStyle,
      tokenCount: tokenCount ?? this.tokenCount,
    );
  }

  @override
  List<Object?> get props => [sessionHistory, personalityInsights, conversationStyle, tokenCount];
}