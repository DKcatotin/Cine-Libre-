// Actualización para lib/pages/movie_details_page.dart
import 'package:flutter/material.dart';
import 'package:cine_libre/models/movie.dart';
import '../pages/video_player_page.dart';
import '../services/favorites_service.dart';

class MovieDetailPage extends StatefulWidget {
  final Movie movie;

  const MovieDetailPage({super.key, required this.movie});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  final FavoritesService _favoritesService = FavoritesService();
  bool _isFavorite = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final isFavorite = await _favoritesService.isFavorite(widget.movie.id, 'movie');
      if (mounted) {
        setState(() {
          _isFavorite = isFavorite;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error al verificar estado de favorito: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      final newStatus = await _favoritesService.toggleFavorite(widget.movie, 'movie');
      if (mounted) {
        setState(() {
          _isFavorite = newStatus;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isFavorite 
                ? '${widget.movie.title} añadido a favoritos'
                : '${widget.movie.title} eliminado de favoritos',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie.title),
        centerTitle: true,
        actions: [
          _isLoading
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // El resto del código permanece igual
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.movie.imageUrl,
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image, size: 100),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                widget.movie.description,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 16),

              Text(
                'Géneros: ${widget.movie.genre}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.movie.duration != null)
                    Text(
                      'Duración: ${widget.movie.duration}',
                      style:
                          const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                    ),
                  if (widget.movie.rating != null)
                    Row(
                      children: [
                        const Icon(Icons.star, size: 18, color: Colors.yellow),
                        Text(
                          '${widget.movie.rating}/10',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 16),

              if (widget.movie.youtubeId.isNotEmpty)
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VideoPlayerPage(
                          videoUrl: widget.movie.youtubeId,
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