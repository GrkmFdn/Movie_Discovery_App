import 'package:flutter/material.dart';
import '../models/movie.dart';
import 'movie_card.dart';

class MovieHorizontalList extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Movie> movies;
  final bool isLoading;
  final Function(Movie) onMovieTap;
  final VoidCallback? onShowAll;

  const MovieHorizontalList({
    super.key,
    required this.title,
    this.subtitle,
    required this.movies,
    this.isLoading = false,
    required this.onMovieTap,
    this.onShowAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                      ),
                    ),
                ],
              ),
              if (onShowAll != null)
                TextButton.icon(
                  onPressed: onShowAll,
                  icon: const Icon(Icons.arrow_forward_ios, size: 14),
                  label: const Text('Tümünü Gör'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF667EEA),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Movie list
        SizedBox(
          height: 280,
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : movies.isEmpty
                  ? Center(
                      child: Text(
                        'Film bulunamadı',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: movies.length,
                      itemBuilder: (context, index) {
                        final movie = movies[index];
                        return MovieCard(
                          movie: movie,
                          onTap: () => onMovieTap(movie),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
