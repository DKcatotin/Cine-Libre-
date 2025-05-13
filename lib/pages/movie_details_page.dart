import 'package:flutter/material.dart';
import 'package:cine_libre/models/movie.dart';
import '../pages/video_player_page.dart';

class MovieDetailPage extends StatelessWidget {
  final Movie movie;

  const MovieDetailPage({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(movie.title),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen de la película
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  movie.imageUrl,
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image, size: 100),
                ),
              ),
              const SizedBox(height: 16),

              // Descripción de la película
              Text(
                movie.description,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 16),

              // Géneros de la película
              Text(
                'Géneros: ${movie.genre}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),

              // Duración y Puntuación (opcional)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (movie.duration != null)
                    Text(
                      'Duración: ${movie.duration}',
                      style:
                          const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                    ),
                  if (movie.rating != null)
                    Row(
                      children: [
                        const Icon(Icons.star, size: 18, color: Colors.yellow),
                        Text(
                          '${movie.rating}/10',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Botón para ver tráiler
              if (movie.youtubeId.isNotEmpty)
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VideoPlayerPage(
                          videoUrl: movie.youtubeId,
                        ),
                      ),
                    );
                  },
                  child: const Text('Ver tráiler en YouTube'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
