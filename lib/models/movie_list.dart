import 'dart:convert';
import 'movie.dart';

class MovieList {
  final String id;
  String name;
  String? description;
  final DateTime createdAt;
  DateTime updatedAt;
  List<Movie> movies;
  String? coverImageUrl;

  MovieList({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.movies = const [],
    this.coverImageUrl,
  });

  int get movieCount => movies.length;
  
  bool containsMovie(int movieId) {
    return movies.any((m) => m.id == movieId);
  }

  factory MovieList.create({required String name, String? description}) {
    final now = DateTime.now();
    return MovieList(
      id: now.millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      createdAt: now,
      updatedAt: now,
      movies: [],
    );
  }

  factory MovieList.fromJson(Map<String, dynamic> json) {
    return MovieList(
      id: json['id'] ?? '',
      name: json['name'] ?? 'İsimsiz Liste',
      description: json['description'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      movies: (json['movies'] as List?)
              ?.map((m) => Movie.fromJson(m))
              .toList() ??
          [],
      coverImageUrl: json['coverImageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'movies': movies.map((m) => m.toJson()).toList(),
      'coverImageUrl': coverImageUrl,
    };
  }

  MovieList copyWith({
    String? name,
    String? description,
    List<Movie>? movies,
    String? coverImageUrl,
  }) {
    return MovieList(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      movies: movies ?? this.movies,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
    );
  }
}
