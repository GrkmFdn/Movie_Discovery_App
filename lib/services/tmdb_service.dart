import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/movie.dart';
import '../models/genre.dart';

class TmdbService {
  static final TmdbService _instance = TmdbService._internal();
  factory TmdbService() => _instance;
  TmdbService._internal();

  /// Popüler filmleri getir
  Future<List<Movie>> getPopularMovies({int page = 1}) async {
    try {
      final url = '${ApiConstants.popularMovies}&page=$page';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List;
        return results.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Popüler filmler yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  /// Trend filmleri getir (haftalık)
  Future<List<Movie>> getTrendingMovies({int page = 1}) async {
    try {
      final url = '${ApiConstants.trendingMovies}&page=$page';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List;
        return results.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Trend filmler yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  /// Film ara
  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    if (query.trim().isEmpty) return [];
    
    try {
      final url = '${ApiConstants.searchMovies(query)}&page=$page';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List;
        return results.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Arama başarısız: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  /// Film detayları getir
  Future<Map<String, dynamic>> getMovieDetails(int movieId) async {
    try {
      final url = ApiConstants.movieDetails(movieId);
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Film detayları yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  /// Kategorileri getir
  Future<List<Genre>> getGenres() async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.genres));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final genres = data['genres'] as List;
        return genres.map((json) => Genre.fromJson(json)).toList();
      } else {
        throw Exception('Kategoriler yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  /// Kategoriye göre film getir
  Future<List<Movie>> getMoviesByGenre(int genreId, {int page = 1}) async {
    try {
      final url = '${ApiConstants.moviesByGenre(genreId)}&page=$page';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List;
        return results.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Filmler yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }

  /// Film oyuncuları getir
  Future<Map<String, dynamic>> getMovieCredits(int movieId) async {
    try {
      final url = ApiConstants.movieCredits(movieId);
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Oyuncu bilgileri yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }
}
