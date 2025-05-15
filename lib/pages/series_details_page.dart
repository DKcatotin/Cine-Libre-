// Actualización para lib/pages/series_details_page.dart
import 'package:flutter/material.dart';
import '../models/series.dart';
import '../services/series_service.dart';
import '../services/favorites_service.dart';
import 'video_player_page.dart';

class SeriesDetailPage extends StatefulWidget {
  final int seriesId;

  const SeriesDetailPage({super.key, required this.seriesId});

  @override
  State<SeriesDetailPage> createState() => _SeriesDetailPageState();
}

class _SeriesDetailPageState extends State<SeriesDetailPage> {
  final SeriesService _seriesService = SeriesService();
  final FavoritesService _favoritesService = FavoritesService();
  Series? series;
  List<dynamic> episodes = [];
  bool isLoading = true;
  bool _isFavorite = false;
  bool _isCheckingFavorite = true;
  int selectedSeason = 1;

  @override
  void initState() {
    super.initState();
    loadSeries();
  }

  void _handleEpisodeTap(String? url) {
    if (url != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoPlayerPage(videoUrl: url),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontró un video para este episodio')),
      );
    }
  }

  Future<void> loadSeries() async {
    try {
      final data = await _seriesService.fetchSeriesDetails(widget.seriesId);
      debugPrint('✅ Datos obtenidos de la serie: $data');

      if (data.isEmpty) {
        throw Exception('La API devolvió datos vacíos.');
      }

      final seasonData = await _seriesService.fetchSeasonEpisodes(widget.seriesId, selectedSeason);
      debugPrint('✅ Datos obtenidos de episodios: $seasonData');

      if (seasonData.isEmpty || seasonData['episodes'] == null) {
        throw Exception('No se encontraron episodios.');
      }

      setState(() {
        series = Series.fromJson(data);
        episodes = seasonData['episodes'] ?? [];
        isLoading = false;
      });
      
      // Verificar estado de favorito
      _checkFavoriteStatus();
    } catch (e, stacktrace) {
      debugPrint('❌ Error al obtener datos de la serie: $e');
      debugPrint('🛠 Stacktrace: $stacktrace');
      setState(() {
        isLoading = false;
        series = null;
        _isCheckingFavorite = false;
      });
    }
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final isFavorite = await _favoritesService.isFavorite(widget.seriesId, 'series');
      if (mounted) {
        setState(() {
          _isFavorite = isFavorite;
          _isCheckingFavorite = false;
        });
      }
    } catch (e) {
      debugPrint('Error al verificar estado de favorito: $e');
      if (mounted) {
        setState(() {
          _isCheckingFavorite = false;
        });
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (series == null) return;
    
    try {
      final newStatus = await _favoritesService.toggleFavorite(series, 'series');
      if (mounted) {
        setState(() {
          _isFavorite = newStatus;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isFavorite 
                ? '${series!.name} añadido a favoritos'
                : '${series!.name} eliminado de favoritos',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  // El resto del código permanece igual

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (series == null) {
      return const Scaffold(
        body: Center(child: Text("No se pudo cargar la serie. Intenta más tarde.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(series!.name),
        actions: [
          _isCheckingFavorite
            ? const Padding(
                padding: EdgeInsets.all(10.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              )
            : IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : null,
                ),
                onPressed: _toggleFavorite,
              )
        ],
      ),
      body: SingleChildScrollView(
        // El resto del código de build permanece igual
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              series!.fullBackdropUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 100),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(series!.overview, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  Text('Temporadas: ${series!.numberOfSeasons ?? "?"}'),
                  Text('Episodios: ${series!.numberOfEpisodes ?? "?"}'),
                  const SizedBox(height: 10),
                  Text('Puntuación: ${series!.voteAverage.toStringAsFixed(1)}'),
                  Row(
                    children: [
                      Text(
                        'Puntuación: ',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      ...List.generate(5, (index) {
                        return Icon(
                          index < (series!.voteAverage / 2).round()
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 20,
                        );
                      }),
                      SizedBox(width: 8),
                      Text(series!.voteAverage.toStringAsFixed(1)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (series != null && series!.genres.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children: series!.genres.map<Widget>((g) => Chip(label: Text(g))).toList(),
                    ),
                  const SizedBox(height: 20),
                  _buildSeasonSelector(),
                  const SizedBox(height: 10),
                  Text('Episodios', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 10),
                  episodes.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: episodes.length,
                          itemBuilder: (context, index) {
                            final ep = episodes[index];
                            return ExpansionTile(
                              title: Text(ep['name'] ?? 'Sin título'),
                              subtitle: Text('Duración: ${ep['runtime'] ?? "?"} min'),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(ep['overview'] ?? "No hay descripción disponible"),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    final episodeNumber = ep['episode_number'] is int
                                        ? ep['episode_number']
                                        : (index + 1);
                                    final url = await _seriesService.fetchEpisodeYoutubeUrl(
                                      widget.seriesId,
                                      selectedSeason,
                                      episodeNumber,
                                    );

                                    if (!mounted) return;
                                    _handleEpisodeTap(url);
                                  },
                                  child: const Text("Ver capítulo"),
                                ),
                              ],
                            );
                          },
                        )
                      : const Text("No hay episodios disponibles."),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeasonSelector() {
    final totalSeasons = series?.numberOfSeasons ?? 1;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: DropdownButton<int>(
        value: selectedSeason,
        items: List.generate(totalSeasons, (index) {
          return DropdownMenuItem(
            value: index + 1,
            child: Text("Temporada ${index + 1}"),
          );
        }),
        onChanged: (newSeason) {
          if (newSeason != null) {
            setState(() {
              selectedSeason = newSeason;
            });
            loadSeasonEpisodes(selectedSeason);
          }
        },
      ),
    );
  }

  Future<void> loadSeasonEpisodes(int seasonNumber) async {
    try {
      final seasonData = await _seriesService.fetchSeasonEpisodes(widget.seriesId, seasonNumber);
      debugPrint('✅ Episodios cargados para temporada $seasonNumber');

      if (seasonData.isEmpty) {
        throw Exception('No hay datos de episodios disponibles.');
      }

      setState(() {
        episodes = seasonData['episodes'] ?? [];
      });
    } catch (e) {
      debugPrint('❌ Error al obtener episodios de la temporada $seasonNumber: $e');
    }
  }
}