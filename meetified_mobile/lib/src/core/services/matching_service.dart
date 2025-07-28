import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';
import '../models/profile_model.dart';
import '../models/match_model.dart';
import '../constants/app_constants.dart';
import 'firebase_service.dart';
import 'auth_service.dart';
import 'logger_service.dart';

class MatchingService {
  static final Uuid _uuid = const Uuid();

  // Main matching algorithm - finds potential matches for a user
  static Future<List<MatchModel>> findPotentialMatches(String userId) async {
    try {
      LoggerService.log('MatchingService', 'findPotentialMatches', 'Finding matches for user: $userId');

      UserModel? user = await AuthService.getUserProfile(userId);
      ProfileModel? userProfile = await _getUserProfile(userId);

      if (user == null || userProfile == null) {
        LoggerService.warning('MatchingService', 'findPotentialMatches', 'User or profile not found');
        return [];
      }

      // Check if matchmaking is on hold
      if (await _isMatchmakingOnHold(user)) {
        LoggerService.log('MatchingService', 'findPotentialMatches', 'Matchmaking on hold for user');
        return [];
      }

      // Get potential candidates
      List<UserModel> candidates = await _getPotentialCandidates(user);
      
      // Calculate compatibility scores
      List<MatchModel> potentialMatches = [];
      
      for (UserModel candidate in candidates) {
        ProfileModel? candidateProfile = await _getUserProfile(candidate.userId);
        if (candidateProfile == null) continue;

        double compatibilityScore = await calculateCompatibilityScore(userProfile, candidateProfile);
        
        if (compatibilityScore >= AppConstants.minCompatibilityScore) {
          MatchModel match = await _createPotentialMatch(
            userId,
            candidate.userId,
            compatibilityScore,
            userProfile,
            candidateProfile,
          );
          potentialMatches.add(match);
        }
      }

      // Sort by compatibility score and prioritize
      potentialMatches.sort((a, b) => b.compatibilityScore.compareTo(a.compatibilityScore));
      potentialMatches = await _prioritizeMatches(potentialMatches);

      // Limit to daily match limit
      potentialMatches = potentialMatches.take(AppConstants.dailyMatchLimit).toList();

      LoggerService.success('MatchingService', 'findPotentialMatches', 
          'Found ${potentialMatches.length} potential matches');

      return potentialMatches;
    } catch (e) {
      LoggerService.error('MatchingService', 'findPotentialMatches', 'Failed to find matches: $e');
      return [];
    }
  }

  // Calculate compatibility score between two profiles
  static Future<double> calculateCompatibilityScore(
    ProfileModel user1Profile,
    ProfileModel user2Profile,
  ) async {
    try {
      LoggerService.log('MatchingService', 'calculateCompatibilityScore', 'Calculating compatibility');

      double presentedScore = _calculatePresentedCompatibility(user1Profile, user2Profile) * 0.4;
      double derivedScore = _calculateDerivedCompatibility(user1Profile, user2Profile) * 0.6;

      double totalScore = presentedScore + derivedScore;
      
      LoggerService.log('MatchingService', 'calculateCompatibilityScore', 
          'Compatibility score: $totalScore (Presented: $presentedScore, Derived: $derivedScore)');

      return totalScore;
    } catch (e) {
      LoggerService.error('MatchingService', 'calculateCompatibilityScore', 'Failed to calculate: $e');
      return 0.0;
    }
  }

  // Process user choice on a match
  static Future<void> processUserChoice(
    String userId,
    String matchId,
    UserChoice choice,
  ) async {
    try {
      LoggerService.userAction('MatchingService', 'processUserChoice', 
          'User $userId chose $choice for match $matchId');

      MatchModel? match = await _getMatch(matchId);
      if (match == null) {
        LoggerService.warning('MatchingService', 'processUserChoice', 'Match not found: $matchId');
        return;
      }

      String otherUserId = match.getOtherUserId(userId);

      switch (choice) {
        case UserChoice.interested:
          await _handleInterest(userId, matchId, match);
          break;
        case UserChoice.askMore:
          await _handleAskMore(userId, otherUserId, match);
          break;
        case UserChoice.notInterested:
          await _handleRejection(userId, matchId, match);
          break;
        case UserChoice.report:
          await _handleReport(userId, matchId, match);
          break;
      }

      LoggerService.success('MatchingService', 'processUserChoice', 'Choice processed successfully');
    } catch (e) {
      LoggerService.error('MatchingService', 'processUserChoice', 'Failed to process choice: $e');
      rethrow;
    }
  }

