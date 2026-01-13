import 'dart:convert';

class UserProfile {
  String firstName;
  String lastName;
  String email;
  String phone;
  DateTime? birthDate;
  String? avatarUrl;
  String? bio;
  List<String> favoriteGenres;  // Changed from String? favoriteGenre

  UserProfile({
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.phone = '',
    this.birthDate,
    this.avatarUrl,
    this.bio,
    this.favoriteGenres = const [],  // Default empty list
  });

  String get fullName => '$firstName $lastName'.trim();
  
  String get initials {
    String initials = '';
    if (firstName.isNotEmpty) initials += firstName[0].toUpperCase();
    if (lastName.isNotEmpty) initials += lastName[0].toUpperCase();
    return initials.isEmpty ? 'K' : initials;
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    // Migration: eski format (tek string) → yeni format (list)
    List<String> genres = [];
    
    // Yeni format
    if (json['favoriteGenres'] != null) {
      genres = List<String>.from(json['favoriteGenres']);
    }
    // Eski format migration
    else if (json['favoriteGenre'] != null && json['favoriteGenre'].toString().isNotEmpty) {
      genres = [json['favoriteGenre'].toString()];
    }
    
    return UserProfile(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      birthDate: json['birthDate'] != null 
          ? DateTime.tryParse(json['birthDate']) 
          : null,
      avatarUrl: json['avatarUrl'],
      bio: json['bio'],
      favoriteGenres: genres,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'birthDate': birthDate?.toIso8601String(),
      'avatarUrl': avatarUrl,
      'bio': bio,
      'favoriteGenres': favoriteGenres,  // Yeni format
    };
  }

  String toJsonString() => jsonEncode(toJson());
  
  static UserProfile fromJsonString(String jsonString) {
    return UserProfile.fromJson(jsonDecode(jsonString));
  }

  UserProfile copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    DateTime? birthDate,
    String? avatarUrl,
    String? bio,
    List<String>? favoriteGenres,
  }) {
    return UserProfile(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      favoriteGenres: favoriteGenres ?? this.favoriteGenres,
    );
  }
}
