/// TMDB API Sabitleri
class ApiConstants {
  static const String apiKey = '65e67d6f7c0ef2a27884e1817bb9934a';
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p';
  
  // Image sizes
  static const String posterW185 = '/w185';
  static const String posterW342 = '/w342';
  static const String posterW500 = '/w500';
  static const String posterOriginal = '/original';
  static const String backdropW780 = '/w780';
  static const String backdropOriginal = '/original';
  
  // Türkçe dil ayarı
  static const String language = 'tr-TR';
  static const String region = 'TR';
  
  // Endpoints
  static String get popularMovies => '$baseUrl/movie/popular?api_key=$apiKey&language=$language&region=$region';
  static String get trendingMovies => '$baseUrl/trending/movie/week?api_key=$apiKey&language=$language';
  static String get topRatedMovies => '$baseUrl/movie/top_rated?api_key=$apiKey&language=$language&region=$region';
  static String get genres => '$baseUrl/genre/movie/list?api_key=$apiKey&language=$language';
  
  static String searchMovies(String query) => 
    '$baseUrl/search/movie?api_key=$apiKey&language=$language&query=$query';
  
  static String movieDetails(int movieId) => 
    '$baseUrl/movie/$movieId?api_key=$apiKey&language=$language';
  
  static String moviesByGenre(int genreId) => 
    '$baseUrl/discover/movie?api_key=$apiKey&language=$language&with_genres=$genreId';
  
  static String movieCredits(int movieId) => 
    '$baseUrl/movie/$movieId/credits?api_key=$apiKey&language=$language';
  
  static String getPosterUrl(String? posterPath, {String size = posterW342}) {
    if (posterPath == null) return '';
    return '$imageBaseUrl$size$posterPath';
  }
  
  static String getBackdropUrl(String? backdropPath, {String size = backdropW780}) {
    if (backdropPath == null) return '';
    return '$imageBaseUrl$size$backdropPath';
  }
}

/// Uygulama Sabitleri
class AppConstants {
  static const String appName = 'Film Keşfet';
  static const String defaultAvatarUrl = 'https://ui-avatars.com/api/?name=Kullanici&background=random';
}