  // Check mutual interest and confirm match if both users are interested
  static Future<void> checkMutualInterest(String user1Id, String user2Id) async {
    try {
      LoggerService.log('MatchingService', 'checkMutualInterest', 
          'Checking mutual interest between $user1Id and $user2Id');

      MatchModel? match = await _findMatchBetweenUsers(user1Id, user2Id);
      if (match == null) return;

      bool user1Interested = _isUserInterestedInMatch(match, user1Id);
      bool user2Interested = _isUserInterestedInMatch(match, user2Id);

      if (user1Interested && user2Interested) {
        await _confirmMatch(match);
        await _notifyBothUsersSimultaneously(user1Id, user2Id, match.matchId);
        LoggerService.match('MatchingService', 'checkMutualInterest', 
            match.matchId, match.compatibilityScore);
      }
    } catch (e) {
      LoggerService.error('MatchingService', 'checkMutualInterest', 'Failed to check mutual interest: $e');
    }
  }

  // Daily matching algorithm (to be called by Cloud Functions)
  static Future<void> runDailyMatching() async {
    try {
      LoggerService.log('MatchingService', 'runDailyMatching', 'Starting daily matching algorithm');

      // Get all active users
      List<UserModel> activeUsers = await _getActiveUsers();
      
      int totalMatches = 0;
      for (UserModel user in activeUsers) {
        List<MatchModel> matches = await findPotentialMatches(user.userId);
        
        // Save matches to database
        for (MatchModel match in matches) {
          await _saveMatch(match);
          totalMatches++;
        }
      }

      LoggerService.success('MatchingService', 'runDailyMatching', 
          'Daily matching complete. Created $totalMatches matches for ${activeUsers.length} users');
    } catch (e) {
      LoggerService.error('MatchingService', 'runDailyMatching', 'Daily matching failed: $e');
      rethrow;
    }
  }

  // Refine compatibility score based on additional answers
  static Future<double> refineCompatibilityScore(
    String matchId,
    String userId,
    List<String> answers,
  ) async {
    try {
      LoggerService.log('MatchingService', 'refineCompatibilityScore', 
          'Refining score for match: $matchId');

      MatchModel? match = await _getMatch(matchId);
      if (match == null) return 0.0;

      // Get updated profiles
      String otherUserId = match.getOtherUserId(userId);
      ProfileModel? userProfile = await _getUserProfile(userId);
      ProfileModel? otherProfile = await _getUserProfile(otherUserId);

      if (userProfile == null || otherProfile == null) return match.compatibilityScore;

      // Recalculate with additional context from answers
      double baseScore = await calculateCompatibilityScore(userProfile, otherProfile);
      double answerBonus = _calculateAnswerCompatibility(answers);
      
      double refinedScore = (baseScore + answerBonus) / 2;
      
      // Update match with refined score
      await FirebaseService.matchDocument(matchId).update({
        'compatibilityScore': refinedScore,
        'matchQuality': refinedScore,
      });

      LoggerService.success('MatchingService', 'refineCompatibilityScore', 
          'Score refined from $baseScore to $refinedScore');

      return refinedScore;
    } catch (e) {
      LoggerService.error('MatchingService', 'refineCompatibilityScore', 'Failed to refine score: $e');
      return 0.0;
    }
  }

  // Private helper methods

  static Future<ProfileModel?> _getUserProfile(String userId) async {
    try {
      DocumentSnapshot doc = await FirebaseService.profileDocument(userId).get();
      if (doc.exists) {
        return ProfileModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      LoggerService.error('MatchingService', '_getUserProfile', 'Failed to get profile: $e');
      return null;
    }
  }

  static Future<bool> _isMatchmakingOnHold(UserModel user) async {
    if (user.matchmakingHoldUntil == null) return false;
    return DateTime.now().isBefore(user.matchmakingHoldUntil!);
  }

  static Future<List<UserModel>> _getPotentialCandidates(UserModel user) async {
    try {
      // Get users within age and location preferences
      Query query = FirebaseService.usersCollection
          .where('userId', isNotEqualTo: user.userId)
          .where('lastActive', isGreaterThan: Timestamp.fromDate(
              DateTime.now().subtract(const Duration(days: 30))))
          .limit(100);

      QuerySnapshot snapshot = await query.get();
      
      List<UserModel> candidates = [];
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        try {
          UserModel candidate = UserModel.fromJson(doc.data() as Map<String, dynamic>);
          
          // Filter by age preference
          if (_isWithinAgeRange(user, candidate) && 
              _isWithinLocationRange(user, candidate)) {
            candidates.add(candidate);
          }
        } catch (e) {
          LoggerService.warning('MatchingService', '_getPotentialCandidates', 
              'Failed to parse candidate: ${doc.id}');
        }
      }

      return candidates;
    } catch (e) {
      LoggerService.error('MatchingService', '_getPotentialCandidates', 'Failed to get candidates: $e');
      return [];
    }
  }

