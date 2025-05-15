import 'favorites_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/tmdb_service.dart';
import '../services/series_service.dart';
import '../services/auth_service.dart';
import '../models/movie.dart';
import '../models/series.dart';
import '../widgets/app_logo.dart';
import 'series_details_page.dart';
import 'movie_details_page.dart';
import 'profile_page.dart';
import '../data/mock_movies.dart';
import '../data/mock_series.dart';
import 'package:firebase_auth/firebase_auth.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedGenre = 'Todos';
  String searchQuery = '';
  bool isLoading = true;
  List<Movie> movies = [];
  List<Series> series = [];
  final TextEditingController _searchController = TextEditingController();
  final _authService = AuthService();

  // Lista de géneros usando SeriesService.genreTranslation
  List<String> get genres => ['Todos', ...SeriesService.genreTranslation.values];

  @override
  void initState() {
    super.initState();

    // Verificar autenticación y cargar contenido
    _checkAuthAndLoadContent();
  }

  // Método para verificar autenticación y cargar contenido
  Future<void> _checkAuthAndLoadContent() async {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      // Si no hay usuario logueado, redirige al login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      });
    } else {
      // Si el usuario está autenticado, carga el contenido
      fetchContent();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void updateSearchQuery(String value) {
    setState(() {
      searchQuery = value;
      
      // Si la búsqueda no devuelve resultados, evita el error
      if (movies.isEmpty && series.isEmpty) {
        debugPrint('⚠️ Advertencia: No hay contenido para mostrar');
        return;
      }
    });
  }

  void fetchContent() async {
    try {
      final tmdbService = TMDbService();
      final fetchedMovies = await tmdbService.fetchPopularMovies();
      final fetchedSeries = await tmdbService.fetchPopularSeries();

      setState(() {
        movies = [...mockMovies, ...fetchedMovies];
        series = kDebugMode ? [...mockSeries, ...fetchedSeries] : [...fetchedSeries];
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error al cargar contenido: $e');
      setState(() {
        // Incluso si hay error, mostramos los datos de prueba
        movies = [...mockMovies];
        series = [...mockSeries];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser; // Obtener usuario actual
    
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const AppLogo(size: 35),
              if (selectedGenre != 'Todos')
                Text(
                  'Género: $selectedGenre',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                ),
            ],
          ),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Películas'),
              Tab(text: 'Series'),
            ],
          ),
        ),
        drawer: Drawer(
          child: SafeArea(
            child: Column(
              children: [
                // Nuevo encabezado con información del usuario
                UserAccountsDrawerHeader(
                  accountName: Text(
                    user?.displayName ?? "Usuario",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  accountEmail: Text(
                    user?.email ?? "",
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : null,
                    child: user?.photoURL == null
                        ? const Icon(Icons.person, size: 40, color: Colors.redAccent)
                        : null,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                  ),
                ),

                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      const SizedBox(height: 8),
                      // Sección de contenido
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          "CONTENIDO",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.home, color: Colors.green),
                        title: const Text(
                          'Mostrar todo',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          setState(() {
                            selectedGenre = 'Todos';
                            searchQuery = '';
                            _searchController.clear();
                          });
                          Navigator.pop(context);
                        },
                      ),

                      // Buscador
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText: '🔍 Buscar título',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        _searchController.clear();
                                        searchQuery = '';
                                      });
                                    },
                                  )
                                : null,
                          ),
                          onSubmitted: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                            Navigator.pop(context); // Cierra el Drawer
                          },
                        ),
                      ),
                      
                      // Filtro por género
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: '🎭 Género',
                            border: OutlineInputBorder(),
                          ),
                          value: selectedGenre,
                          items: genres.map((genre) => DropdownMenuItem<String>(value: genre, child: Text(genre))).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedGenre = value!;
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ),

                      const Divider(),
                      
                      // Sección de cuenta
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          "MI CUENTA",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const Divider(),
                      ListTile(
  leading: const Icon(Icons.favorite, color: Colors.red),
  title: const Text(
    'Mis Favoritos',
    style: TextStyle(fontWeight: FontWeight.bold),
  ),
  onTap: () {
    Navigator.pop(context); // Cierra el drawer
    
    // Navegar a la página de favoritos usando materialPageRoute
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FavoritesPage(),
      ),
    );
  },
),
                      // Enlace a la página de perfil
                      ListTile(
                        leading: const Icon(Icons.account_circle, color: Colors.blueAccent),
                        title: const Text(
                          'Mi Perfil',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text('Gestiona tu cuenta y cierra sesión'),
                        onTap: () {
                          Navigator.pop(context); // Cerrar el drawer
                          
                          // Navegar a la página de perfil
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ProfilePage()),
                          );
                        },
                      ),
                      
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  buildContentGrid(isSeries: false),
                  buildContentGrid(isSeries: true),
                ],
              ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.redAccent,
          onPressed: () => _showHelpDialog(context),
          child: const Icon(Icons.help_outline),
        ),
      ),
    );
  }

  Widget buildContentGrid({required bool isSeries}) {
    // Filtrado de películas con mejor manejo de géneros
    List<Movie> filteredMovies = movies.where((movie) {
      final matchesSearch = movie.title.toLowerCase().contains(searchQuery.toLowerCase());
      
      // Usar la traducción de géneros para películas
      final movieGenres = movie.genre.contains(',') 
          ? movie.genre.split(',').map((g) => g.trim().toLowerCase()).toList() 
          : [movie.genre.trim().toLowerCase()];
      
      // Verificar si el género seleccionado está en la lista de géneros de la película
      final matchesGenre = selectedGenre == 'Todos' || 
          movieGenres.any((genre) => SeriesService.genreTranslation.values
              .any((translated) => translated.toLowerCase() == genre && 
                  (translated == selectedGenre || selectedGenre == 'Todos')));
      
      return matchesSearch && matchesGenre;
    }).toList();

    // Filtrado de series con mejor manejo de géneros
    List<Series> filteredSeries = series.where((serie) {
      final matchesSearch = serie.name.toLowerCase().contains(searchQuery.toLowerCase());
      
      // Obtener los géneros de la serie y convertirlos a minúsculas
      final serieGenres = serie.genres.map((g) => g.trim().toLowerCase()).toList();
      
      // Verificar si el género seleccionado está en la lista de géneros de la serie
      final matchesGenre = selectedGenre == 'Todos' || 
          serieGenres.any((genre) => SeriesService.genreTranslation.values
              .any((translated) => translated.toLowerCase() == genre && 
                  (translated == selectedGenre || selectedGenre == 'Todos')));
      
      return matchesSearch && matchesGenre;
    }).toList();

    final featuredMovies = filteredMovies.where((m) => m.isFeatured).toList();
    final contentList = isSeries ? filteredSeries : filteredMovies;

    // Mostrar mensaje solo si no hay carrusel NI cuadrícula
    final noResults = contentList.isEmpty && (isSeries || featuredMovies.isEmpty);

    if (noResults && searchQuery.isNotEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            '⚠️ No se encontraron resultados. Intenta con otro título.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isSeries &&
              featuredMovies.isNotEmpty &&
              searchQuery.isEmpty &&
              selectedGenre == 'Todos')
            _buildCarousel(featuredMovies),

          buildMovieGrid(contentList),
        ],
      ),
    );
  }

  // Carrusel de películas destacadas
  Widget _buildCarousel(List<Movie> movies) {
    final featuredMovies = movies.where((m) => m.isFeatured).toList();

    if (featuredMovies.isEmpty) return const SizedBox(); // No muestra nada si no hay destacadas

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
          child: Text(
            '🎬 Películas destacadas',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white70),
          ),
        ),
        SizedBox(
          height: 255,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: featuredMovies.length,
            itemBuilder: (context, index) {
              final movie = featuredMovies[index];
              return SizedBox(
                width: 185,
                child: buildContentCard(movie, false),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // Cuadrícula de contenido
  Widget buildMovieGrid(List<dynamic> contentList) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: contentList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.7,
      ),
      itemBuilder: (context, index) {
        final item = contentList[index];
        return buildContentCard(item, item is Series);
      },
    );
  }

  // Tarjeta de contenido
  Widget buildContentCard(dynamic item, bool isSeries) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => isSeries
                ? SeriesDetailPage(seriesId: item.id)
                : MovieDetailPage(movie: item),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                item is Movie ? item.fullPosterUrl : (item as Series).fullPosterUrl,
                height: 170,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 100),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                item is Movie ? item.title : (item as Series).name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ayuda'),
          content: SizedBox(
            width: double.maxFinite,
            child: DefaultTabController(
              length: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const TabBar(
                    labelColor: Colors.redAccent,
                    tabs: [
                      Tab(text: 'Cómo usar'),
                      Tab(text: 'Acerca de'),
                    ],
                  ),
                  SizedBox(
                    height: 200,
                    child: TabBarView(
                      children: [
                        ListView(
                          children: const [
                            ListTile(
                              leading: Icon(Icons.search),
                              title: Text('Buscar películas o series por título'),
                            ),
                            ListTile(
                              leading: Icon(Icons.filter_alt),
                              title: Text('Filtrar por género desde el menú lateral'),
                            ),
                            ListTile(
                              leading: Icon(Icons.play_arrow),
                              title: Text('Haz clic en una película o episodio para reproducir'),
                            ),
                            ListTile(
                              leading: Icon(Icons.account_circle),
                              title: Text('Accede a tu perfil para gestionar tu cuenta'),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Cine Libre es una app sin fines de lucro para ver películas y series.\n\n'
                            'Desarrollado con Flutter con fines educativos y de entretenimiento.\n\n'
                            'Creado por Jeremy Catota.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}