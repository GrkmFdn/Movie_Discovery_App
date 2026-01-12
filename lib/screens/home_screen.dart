import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../providers/profile_provider.dart';
import '../models/movie.dart';
import '../widgets/search_bar.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/movie_card.dart';
import '../widgets/movie_horizontal_list.dart';
import '../widgets/movie_detail_popup.dart';
import '../widgets/genre_chip.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  int? _selectedGenreId;
  bool _showSearchResults = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      setState(() {
        _showSearchResults = false;
      });
      context.read<MovieProvider>().clearSearch();
    }
  }

  Future<void> _loadData() async {
    final movieProvider = context.read<MovieProvider>();
    await movieProvider.loadInitialData();
    
    // Load movies for first 4 genres
    if (movieProvider.genres.isNotEmpty) {
      for (int i = 0; i < movieProvider.genres.length && i < 4; i++) {
        await movieProvider.loadMoviesByGenre(movieProvider.genres[i].id);
      }
    }
  }

  void _onSearch(String query) {
    if (query.isNotEmpty) {
      setState(() {
        _showSearchResults = true;
      });
      context.read<MovieProvider>().searchMovies(query);
    }
  }

  void _onMovieTap(Movie movie) {
    final movieProvider = context.read<MovieProvider>();
    showMovieDetailPopup(
      context,
      movie,
      movieProvider.genres,
      onAddToList: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Listeye ekleme özelliği yakında!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      onMarkWatched: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('İzledim olarak işaretlendi!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  void _openProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil sayfası yakında!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: CustomScrollView(
            slivers: [
              // App Bar with Profile and Search
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Profile and Settings row
                      Row(
                        children: [
                          Consumer<ProfileProvider>(
                            builder: (context, provider, child) {
                              return ProfileAvatar(
                                avatarUrl: provider.profile.avatarUrl,
                                initials: provider.profile.initials,
                                size: 48,
                                onTap: _openProfile,
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Consumer<ProfileProvider>(
                              builder: (context, provider, child) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      provider.profile.fullName.isEmpty
                                          ? 'Merhaba!'
                                          : provider.profile.fullName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1A1A1A),
                                      ),
                                    ),
                                    Text(
                                      'Film keşfetmeye hazır mısın?',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.notifications_outlined),
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Search Bar
                      CustomSearchBar(
                        controller: _searchController,
                        hintText: 'Film veya dizi ara...',
                        onChanged: (value) {
                          if (value.length >= 2) {
                            _onSearch(value);
                          }
                        },
                        onClear: () {
                          setState(() {
                            _showSearchResults = false;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              Consumer<MovieProvider>(
                builder: (context, movieProvider, child) {
                  // Show search results
                  if (_showSearchResults) {
                    return _buildSearchResults(movieProvider);
                  }

                  // Show main content
                  return SliverList(
                    delegate: SliverChildListDelegate([
                      // Featured Movie
                      if (movieProvider.trendingMovies.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Haftanın Öne Çıkanı',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FeaturedMovieCard(
                          movie: movieProvider.trendingMovies.first,
                          onTap: () => _onMovieTap(
                            movieProvider.trendingMovies.first,
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],

                      // Genre chips
                      if (movieProvider.genres.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Kategoriler',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 44,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            scrollDirection: Axis.horizontal,
                            itemCount: movieProvider.genres.length,
                            itemBuilder: (context, index) {
                              final genre = movieProvider.genres[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: GenreChip(
                                  genre: genre,
                                  isSelected: _selectedGenreId == genre.id,
                                  onTap: () {
                                    setState(() {
                                      if (_selectedGenreId == genre.id) {
                                        _selectedGenreId = null;
                                      } else {
                                        _selectedGenreId = genre.id;
                                        movieProvider.loadMoviesByGenre(genre.id);
                                      }
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],

                      // Selected genre movies
                      if (_selectedGenreId != null) ...[
                        MovieHorizontalList(
                          title: movieProvider.genres
                              .firstWhere((g) => g.id == _selectedGenreId)
                              .name,
                          subtitle: 'Kategori filmleri',
                          movies: movieProvider.getMoviesByGenre(_selectedGenreId!),
                          onMovieTap: _onMovieTap,
                        ),
                        const SizedBox(height: 28),
                      ],

                      // Trending movies
                      MovieHorizontalList(
                        title: 'Trend Filmler',
                        subtitle: 'Bu hafta popüler',
                        movies: movieProvider.trendingMovies,
                        isLoading: movieProvider.isLoadingTrending,
                        onMovieTap: _onMovieTap,
                      ),
                      const SizedBox(height: 28),

                      // Popular movies
                      MovieHorizontalList(
                        title: 'Popüler Filmler',
                        subtitle: 'En çok izlenenler',
                        movies: movieProvider.popularMovies,
                        isLoading: movieProvider.isLoadingPopular,
                        onMovieTap: _onMovieTap,
                      ),
                      const SizedBox(height: 100), // Bottom padding for nav bar
                    ]),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(MovieProvider movieProvider) {
    if (movieProvider.isSearching) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (movieProvider.searchResults.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Sonuç bulunamadı',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '"${_searchController.text}" için sonuç yok',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.55,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final movie = movieProvider.searchResults[index];
            return MovieCard(
              movie: movie,
              width: double.infinity,
              height: 200,
              onTap: () => _onMovieTap(movie),
            );
          },
          childCount: movieProvider.searchResults.length,
        ),
      ),
    );
  }
}