  static bool _isWithinAgeRange(UserModel user, UserModel candidate) {
    ProfileModel? candidateProfile;
    // This would need to be fetched, but for efficiency we'll assume it's available
    // In a real implementation, you'd batch-fetch profiles or include age in user model
    return true; // Simplified for now
  }

  static bool _isWithinLocationRange(UserModel user, UserModel candidate) {
    // This would calculate distance between user locations
    // For now, we'll use city comparison as a simplified approach
    return user.preferences.location.city == candidate.preferences.location.city;
  }

  static double _calculatePresentedCompatibility(ProfileModel user1, ProfileModel user2) {
    double interestOverlap = _calculateInterestOverlap(user1.presented.interests, user2.presented.interests);
    double valueAlignment = _calculateValueAlignment(user1.presented.values, user2.presented.values);
    double locationCompatibility = _calculateLocationCompatibility(user1.presented.location, user2.presented.location);

    return (interestOverlap + valueAlignment + locationCompatibility) / 3;
  }

  static double _calculateDerivedCompatibility(ProfileModel user1, ProfileModel user2) {
    double personalityCompatibility = _calculatePersonalityCompatibility(
        user1.derived.personality, user2.derived.personality);
    double communicationCompatibility = _calculateCommunicationCompatibility(
        user1.derived.communicationStyle, user2.derived.communicationStyle);
    double lifestyleCompatibility = _calculateLifestyleCompatibility(
        user1.derived.lifestylePreferences, user2.derived.lifestylePreferences);

    return (personalityCompatibility + communicationCompatibility + lifestyleCompatibility) / 3;
  }

  static double _calculateInterestOverlap(List<String> interests1, List<String> interests2) {
    if (interests1.isEmpty || interests2.isEmpty) return 0.0;
    
    Set<String> set1 = interests1.map((e) => e.toLowerCase()).toSet();
    Set<String> set2 = interests2.map((e) => e.toLowerCase()).toSet();
    
    int overlap = set1.intersection(set2).length;
    int total = set1.union(set2).length;
    
    return total > 0 ? overlap / total : 0.0;
  }

  static double _calculateValueAlignment(List<String> values1, List<String> values2) {
    if (values1.isEmpty || values2.isEmpty) return 0.0;
    
    Set<String> set1 = values1.map((e) => e.toLowerCase()).toSet();
    Set<String> set2 = values2.map((e) => e.toLowerCase()).toSet();
    
    int overlap = set1.intersection(set2).length;
    return overlap / max(set1.length, set2.length);
  }

  static double _calculateLocationCompatibility(String location1, String location2) {
    // Simple string comparison for now
    // In a real implementation, this would use geographic distance
    return location1.toLowerCase() == location2.toLowerCase() ? 1.0 : 0.5;
  }

  static double _calculatePersonalityCompatibility(PersonalityTraits p1, PersonalityTraits p2) {
    // Calculate compatibility using Big Five personality traits
    double opennessDiff = (p1.openness - p2.openness).abs();
    double conscientiousnessDiff = (p1.conscientiousness - p2.conscientiousness).abs();
    double extraversionDiff = (p1.extraversion - p2.extraversion).abs();
    double agreeablenessDiff = (p1.agreeableness - p2.agreeableness).abs();
    double neuroticismDiff = (p1.neuroticism - p2.neuroticism).abs();

    double avgDifference = (opennessDiff + conscientiousnessDiff + extraversionDiff + 
                          agreeablenessDiff + neuroticismDiff) / 5;

    // Convert difference to compatibility (lower difference = higher compatibility)
    return 1.0 - avgDifference;
  }

