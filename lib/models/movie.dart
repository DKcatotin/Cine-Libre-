import 'package:cine_libre/models/episode.dart';

class Movie {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String genre;
  final bool isFeatured;
  final bool isSeries;

  // Solo para películas
  final String? youtubeId;
  final List<Episode> episodes;

  Movie({
  required this.id,
  required this.title,
  required this.description,
  required this.imageUrl,
  required this.genre,
  this.isFeatured = false,
  this.isSeries = false,
  this.youtubeId,
  this.episodes = const [], // <- valor por defecto
});
}
