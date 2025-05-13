import 'package:flutter/material.dart';
import '../models/series.dart';
import '../services/series_service.dart';
import 'video_player_page.dart';

class SeriesDetailPage extends StatefulWidget {
  final int seriesId;

  const SeriesDetailPage({super.key, required this.seriesId});

  @override
  State<SeriesDetailPage> createState() => _SeriesDetailPageState();
}

class _SeriesDetailPageState extends State<SeriesDetailPage> {
  final SeriesService _seriesService = SeriesService();
  Series? series;
  List<dynamic> episodes = [];
  bool isLoading = true;
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
  } catch (e, stacktrace) {
    debugPrint('❌ Error al obtener datos de la serie: $e');
    debugPrint('🛠 Stacktrace: $stacktrace');
    setState(() {
      isLoading = false;
      series = null;
    });
  }
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
      appBar: AppBar(title: Text(series!.name)),
      body: SingleChildScrollView(
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
                  const SizedBox(height: 10),
                  if (series!.genres != null && series!.genres!.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children: series!.genres!
                          .map<Widget>((g) => Chip(label: Text(g)))
                          .toList(),
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
}