  static double _calculateCommunicationCompatibility(String style1, String style2) {
    Map<String, List<String>> compatibleStyles = {
      'friendly': ['friendly', 'casual', 'humorous'],
      'formal': ['formal', 'professional'],
      'casual': ['casual', 'friendly', 'humorous'],
      'humorous': ['humorous', 'casual', 'friendly'],
      'professional': ['professional', 'formal'],
    };

    List<String> compatible = compatibleStyles[style1.toLowerCase()] ?? [];
    return compatible.contains(style2.toLowerCase()) ? 1.0 : 0.5;
  }

  static double _calculateLifestyleCompatibility(Map<String, dynamic> lifestyle1, Map<String, dynamic> lifestyle2) {
    double compatibility = 0.0;
    int factors = 0;

    // Compare social levels
    if (lifestyle1['social_level'] != null && lifestyle2['social_level'] != null) {
      compatibility += _compareLifestyleFactor(lifestyle1['social_level'], lifestyle2['social_level']);
      factors++;
    }

    // Compare activity levels
    if (lifestyle1['activity_level'] != null && lifestyle2['activity_level'] != null) {
      compatibility += _compareLifestyleFactor(lifestyle1['activity_level'], lifestyle2['activity_level']);
      factors++;
    }

    // Compare travel interest
    if (lifestyle1['travel_interest'] != null && lifestyle2['travel_interest'] != null) {
      compatibility += _compareLifestyleFactor(lifestyle1['travel_interest'], lifestyle2['travel_interest']);
      factors++;
    }

    return factors > 0 ? compatibility / factors : 0.5;
  }

  static double _compareLifestyleFactor(dynamic factor1, dynamic factor2) {
    if (factor1 == factor2) return 1.0;
    
    List<String> levels = ['low', 'medium', 'high'];
    int index1 = levels.indexOf(factor1.toString().toLowerCase());
    int index2 = levels.indexOf(factor2.toString().toLowerCase());
    
    if (index1 == -1 || index2 == -1) return 0.5;
    
    int difference = (index1 - index2).abs();
    return difference == 0 ? 1.0 : (difference == 1 ? 0.7 : 0.3);
  }

  static Future<MatchModel> _createPotentialMatch(
    String user1Id,
    String user2Id,
    double compatibilityScore,
    ProfileModel user1Profile,
    ProfileModel user2Profile,
  ) async {
    QualityMetrics metrics = QualityMetrics(
      personalityMatch: _calculatePersonalityCompatibility(
          user1Profile.derived.personality, user2Profile.derived.personality),
      interestOverlap: _calculateInterestOverlap(
          user1Profile.presented.interests, user2Profile.presented.interests),
      communicationStyle: _calculateCommunicationCompatibility(
          user1Profile.derived.communicationStyle, user2Profile.derived.communicationStyle),
      lifestyleCompatibility: _calculateLifestyleCompatibility(
          user1Profile.derived.lifestylePreferences, user2Profile.derived.lifestylePreferences),
    );

    return MatchModel(
      matchId: _uuid.v4(),
      user1Id: user1Id,
      user2Id: user2Id,
      matchDate: DateTime.now(),
      status: MatchStatus.potential,
      compatibilityScore: compatibilityScore,
      questionExchange: const QuestionExchange(
        user1Questions: [],
        user2Questions: [],
        user1Answers: [],
        user2Answers: [],
        exchangeComplete: false,
      ),
      matchQuality: compatibilityScore,
      mutualInterest: false,
      priority: MatchPriority.tertiary,
      qualityMetrics: metrics,
    );
  }

  static Future<List<MatchModel>> _prioritizeMatches(List<MatchModel> matches) async {
    for (int i = 0; i < matches.length; i++) {
      MatchPriority priority;
      if (i == 0) {
        priority = MatchPriority.primary;
      } else if (i < 3) {
        priority = MatchPriority.secondary;
      } else {
        priority = MatchPriority.tertiary;
      }
      
      matches[i] = matches[i].copyWith(priority: priority);
    }
    
    return matches;
  }

