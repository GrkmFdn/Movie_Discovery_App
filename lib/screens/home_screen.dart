import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../providers/profile_provider.dart';
import 'profile_screen.dart';
import '../models/movie.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/movie_card.dart';
import '../widgets/movie_detail_popup.dart';
import '../widgets/add_to_list_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int? _selectedGenreId;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieProvider>().init();
    });
  }


  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }



  void _onSearchChanged() {
    setState(() {});
    if (_searchController.text.isEmpty) {
      context.read<MovieProvider>().clearSearch();
    }
  }

  Future<void> _onRefresh() async {
    await context.read<MovieProvider>().refresh();
  }

  void _onSearch(String query) {
    if (query.isNotEmpty) {
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
        showAddToListBottomSheet(context, movie);
      },
      onMarkWatched: () {
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          backgroundColor: const Color(0xFF1E1E1E),
          color: const Color(0xFF667EEA),
          child: Consumer<MovieProvider>(
            builder: (context, provider, child) {
              // Search results sayfası mı yoksa normal içerik mi?
              final isSearching = _searchController.text.isNotEmpty;
              
              if (isSearching) {
                return _buildSearchResults(provider);
              }
              
              return _buildMainContent(provider);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(MovieProvider provider) {
    return CustomScrollView(
      slivers: [
        // Header with Search
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                Text(
                  'Arama Sonuçları: "${_searchController.text}"',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Search Results Grid
        if (provider.isSearching)
          const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFF667EEA)),
            ),
          )
        else if (provider.searchResults.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: 64,
                    color: Colors.grey[700],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Film bulunamadı',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Farklı bir arama yapın',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.58,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final movie = provider.searchResults[index];
                  return MovieCard(
                    movie: movie,
                    width: double.infinity,
                    height: 240,
                    onTap: () => _onMovieTap(movie),
                    isDarkTheme: true,  // Search results dark theme
                  );
                },
                childCount: provider.searchResults.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMainContent(MovieProvider provider) {
    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: _buildHeader(),
          ),
        ),

        // Genre Pills
        SliverToBoxAdapter(
          child: Container(
            height: 46,
            margin: const EdgeInsets.only(bottom: 24),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: provider.genres.length,
              itemBuilder: (context, index) {
                final genre = provider.genres[index];
                final isSelected = _selectedGenreId == genre.id;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedGenreId = isSelected ? null : genre.id;
                    });
                    // O genre için filmleri yükle
                    if (_selectedGenreId != null) {
                      provider.loadMoviesByGenre(_selectedGenreId!);
                    }
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(23),
                    child: BackdropFilter(
                      filter: isSelected
                          ? ImageFilter.blur(sigmaX: 10, sigmaY: 10)
                          : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                                  colors: [
                                    const Color(0xFF667EEA).withOpacity(0.5),
                                    const Color(0xFF764BA2).withOpacity(0.5),
                                  ],
                                )
                              : null,
                          color: isSelected ? null : const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(23),
                          border: isSelected
                              ? Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                )
                              : null,
                        ),
                        child: Row(
                          children: [
                            if (isSelected)
                              Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            Text(
                              genre.name,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey[400],
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Featured Slider
        SliverToBoxAdapter(
          child: _buildFeaturedSlider(provider),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),

        // Seçili Genre Section (en üstte)
        if (_selectedGenreId != null)
          _buildGenreSection(
            provider.genres.firstWhere((g) => g.id == _selectedGenreId).name,
            _selectedGenreId!,
            provider,
          ),

        if (_selectedGenreId != null)
          const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // Popular Movies (Top Rated - Puanı Yüksek Filmler)
        _buildSection('Popüler Filmler', provider.topRatedMovies),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // Comedy Movies (Genre ID: 35)
        _buildGenreSection('Komedi Filmleri', 35, provider),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // Romance Movies (Genre ID: 10749)
        _buildGenreSection('Romantik Filmler', 10749, provider),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              color: Colors.white70,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Discover Movies',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Consumer<ProfileProvider>(
              builder: (context, provider, child) {
                return ProfileAvatar(
                  avatarUrl: provider.profile.avatarUrl,
                  initials: provider.profile.initials,
                  size: 40,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        // Search Bar
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchController,
            onSubmitted: _onSearch,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search for movies...',
              hintStyle: TextStyle(color: Colors.grey[600]),
              prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey[600]),
                      onPressed: () {
                        _searchController.clear();
                        context.read<MovieProvider>().clearSearch();
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedSlider(MovieProvider provider) {
    // Featured slider HER ZAMAN trending filmlerini gösterir
    final featuredMovies = provider.trendingMovies.take(3).toList();

    if (featuredMovies.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Text(
            "Haftanın Öne Çıkanı",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pageController,
            itemCount: featuredMovies.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final movie = featuredMovies[index];
              return _buildFeaturedCard(movie);
            },
          ),
        ),
        const SizedBox(height: 12),
        // Dot Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            featuredMovies.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                gradient: _currentPage == index
                    ? const LinearGradient(
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      )
                    : null,
                color: _currentPage == index ? null : Colors.grey[700],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCard(Movie movie) {
    return GestureDetector(
      onTap: () => _onMovieTap(movie),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667EEA).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (movie.backdropPath != null)
                Image.network(
                  movie.backdropUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: const Color(0xFF1E1E1E)),
                )
              else
                Container(color: const Color(0xFF1E1E1E)),
              
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.9),
                    ],
                  ),
                ),
              ),
              
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Featured',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      movie.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: Colors.amber[300],
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          movie.formattedRating,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          movie.year,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Movie> movies) {
    if (movies.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final displayMovies = movies;
    
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: displayMovies.take(10).length,
              itemBuilder: (context, index) {
                return MovieCard(
                  movie: displayMovies[index],
                  width: 140,
                  height: 210,
                  isDarkTheme: true,
                  onTap: () => _onMovieTap(displayMovies[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreSection(String title, int genreId, MovieProvider provider) {
    final movies = provider.getMoviesByGenre(genreId);
    
    if (movies.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: movies.take(10).length,
              itemBuilder: (context, index) {
                return MovieCard(
                  movie: movies[index],
                  width: 140,
                  height: 210,
                  isDarkTheme: true,
                  onTap: () => _onMovieTap(movies[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
