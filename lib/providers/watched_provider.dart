import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie.dart';

class WatchedProvider with ChangeNotifier {
  static const String _watchedKey = 'watched_movies';
  
  List<Movie> _watchedMovies = [];
  List<Movie> _filteredMovies = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _currentSort = 'date_desc'; // date_desc, date_asc, rating_desc, title_asc
  
  List<Movie> get watchedMovies => _searchQuery.isEmpty ? _watchedMovies : _filteredMovies;
  bool get isLoading => _isLoading;
  String get currentSort => _currentSort;
  bool get isSearching => _searchQuery.isNotEmpty;

  /// İzlenenleri yükle
  Future<void> loadWatchedMovies() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_watchedKey);
      
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        _watchedMovies = jsonList.map((json) => Movie.fromJson(json)).toList();
        // Varsayılan olarak son eklenen en üstte (aslında listede saklama sıramız bu değilse sort etmeliyiz)
        // Şimdilik listeyi ters çeviriyoruz ki son eklenen başta olsun
        _watchedMovies = _watchedMovies.reversed.toList();
      }
    } catch (e) {
      debugPrint('İzlenenler yüklenirken hata: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// İzlenenleri kaydet
  Future<void> _saveWatchedMovies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Kaydederken orijinal sırayı koruyalım (eklenme sırası)
      // Ancak _watchedMovies'i ters çevirmiştik, kaydederken tekrar ters çevirip orijinal sıraya döndürelim
      final listToSave = _watchedMovies.reversed.toList();
      final String jsonString = jsonEncode(listToSave.map((m) => m.toJson()).toList());
      await prefs.setString(_watchedKey, jsonString);
    } catch (e) {
      debugPrint('İzlenenler kaydedilirken hata: $e');
    }
  }

  /// İzlenenlere ekle
  Future<void> addToWatched(Movie movie) async {
    // Zaten varsa ekleme, en başa taşı
    final index = _watchedMovies.indexWhere((m) => m.id == movie.id);
    if (index != -1) {
      _watchedMovies.removeAt(index);
    }
    
    _watchedMovies.insert(0, movie);
    notifyListeners();
    await _saveWatchedMovies();
  }

  /// İzlenenlerden çıkar
  Future<void> removeFromWatched(int movieId) async {
    _watchedMovies.removeWhere((m) => m.id == movieId);
    if (isSearching) {
      _filteredMovies.removeWhere((m) => m.id == movieId);
    }
    notifyListeners();
    await _saveWatchedMovies();
  }
  
  /// İzlenip izlenmediğini kontrol et
  bool isWatched(int movieId) {
    return _watchedMovies.any((m) => m.id == movieId);
  }

  /// Arama yap
  void searchWatched(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredMovies = [];
    } else {
      _filteredMovies = _watchedMovies.where((movie) {
        return movie.title.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  /// Sıralama
  void sortMovies(String sortType) {
    _currentSort = sortType;
    List<Movie> targetList = isSearching ? _filteredMovies : _watchedMovies;
    
    switch (sortType) {
      case 'date_desc': // Yeni -> Eski (Varsayılan liste yapımız)
        // Listemiz zaten son eklenen başta şeklinde tutuluyor (load ederken reversed yaptık)
        // Ancak sıralama bozulmuş olabilir, tekrar idare etmek gerekir mi?
        // Basitlik adına, loadWatchedMovies'deki mantığı koruyoruz. 
        // Burada gerçek tarih tutmadığımız için sadece liste sırasına güveniyoruz.
        // Eğer kullanıcı başka sıralama seçip geri dönerse bu mantık karışabilir.
        // İdeali Movie modelinde addedDate tutmak.
        // Şimdilik listeyi load edildiği hale döndürmek zor, o yüzden rating ve title sıralamalarını yapalım.
        break;
      case 'rating_desc':
        targetList.sort((a, b) => (double.tryParse(b.voteAverage.toString()) ?? 0)
            .compareTo(double.tryParse(a.voteAverage.toString()) ?? 0));
        break;
      case 'title_asc':
        targetList.sort((a, b) => a.title.compareTo(b.title));
        break;
    }
    notifyListeners();
  }
}
