import 'package:flutter/material.dart';
import '../data/mock_movies.dart';
import 'video_player_page.dart';
import 'series_details_page.dart'; //
import '../widgets/app_logo.dart';
import '../models/episode.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  String selectedGenre = 'Todos';
  String searchQuery = '';
  final List<String> genres = [
    'Todos',
    'Acción', 'Drama', 'Comedia',
    'Documental', 'Terror', 'Suspenso',
    'Ciencia Ficción', 'Romance', 'Animación', 'Aventura'
  ];

  @override
  Widget build(BuildContext context) {
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
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.redAccent),
                child: Text('Filtrar contenido', style: TextStyle(color: Colors.white, fontSize: 20)),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Género',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedGenre,
                  items: genres
                      .map((genre) => DropdownMenuItem<String>(value: genre, child: Text(genre)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedGenre = value!;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Buscar título',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                    // Verificación de mounted para evitar errores de contexto en futuras llamadas asíncronas
                    if (mounted) {
                      Navigator.pop(context); // Cierra el drawer después de la búsqueda
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
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
  final filtered = mockMovies.where((movie) {
    final movieGenres = movie.genre.split(',').map((g) => g.trim()).toList();
    final matchesGenre = selectedGenre == 'Todos' || movieGenres.contains(selectedGenre);
    final matchesSearch = movie.title.toLowerCase().contains(searchQuery.toLowerCase());
    return movie.isSeries == isSeries && matchesGenre && matchesSearch;
  }).toList();

  final featured = filtered.where((m) => m.isFeatured).toList();

  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selectedGenre == 'Todos' && featured.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 8),
                  child: Text(
                    'Películas destacadas',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                ),
                SizedBox(
                  height: 255,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: featured.length,
                    itemBuilder: (context, index) {
                      final movie = featured[index];
                      return SizedBox(
                        width: 185,
                        child: buildMovieCard(movie),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(), // ← ¡clave!
            shrinkWrap: true, // ← ¡clave!
            itemCount: filtered.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.7,
            ),
            itemBuilder: (context, index) {
              final movie = filtered[index];
              return buildMovieCard(movie);
            },
          ),
        ],
      ),
    ),
  );
}

  Widget buildMovieCard(movie) {
    return GestureDetector(
      onTap: () {
        if (movie.isSeries) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SeriesDetailPage(series: movie),
            ),
          );
        } else if (movie.youtubeId != null && movie.youtubeId!.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VideoPlayerPage(
                movie: movie,
                episode: Episode(
                  title: movie.title,
                  videoUrl: 'https://www.youtube.com/watch?v=${movie.youtubeId}',
                  duration: 'N/A',
                ),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No hay video disponible')),
          );
        }
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
                movie.imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.broken_image, size: 100),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                movie.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
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
                        ],
                      ),
                      Padding(
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

