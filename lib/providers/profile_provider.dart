import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class ProfileProvider with ChangeNotifier {
  static const String _profileKey = 'user_profile';
  
  UserProfile _profile = UserProfile(
    firstName: 'Kullanıcı',
    lastName: '',
    email: '',
    phone: '',
  );
  
  bool _isLoading = false;
  
  UserProfile get profile => _profile;
  bool get isLoading => _isLoading;

  /// Profili yükle
  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString(_profileKey);
      
      if (profileJson != null) {
        _profile = UserProfile.fromJsonString(profileJson);
      }
    } catch (e) {
      debugPrint('Profil yüklenirken hata: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  /// Profili kaydet
  Future<void> saveProfile(UserProfile profile) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_profileKey, profile.toJsonString());
      _profile = profile;
    } catch (e) {
      debugPrint('Profil kaydedilirken hata: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Profil güncelle
  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    DateTime? birthDate,
    String? avatarUrl,
    String? bio,
    List<String>? favoriteGenres,  // Changed from String? favoriteGenre
  }) async {
    final updatedProfile = _profile.copyWith(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      birthDate: birthDate,
      avatarUrl: avatarUrl,
      bio: bio,
      favoriteGenres: favoriteGenres,
    );
    
    await saveProfile(updatedProfile);
  }
  
  /// Avatar güncelle
  Future<void> updateAvatar(String avatarPath) async {
    final updatedProfile = _profile.copyWith(avatarUrl: avatarPath);
    await saveProfile(updatedProfile);
  }
}
