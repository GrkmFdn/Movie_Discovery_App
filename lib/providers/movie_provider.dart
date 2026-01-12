import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../models/genre.dart';
import '../services/tmdb_service.dart';

class MovieProvider with ChangeNotifier {
  final TmdbService _tmdbService = TmdbService();
  
  List<Movie> _popularMovies = [];
  List<Movie> _trendingMovies = [];
  List<Movie> _searchResults = [];
  List<Genre> _genres = [];
  Map<int, List<Movie>> _moviesByGenre = {};
  
  bool _isLoadingPopular = false;
  bool _isLoadingTrending = false;
  bool _isLoadingGenres = false;
  bool _isSearching = false;
  
  String? _error;
  String _searchQuery = '';

  // Getters
  List<Movie> get popularMovies => _popularMovies;
  List<Movie> get trendingMovies => _trendingMovies;
  List<Movie> get searchResults => _searchResults;
  List<Genre> get genres => _genres;
  
  bool get isLoadingPopular => _isLoadingPopular;
  bool get isLoadingTrending => _isLoadingTrending;
  bool get isLoadingGenres => _isLoadingGenres;
  bool get isSearching => _isSearching;
  
  String? get error => _error;
  String get searchQuery => _searchQuery;
  
  List<Movie> getMoviesByGenre(int genreId) => _moviesByGenre[genreId] ?? [];

  /// Popüler filmleri yükle
  Future<void> loadPopularMovies() async {
    if (_isLoadingPopular) return;
    
    _isLoadingPopular = true;
    _error = null;
    notifyListeners();
    
    try {
      _popularMovies = await _tmdbService.getPopularMovies();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingPopular = false;
      notifyListeners();
    }
  }

  /// Trend filmleri yükle
  Future<void> loadTrendingMovies() async {
    if (_isLoadingTrending) return;
    
    _isLoadingTrending = true;
    _error = null;
    notifyListeners();
    
    try {
      _trendingMovies = await _tmdbService.getTrendingMovies();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingTrending = false;
      notifyListeners();
    }
  }

  /// Kategorileri yükle
  Future<void> loadGenres() async {
    if (_isLoadingGenres) return;
    
    _isLoadingGenres = true;
    _error = null;
    notifyListeners();
    
    try {
      _genres = await _tmdbService.getGenres();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingGenres = false;
      notifyListeners();
    }
  }

  /// Kategoriye göre film yükle
  Future<void> loadMoviesByGenre(int genreId) async {
    if (_moviesByGenre.containsKey(genreId)) return;
    
    try {
      final movies = await _tmdbService.getMoviesByGenre(genreId);
      _moviesByGenre[genreId] = movies;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Film ara
  Future<void> searchMovies(String query) async {
    _searchQuery = query;
    
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }
    
    _isSearching = true;
    _error = null;
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

  /// Tüm verileri yükle
  Future<void> loadInitialData() async {
    await Future.wait([
      loadPopularMovies(),
      loadTrendingMovies(),
      loadGenres(),
    ]);
  }
}
