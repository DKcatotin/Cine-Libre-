class Movie {
  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final String genre;
  final String? duration;
  final double? rating;
  final bool isFeatured;
  final String youtubeId;

  Movie({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.genre,
    this.duration,
    this.rating,
    this.isFeatured = false,
    this.youtubeId = '',
  });

  
 
  /// Constructor para convertir los datos desde la API de TMDb
  factory Movie.fromJsonTMDb(Map<String, dynamic> json) {
    // Obtener tráiler de YouTube
    final videos = json['videos']?['results'] as List<dynamic>? ?? [];
    final trailer = videos.firstWhere(
      (video) => video['type'] == 'Trailer' && video['site'] == 'YouTube',
      orElse: () => null,
    );

    return Movie(
      id: json['id'],
      title: json['title'] ?? 'Sin título',
      description: json['overview'] ?? 'Sin descripción',
      imageUrl: json['poster_path'] != null
          ? 'https://image.tmdb.org/t/p/w500${json['poster_path']}'
          : '',
      genre: (json['genres'] as List?)
          ?.map((g) => g['name'].toString())
          .join(', ') ?? 'Desconocido',
      duration: json['runtime'] != null ? '${json['runtime']} min' : 'Desconocida',
      rating: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      isFeatured: (json['vote_average'] ?? 0) >= 7.5,
      youtubeId: trailer != null ? trailer['key'] : '', // ✅ Ahora `youtubeId` se obtiene de TMDB
    );
  }
  // En lib/models/movie.dart:

/// ✅ Se asegura que `fullPosterUrl` sea siempre una imagen válida
String get fullPosterUrl {
  if (imageUrl.isEmpty) {
    return "https://via.placeholder.com/500?text=No+Imagen";
  }
  
  // Si la URL ya empieza con http o https, es una URL completa
  if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
    return imageUrl; // Devolver la URL tal cual
  }
  
  // Solo añadir el prefijo de TMDB si no es una URL completa
  return 'https://image.tmdb.org/t/p/w500$imageUrl';
}
}