  static Future<MatchModel?> _getMatch(String matchId) async {
    try {
      DocumentSnapshot doc = await FirebaseService.matchDocument(matchId).get();
      if (doc.exists) {
        return MatchModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      LoggerService.error('MatchingService', '_getMatch', 'Failed to get match: $e');
      return null;
    }
  }

  static Future<void> _saveMatch(MatchModel match) async {
    try {
      await FirebaseService.matchDocument(match.matchId).set(match.toJson());
    } catch (e) {
      LoggerService.error('MatchingService', '_saveMatch', 'Failed to save match: $e');
      rethrow;
    }
  }

  static Future<void> _handleInterest(String userId, String matchId, MatchModel match) async {
    MatchStatus newStatus;
    if (userId == match.user1Id) {
      newStatus = MatchStatus.user1Interested;
    } else {
      newStatus = MatchStatus.user2Interested;
    }

    await FirebaseService.matchDocument(matchId).update({
      'status': newStatus.toString().split('.').last,
    });

    // Check if other user is also interested
    String otherUserId = match.getOtherUserId(userId);
    await checkMutualInterest(userId, otherUserId);
  }

  static Future<void> _handleAskMore(String userId, String otherUserId, MatchModel match) async {
    // This would integrate with AIChatService to initiate question exchange
    // For now, we'll just update the match status
    await FirebaseService.matchDocument(match.matchId).update({
      'questionExchange.exchangeInProgress': true,
    });
  }

  static Future<void> _handleRejection(String userId, String matchId, MatchModel match) async {
    MatchStatus newStatus;
    if (userId == match.user1Id) {
      newStatus = MatchStatus.user1Rejected;
    } else {
      newStatus = MatchStatus.user2Rejected;
    }

    await FirebaseService.matchDocument(matchId).update({
      'status': newStatus.toString().split('.').last,
    });
  }

  static Future<void> _handleReport(String userId, String matchId, MatchModel match) async {
    // Log the report and potentially flag the user
    LoggerService.warning('MatchingService', '_handleReport', 
        'User $userId reported match $matchId');
    
    await _handleRejection(userId, matchId, match);
  }

  static Future<MatchModel?> _findMatchBetweenUsers(String user1Id, String user2Id) async {
    try {
      QuerySnapshot snapshot = await FirebaseService.matchesCollection
          .where('user1Id', isEqualTo: user1Id)
          .where('user2Id', isEqualTo: user2Id)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return MatchModel.fromJson(snapshot.docs.first.data() as Map<String, dynamic>);
      }

      // Check reverse order
      snapshot = await FirebaseService.matchesCollection
          .where('user1Id', isEqualTo: user2Id)
          .where('user2Id', isEqualTo: user1Id)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return MatchModel.fromJson(snapshot.docs.first.data() as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      LoggerService.error('MatchingService', '_findMatchBetweenUsers', 'Failed to find match: $e');
      return null;
    }
  }

  static bool _isUserInterestedInMatch(MatchModel match, String userId) {
    if (userId == match.user1Id) {
      return match.status == MatchStatus.user1Interested || match.status == MatchStatus.confirmed;
    } else if (userId == match.user2Id) {
      return match.status == MatchStatus.user2Interested || match.status == MatchStatus.confirmed;
    }
    return false;
  }

  static Future<void> _confirmMatch(MatchModel match) async {
    await FirebaseService.matchDocument(match.matchId).update({
      'status': MatchStatus.confirmed.toString().split('.').last,
      'mutualInterest': true,
    });
  }

  static Future<void> _notifyBothUsersSimultaneously(String user1Id, String user2Id, String matchId) async {
    // This would send push notifications to both users
    LoggerService.log('MatchingService', '_notifyBothUsersSimultaneously', 
        'Notifying users $user1Id and $user2Id about confirmed match');
  }

  static Future<List<UserModel>> _getActiveUsers() async {
    try {
      DateTime cutoff = DateTime.now().subtract(const Duration(days: 7));
      
      QuerySnapshot snapshot = await FirebaseService.usersCollection
          .where('lastActive', isGreaterThan: Timestamp.fromDate(cutoff))
          .get();

      List<UserModel> users = [];
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        try {
          users.add(UserModel.fromJson(doc.data() as Map<String, dynamic>));
        } catch (e) {
          LoggerService.warning('MatchingService', '_getActiveUsers', 
              'Failed to parse user: ${doc.id}');
        }
      }

      return users;
    } catch (e) {
      LoggerService.error('MatchingService', '_getActiveUsers', 'Failed to get active users: $e');
      return [];
    }
  }

  static double _calculateAnswerCompatibility(List<String> answers) {
    // This would analyze answers using AI to determine compatibility
    // For now, return a base score
    return 0.1; // Small bonus for providing answers
  }
}