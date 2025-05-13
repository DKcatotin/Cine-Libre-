class Series {
  final int id;
  final String name;
  final String overview;
  final String posterPath;
  final double voteAverage;
  final List<dynamic>? genres;
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
    this.genres,
    this.numberOfSeasons,
    this.numberOfEpisodes,
    this.backdropPath,
    this.youtubeId = '',
  });

  factory Series.fromJson(Map<String, dynamic> json, {String youtubeId = ''}) {
    return Series(
      id: json['id'],
      name: json['name'],
      overview: json['overview'] ?? "Sin descripción",
      posterPath: json['poster_path'] ?? '',
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      genres: (json['genres'] as List<dynamic>?)
              ?.map((genre) => genre['name'].toString())
              .toList() ?? [],
      numberOfSeasons: json['number_of_seasons'],
      numberOfEpisodes: json['number_of_episodes'],
      backdropPath: json['backdrop_path'],
      youtubeId: youtubeId,
    );
  }

  List<Map<String, dynamic>> getEpisodesFromJson(List<dynamic>? episodesJson) {
    return episodesJson?.map((ep) => {
      'name': ep['name'],
      'runtime': ep['runtime'] ?? "Duración desconocida",
      'overview': ep['overview'] ?? "No hay descripción disponible",
      'videoUrl': ep['video_url'] ?? '',
    }).toList() ?? [];
  }

  String get fullPosterUrl {
    if (posterPath.isNotEmpty && posterPath != "example.jpg") {
      return 'https://image.tmdb.org/t/p/w500$posterPath';
    }
    return "https://via.placeholder.com/500?text=No+Imagen";
  }

  String get fullBackdropUrl {
    if (backdropPath != null && backdropPath!.isNotEmpty && backdropPath != "example.jpg") {
      return 'https://image.tmdb.org/t/p/w780$backdropPath';
    }
    return fullPosterUrl;
  }
}
