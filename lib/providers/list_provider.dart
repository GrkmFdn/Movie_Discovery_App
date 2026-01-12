import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie_list.dart';
import '../models/movie.dart';

class ListProvider with ChangeNotifier {
  static const String _listsKey = 'user_movie_lists';
  
  List<MovieList> _lists = [];
  bool _isLoading = false;
  
  List<MovieList> get lists => _lists;
  bool get isLoading => _isLoading;

  /// Listeleri yükle
  Future<void> loadLists() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final listsJson = prefs.getString(_listsKey);
      
      if (listsJson != null) {
        final List<dynamic> decoded = jsonDecode(listsJson);
        _lists = decoded.map((json) => MovieList.fromJson(json)).toList();
        // En son güncellenen önce
        _lists.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      }
    } catch (e) {
      debugPrint('Listeler yüklenirken hata: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Listeleri kaydet
  Future<void> _saveLists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listsJson = jsonEncode(_lists.map((l) => l.toJson()).toList());
      await prefs.setString(_listsKey, listsJson);
    } catch (e) {
      debugPrint('Listeler kaydedilirken hata: $e');
    }
  }

  /// Yeni liste oluştur
  Future<MovieList> createList({required String name, String? description}) async {
    final newList = MovieList.create(name: name, description: description);
    _lists.insert(0, newList);
    notifyListeners();
    await _saveLists();
    return newList;
  }

  /// Liste güncelle
  Future<void> updateList(String listId, {String? name, String? description}) async {
    final index = _lists.indexWhere((l) => l.id == listId);
    if (index != -1) {
      _lists[index] = _lists[index].copyWith(
        name: name,
        description: description,
      );
      notifyListeners();
      await _saveLists();
    }
  }

  /// Liste sil
  Future<void> deleteList(String listId) async {
    _lists.removeWhere((l) => l.id == listId);
    notifyListeners();
    await _saveLists();
  }

  /// Listeye film ekle
  Future<void> addMovieToList(String listId, Movie movie) async {
    final index = _lists.indexWhere((l) => l.id == listId);
    if (index != -1) {
      if (!_lists[index].containsMovie(movie.id)) {
        final updatedMovies = [..._lists[index].movies, movie];
        _lists[index] = _lists[index].copyWith(movies: updatedMovies);
        
        // İlk film eklendiyse kapak fotoğrafını ayarla
        if (_lists[index].coverImageUrl == null && movie.posterPath != null) {
          _lists[index] = _lists[index].copyWith(coverImageUrl: movie.posterUrl);
        }
        
        notifyListeners();
        await _saveLists();
      }
    }
  }

  /// Listeden film çıkar
  Future<void> removeMovieFromList(String listId, int movieId) async {
    final index = _lists.indexWhere((l) => l.id == listId);
    if (index != -1) {
      final updatedMovies = _lists[index].movies.where((m) => m.id != movieId).toList();
      _lists[index] = _lists[index].copyWith(movies: updatedMovies);
      notifyListeners();
      await _saveLists();
    }
  }

  /// Film hangi listelerde var
  List<String> getListsContainingMovie(int movieId) {
    return _lists
        .where((l) => l.containsMovie(movieId))
        .map((l) => l.id)
        .toList();
  }

  /// Liste getir
  MovieList? getListById(String listId) {
    try {
      return _lists.firstWhere((l) => l.id == listId);
    } catch (e) {
      return null;
    }
  }
}
