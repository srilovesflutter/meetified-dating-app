import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String userId;
  final String email;
  final String phoneNumber;
  final DateTime registrationDate;
  final DateTime lastActive;
  final bool isPremium;
  final DateTime? premiumExpiry;
  final DateTime? matchmakingHoldUntil;
  final UserPreferences preferences;
  final UserSettings settings;

  const UserModel({
    required this.userId,
    required this.email,
    required this.phoneNumber,
    required this.registrationDate,
    required this.lastActive,
    this.isPremium = false,
    this.premiumExpiry,
    this.matchmakingHoldUntil,
    required this.preferences,
    required this.settings,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      registrationDate: (json['registrationDate'] as Timestamp).toDate(),
      lastActive: (json['lastActive'] as Timestamp).toDate(),
      isPremium: json['isPremium'] as bool? ?? false,
      premiumExpiry: json['premiumExpiry'] != null 
          ? (json['premiumExpiry'] as Timestamp).toDate() 
          : null,
      matchmakingHoldUntil: json['matchmakingHoldUntil'] != null
          ? (json['matchmakingHoldUntil'] as Timestamp).toDate()
          : null,
      preferences: UserPreferences.fromJson(json['preferences'] as Map<String, dynamic>),
      settings: UserSettings.fromJson(json['settings'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'phoneNumber': phoneNumber,
      'registrationDate': Timestamp.fromDate(registrationDate),
      'lastActive': Timestamp.fromDate(lastActive),
      'isPremium': isPremium,
      'premiumExpiry': premiumExpiry != null ? Timestamp.fromDate(premiumExpiry!) : null,
      'matchmakingHoldUntil': matchmakingHoldUntil != null 
          ? Timestamp.fromDate(matchmakingHoldUntil!) 
          : null,
      'preferences': preferences.toJson(),
      'settings': settings.toJson(),
    };
  }

  UserModel copyWith({
    String? userId,
    String? email,
    String? phoneNumber,
    DateTime? registrationDate,
    DateTime? lastActive,
    bool? isPremium,
    DateTime? premiumExpiry,
    DateTime? matchmakingHoldUntil,
    UserPreferences? preferences,
    UserSettings? settings,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      registrationDate: registrationDate ?? this.registrationDate,
      lastActive: lastActive ?? this.lastActive,
      isPremium: isPremium ?? this.isPremium,
      premiumExpiry: premiumExpiry ?? this.premiumExpiry,
      matchmakingHoldUntil: matchmakingHoldUntil ?? this.matchmakingHoldUntil,
      preferences: preferences ?? this.preferences,
      settings: settings ?? this.settings,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        email,
        phoneNumber,
        registrationDate,
        lastActive,
        isPremium,
        premiumExpiry,
        matchmakingHoldUntil,
        preferences,
        settings,
      ];
}

class UserPreferences extends Equatable {
  final AgeRange ageRange;
  final LocationPreference location;
  final List<String> interests;

  const UserPreferences({
    required this.ageRange,
    required this.location,
    required this.interests,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      ageRange: AgeRange.fromJson(json['ageRange'] as Map<String, dynamic>),
      location: LocationPreference.fromJson(json['location'] as Map<String, dynamic>),
      interests: List<String>.from(json['interests'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ageRange': ageRange.toJson(),
      'location': location.toJson(),
      'interests': interests,
    };
  }

  UserPreferences copyWith({
    AgeRange? ageRange,
    LocationPreference? location,
    List<String>? interests,
  }) {
    return UserPreferences(
      ageRange: ageRange ?? this.ageRange,
      location: location ?? this.location,
      interests: interests ?? this.interests,
    );
  }

  @override
  List<Object?> get props => [ageRange, location, interests];
}

class AgeRange extends Equatable {
  final int min;
  final int max;

  const AgeRange({
    required this.min,
    required this.max,
  });

  factory AgeRange.fromJson(Map<String, dynamic> json) {
    return AgeRange(
      min: json['min'] as int,
      max: json['max'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'min': min,
      'max': max,
    };
  }

  @override
  List<Object?> get props => [min, max];
}

class LocationPreference extends Equatable {
  final String city;
  final double radius;

  const LocationPreference({
    required this.city,
    required this.radius,
  });

  factory LocationPreference.fromJson(Map<String, dynamic> json) {
    return LocationPreference(
      city: json['city'] as String,
      radius: (json['radius'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'radius': radius,
    };
  }

  @override
  List<Object?> get props => [city, radius];
}

class UserSettings extends Equatable {
  final String theme;
  final bool notifications;
  final PrivacySettings privacy;

  const UserSettings({
    required this.theme,
    required this.notifications,
    required this.privacy,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      theme: json['theme'] as String,
      notifications: json['notifications'] as bool,
      privacy: PrivacySettings.fromJson(json['privacy'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'notifications': notifications,
      'privacy': privacy.toJson(),
    };
  }

  UserSettings copyWith({
    String? theme,
    bool? notifications,
    PrivacySettings? privacy,
  }) {
    return UserSettings(
      theme: theme ?? this.theme,
      notifications: notifications ?? this.notifications,
      privacy: privacy ?? this.privacy,
    );
  }

  @override
  List<Object?> get props => [theme, notifications, privacy];
}

class PrivacySettings extends Equatable {
  final bool showProfile;
  final bool allowMessagesFromMatches;
  final bool shareLocation;

  const PrivacySettings({
    required this.showProfile,
    required this.allowMessagesFromMatches,
    required this.shareLocation,
  });

  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    return PrivacySettings(
      showProfile: json['showProfile'] as bool,
      allowMessagesFromMatches: json['allowMessagesFromMatches'] as bool,
      shareLocation: json['shareLocation'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'showProfile': showProfile,
      'allowMessagesFromMatches': allowMessagesFromMatches,
      'shareLocation': shareLocation,
    };
  }

  @override
  List<Object?> get props => [showProfile, allowMessagesFromMatches, shareLocation];
}