import 'package:cine_libre/services/series_service.dart';

class Series {
  final int id;
  final String name;
  final String overview;
  final String posterPath;
  final double voteAverage;
  final List<String> genres;
  final int? numberOfSeasons;
  final int? numberOfEpisodes;
  final String? backdropPath;
  final String youtubeId;

  Series({
    required this.id,
    required this.name,
    required this.overview,
    required this.posterPath,
    required this.voteAverage,
    required this.genres,
    this.numberOfSeasons,
    this.numberOfEpisodes,
    this.backdropPath,
    this.youtubeId = '',
  });

 factory Series.fromJson(Map<String, dynamic> json, {String youtubeId = ''}) {
  String overviewText = json['overview'] ?? '';

  // Si la descripción en español está vacía y hay una en inglés, úsala
  if (overviewText.isEmpty && json.containsKey('original_overview')) {
    overviewText = json['original_overview'];
  }

  List<String> genreNames = [];

  if (json.containsKey('genres')) {
    // Detalles completos (genre: [{id, name}])
    genreNames = (json['genres'] as List?)
        ?.whereType<Map<String, dynamic>>()
        .map((g) => SeriesService.genreTranslation[g['name']] ?? g['name'].toString())
        .toList() ?? [];
  } else if (json.containsKey('genre_ids')) {
    // Lista popular (genre_ids: [18, 10765])
    genreNames = (json['genre_ids'] as List?)
        ?.whereType<int>()
        .map((id) => SeriesService.genreTranslation[id] ?? 'Desconocido')
        .toList() ?? [];
  }

  return Series(
    id: json['id'],
    name: json['name'],
    overview: overviewText.isNotEmpty ? overviewText : "Sin descripción",
    posterPath: json['poster_path'] ?? '',
    voteAverage: (json['vote_average'] is num) ? (json['vote_average'] as num).toDouble() : 0.0,
    genres: genreNames,
    numberOfSeasons: json['number_of_seasons'],
    numberOfEpisodes: json['number_of_episodes'],
    backdropPath: json['backdrop_path'],
    youtubeId: youtubeId,
  );
}

  
String get fullPosterUrl {
  if (posterPath.isEmpty) {
    return "https://via.placeholder.com/500?text=No+Imagen";
  }
  
  // Si la URL ya empieza con http o https, es una URL completa
  if (posterPath.startsWith('http://') || posterPath.startsWith('https://')) {
    return posterPath; // Devolver la URL tal cual
  }
  
  // Solo añadir el prefijo de TMDB si no es una URL completa
  return 'https://image.tmdb.org/t/p/w500$posterPath';
}

// También corregir el método fullBackdropUrl de manera similar:

String get fullBackdropUrl {
  if (backdropPath == null || backdropPath!.isEmpty) {
    return fullPosterUrl;
  }
  
  // Si la URL ya empieza con http o https, es una URL completa
  if (backdropPath!.startsWith('http://') || backdropPath!.startsWith('https://')) {
    return backdropPath!; // Devolver la URL tal cual
  }
  
  // Solo añadir el prefijo de TMDB si no es una URL completa
  return 'https://image.tmdb.org/t/p/w780$backdropPath';
}
}
