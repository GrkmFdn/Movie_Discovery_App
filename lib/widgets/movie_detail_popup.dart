import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/movie.dart';
import '../models/genre.dart';
import '../providers/watched_provider.dart';

class MovieDetailPopup extends StatelessWidget {
  final Movie movie;
  final List<Genre> genres;
  final VoidCallback? onAddToList;
  final VoidCallback? onMarkWatched;

  const MovieDetailPopup({
    super.key,
    required this.movie,
    this.genres = const [],
    this.onAddToList,
    this.onMarkWatched,
  });

  String _getGenreNames() {
    if (genres.isEmpty) return '';
    return movie.genreIds
        .map((id) => genres.firstWhere(
              (g) => g.id == id,
              orElse: () => Genre(id: 0, name: ''),
            ))
        .where((g) => g.name.isNotEmpty)
        .map((g) => g.name)
        .join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Backdrop image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: movie.backdropPath != null
                        ? CachedNetworkImage(
                            imageUrl: movie.backdropUrl,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              height: 200,
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 200,
                              color: Colors.grey[200],
                              child: const Icon(Icons.movie_outlined, size: 50),
                            ),
                          )
                        : Container(
                            height: 200,
                            color: Colors.grey[200],
                            child: const Icon(Icons.movie_outlined, size: 50),
                          ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Title and rating
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          movie.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              movie.formattedRating,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Year and genres
                  Row(
                    children: [
                      if (movie.year.isNotEmpty) ...[
                        Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(
                          movie.year,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      Icon(Icons.visibility, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        '${movie.voteCount} oy',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  
                  // Genre chips
                  if (_getGenreNames().isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: movie.genreIds
                          .map((id) => genres.firstWhere(
                                (g) => g.id == id,
                                orElse: () => Genre(id: 0, name: ''),
                              ))
                          .where((g) => g.name.isNotEmpty)
                          .map((genre) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Text(
                                  genre.name,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // Overview
                  if (movie.overview != null && movie.overview!.isNotEmpty) ...[
                    const Text(
                      'Özet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      movie.overview!,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[700],
                        height: 1.6,
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 30),
                  
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onAddToList,
                          icon: const Icon(Icons.playlist_add),
                          label: const Text('Listeye Ekle'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF667EEA),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Consumer<WatchedProvider>(
                          builder: (context, watchedProvider, _) {
                            final isWatched = watchedProvider.isWatched(movie.id);
                            
                            return OutlinedButton.icon(
                              onPressed: () async {
                                if (isWatched) {
                                  await watchedProvider.removeFromWatched(movie.id);
                                } else {
                                  await watchedProvider.addToWatched(movie);
                                }
                              },
                              icon: Icon(
                                isWatched ? Icons.check_circle_rounded : Icons.check_circle_outline,
                              ),
                              label: Text(isWatched ? 'İzlendi' : 'İzledim'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: isWatched ? Colors.white : const Color(0xFF667EEA),
                                backgroundColor: isWatched ? const Color(0xFF667EEA) : null,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: const BorderSide(color: Color(0xFF667EEA)),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void showMovieDetailPopup(
  BuildContext context,
  Movie movie,
  List<Genre> genres, {
  VoidCallback? onAddToList,
  VoidCallback? onMarkWatched,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => MovieDetailPopup(
      movie: movie,
      genres: genres,
      onAddToList: onAddToList,
      onMarkWatched: onMarkWatched,
    ),
  );
}
