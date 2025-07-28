import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum MatchStatus {
  potential,
  user1Interested,
  user2Interested,
  confirmed,
  user1Rejected,
  user2Rejected,
  expired
}

enum MatchPriority {
  primary,
  secondary,
  tertiary
}

enum UserChoice {
  interested,
  askMore,
  notInterested,
  report
}

class MatchModel extends Equatable {
  final String matchId;
  final String user1Id;
  final String user2Id;
  final DateTime matchDate;
  final MatchStatus status;
  final double compatibilityScore;
  final QuestionExchange questionExchange;
  final double matchQuality;
  final bool mutualInterest;
  final MatchPriority priority;
  final QualityMetrics qualityMetrics;

  const MatchModel({
    required this.matchId,
    required this.user1Id,
    required this.user2Id,
    required this.matchDate,
    required this.status,
    required this.compatibilityScore,
    required this.questionExchange,
    required this.matchQuality,
    required this.mutualInterest,
    required this.priority,
    required this.qualityMetrics,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      matchId: json['matchId'] as String,
      user1Id: json['user1Id'] as String,
      user2Id: json['user2Id'] as String,
      matchDate: (json['matchDate'] as Timestamp).toDate(),
      status: MatchStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => MatchStatus.potential,
      ),
      compatibilityScore: (json['compatibilityScore'] as num).toDouble(),
      questionExchange: QuestionExchange.fromJson(json['questionExchange'] as Map<String, dynamic>),
      matchQuality: (json['matchQuality'] as num).toDouble(),
      mutualInterest: json['mutualInterest'] as bool,
      priority: MatchPriority.values.firstWhere(
        (e) => e.toString().split('.').last == json['priority'],
        orElse: () => MatchPriority.tertiary,
      ),
      qualityMetrics: QualityMetrics.fromJson(json['qualityMetrics'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'matchId': matchId,
      'user1Id': user1Id,
      'user2Id': user2Id,
      'matchDate': Timestamp.fromDate(matchDate),
      'status': status.toString().split('.').last,
      'compatibilityScore': compatibilityScore,
      'questionExchange': questionExchange.toJson(),
      'matchQuality': matchQuality,
      'mutualInterest': mutualInterest,
      'priority': priority.toString().split('.').last,
      'qualityMetrics': qualityMetrics.toJson(),
    };
  }

  MatchModel copyWith({
    String? matchId,
    String? user1Id,
    String? user2Id,
    DateTime? matchDate,
    MatchStatus? status,
    double? compatibilityScore,
    QuestionExchange? questionExchange,
    double? matchQuality,
    bool? mutualInterest,
    MatchPriority? priority,
    QualityMetrics? qualityMetrics,
  }) {
    return MatchModel(
      matchId: matchId ?? this.matchId,
      user1Id: user1Id ?? this.user1Id,
      user2Id: user2Id ?? this.user2Id,
      matchDate: matchDate ?? this.matchDate,
      status: status ?? this.status,
      compatibilityScore: compatibilityScore ?? this.compatibilityScore,
      questionExchange: questionExchange ?? this.questionExchange,
      matchQuality: matchQuality ?? this.matchQuality,
      mutualInterest: mutualInterest ?? this.mutualInterest,
      priority: priority ?? this.priority,
      qualityMetrics: qualityMetrics ?? this.qualityMetrics,
    );
  }

  String getOtherUserId(String currentUserId) {
    return currentUserId == user1Id ? user2Id : user1Id;
  }

  bool isUserInterested(String userId) {
    if (userId == user1Id) {
      return status == MatchStatus.user1Interested || status == MatchStatus.confirmed;
    } else if (userId == user2Id) {
      return status == MatchStatus.user2Interested || status == MatchStatus.confirmed;
    }
    return false;
  }

  @override
  List<Object?> get props => [
        matchId,
        user1Id,
        user2Id,
        matchDate,
        status,
        compatibilityScore,
        questionExchange,
        matchQuality,
        mutualInterest,
        priority,
        qualityMetrics,
      ];
}

class QuestionExchange extends Equatable {
  final List<String> user1Questions;
  final List<String> user2Questions;
  final List<String> user1Answers;
  final List<String> user2Answers;
  final bool exchangeComplete;

  const QuestionExchange({
    required this.user1Questions,
    required this.user2Questions,
    required this.user1Answers,
    required this.user2Answers,
    required this.exchangeComplete,
  });

  factory QuestionExchange.fromJson(Map<String, dynamic> json) {
    return QuestionExchange(
      user1Questions: List<String>.from(json['user1Questions'] as List),
      user2Questions: List<String>.from(json['user2Questions'] as List),
      user1Answers: List<String>.from(json['user1Answers'] as List),
      user2Answers: List<String>.from(json['user2Answers'] as List),
      exchangeComplete: json['exchangeComplete'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user1Questions': user1Questions,
      'user2Questions': user2Questions,
      'user1Answers': user1Answers,
      'user2Answers': user2Answers,
      'exchangeComplete': exchangeComplete,
    };
  }

  QuestionExchange copyWith({
    List<String>? user1Questions,
    List<String>? user2Questions,
    List<String>? user1Answers,
    List<String>? user2Answers,
    bool? exchangeComplete,
  }) {
    return QuestionExchange(
      user1Questions: user1Questions ?? this.user1Questions,
      user2Questions: user2Questions ?? this.user2Questions,
      user1Answers: user1Answers ?? this.user1Answers,
      user2Answers: user2Answers ?? this.user2Answers,
      exchangeComplete: exchangeComplete ?? this.exchangeComplete,
    );
  }

  @override
  List<Object?> get props => [user1Questions, user2Questions, user1Answers, user2Answers, exchangeComplete];
}

class QualityMetrics extends Equatable {
  final double personalityMatch;
  final double interestOverlap;
  final double communicationStyle;
  final double lifestyleCompatibility;

  const QualityMetrics({
    required this.personalityMatch,
    required this.interestOverlap,
    required this.communicationStyle,
    required this.lifestyleCompatibility,
  });

  factory QualityMetrics.fromJson(Map<String, dynamic> json) {
    return QualityMetrics(
      personalityMatch: (json['personalityMatch'] as num).toDouble(),
      interestOverlap: (json['interestOverlap'] as num).toDouble(),
      communicationStyle: (json['communicationStyle'] as num).toDouble(),
      lifestyleCompatibility: (json['lifestyleCompatibility'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'personalityMatch': personalityMatch,
      'interestOverlap': interestOverlap,
      'communicationStyle': communicationStyle,
      'lifestyleCompatibility': lifestyleCompatibility,
    };
  }

  QualityMetrics copyWith({
    double? personalityMatch,
    double? interestOverlap,
    double? communicationStyle,
    double? lifestyleCompatibility,
  }) {
    return QualityMetrics(
      personalityMatch: personalityMatch ?? this.personalityMatch,
      interestOverlap: interestOverlap ?? this.interestOverlap,
      communicationStyle: communicationStyle ?? this.communicationStyle,
      lifestyleCompatibility: lifestyleCompatibility ?? this.lifestyleCompatibility,
    );
  }

  double get averageScore {
    return (personalityMatch + interestOverlap + communicationStyle + lifestyleCompatibility) / 4;
  }

  @override
  List<Object?> get props => [personalityMatch, interestOverlap, communicationStyle, lifestyleCompatibility];
}