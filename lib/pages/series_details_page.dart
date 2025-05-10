import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../models/episode.dart';
import 'video_player_page.dart';

class SeriesDetailPage extends StatelessWidget {
  final Movie series;

  const SeriesDetailPage({super.key, required this.series});

  @override
  Widget build(BuildContext context) {
    // Asegúrate de que 'episodes' nunca sea nulo
    final List<Episode> episodes = series.episodes;

    return Scaffold(
      appBar: AppBar(
        title: Text(series.title),
      ),
      body: Column(
        children: [
          Image.network(
            series.imageUrl,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.broken_image, size: 100),
          ),
          const SizedBox(height: 10),
          Text(
            'Episodios',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: episodes.length,
              itemBuilder: (context, index) {
                final ep = episodes[index];
                return ListTile(
                  title: Text(ep.title),
                  subtitle: Text('Duración: ${ep.duration}'),
                  trailing: const Icon(Icons.play_arrow),
                  onTap: () {
                    // Navegamos a la página de video del episodio
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VideoPlayerPage(
                          movie: series, // En este caso, series es de tipo Movie
                          episode: ep,   // Y el episodio correspondiente
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
