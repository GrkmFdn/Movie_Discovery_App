import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../models/genre.dart';
import '../services/tmdb_service.dart';

class MovieProvider with ChangeNotifier {
  final TmdbService _tmdbService = TmdbService();
  
  bool _initialized = false;
  
  List<Movie> _popularMovies = [];
  List<Movie> _trendingMovies = [];
  List<Movie> _topRatedMovies = [];
  List<Movie> _searchResults = [];
  List<Genre> _genres = [];
  final Map<int, List<Movie>> _moviesByGenre = {};
  
  bool _isLoadingPopular = false;
  bool _isLoadingTrending = false;
  bool _isLoadingTopRated = false;
  bool _isLoadingGenres = false;
  bool _isSearching = false;
  
  String? _error;
  String _searchQuery = '';

  // Getters
  List<Movie> get popularMovies => _popularMovies;
  List<Movie> get trendingMovies => _trendingMovies;
  List<Movie> get topRatedMovies => _topRatedMovies;
  List<Movie> get searchResults => _searchResults;
  List<Genre> get genres => _genres;
  
  bool get isLoadingPopular => _isLoadingPopular;
  bool get isLoadingTrending => _isLoadingTrending;
  bool get isLoadingTopRated => _isLoadingTopRated;
  bool get isLoadingGenres => _isLoadingGenres;
  bool get isSearching => _isSearching;
  
  String? get error => _error;
  String get searchQuery => _searchQuery;
  
  List<Movie> getMoviesByGenre(int genreId) => _moviesByGenre[genreId] ?? [];

  /// Merkezi başlatma fonksiyonu
  /// Tek sefer çalışır, tek bir başlangıç/bitiş notify yapar
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    _error = null;
    _isLoadingPopular = true;
    _isLoadingTrending = true;
    _isLoadingTopRated = true;
    _isLoadingGenres = true;
    // Başlangıç notify
    notifyListeners();

    try {
      final results = await Future.wait([
        _tmdbService.getPopularMovies(),
        _tmdbService.getTrendingMovies(),
        _tmdbService.getTopRatedMovies(),
        _tmdbService.getGenres(),
      ]);

      _popularMovies = results[0] as List<Movie>;
      _trendingMovies = results[1] as List<Movie>;
      _topRatedMovies = results[2] as List<Movie>;
      _genres = results[3] as List<Genre>;
      
      // İlk 3 kategori için de filmleri önden yükleyelim (opsiyonel ama iyi olur)
      if (_genres.isNotEmpty) {
        for (var i = 0; i < _genres.length && i < 3; i++) {
          await _loadMoviesByGenreInternal(_genres[i].id);
        }
      }
      
    } catch (e) {
      _error = e.toString();
      debugPrint('Init Error: $_error');
    } finally {
      _isLoadingPopular = false;
      _isLoadingTrending = false;
      _isLoadingTopRated = false;
      _isLoadingGenres = false;
      // Bitiş notify
      notifyListeners();
    }
  }

  /// Kategoriye göre film yükle - Optimize edilmiş
  Future<void> loadMoviesByGenre(int genreId) async {
    if (_moviesByGenre.containsKey(genreId)) return;

    await _loadMoviesByGenreInternal(genreId);

    if (_moviesByGenre.containsKey(genreId)) {
      notifyListeners();
    }
  }


  /// Dahili kullanım için, notify yapmaz
  Future<void> _loadMoviesByGenreInternal(int genreId) async {
    try {
      final movies = await _tmdbService.getMoviesByGenre(genreId);
      _moviesByGenre[genreId] = movies;
    } catch (e) {
      // Sessiz hata yönetimi veya loglama
      debugPrint('Genre Load Error ($genreId): $e');
    }
  }

  /// Film ara
  Future<void> searchMovies(String query) async {
    _searchQuery = query;
    _error = null;
    
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }
    
    _isSearching = true;
    notifyListeners();
    
    try {
      _searchResults = await _tmdbService.searchMovies(query);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  /// Aramayı temizle
  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    notifyListeners();
  }
  
  /// Sayfa yenileme (Pull-to-refresh) için
  Future<void> refresh() async {
    _error = null;
    _moviesByGenre.clear();

    _isLoadingPopular = true;
    _isLoadingTrending = true;
    _isLoadingTopRated = true;
    _isLoadingGenres = true;
    notifyListeners();

    _initialized = false;
    await init();
  }
}
