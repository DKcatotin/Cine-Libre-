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

  return Series(
    id: json['id'],
    name: json['name'],
    overview: overviewText.isNotEmpty ? overviewText : "Sin descripción",
    posterPath: json['poster_path'] ?? '',
    voteAverage: (json['vote_average'] is num) ? (json['vote_average'] as num).toDouble() : 0.0,
    genres: (json['genres'] as List?)
        ?.map((g) => g is Map && g['name'] != null ? g['name'].toString() : g.toString())
        .toList()
        .cast<String>() ?? [],
    numberOfSeasons: json['number_of_seasons'],
    numberOfEpisodes: json['number_of_episodes'],
    backdropPath: json['backdrop_path'],
    youtubeId: youtubeId,
  );
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
