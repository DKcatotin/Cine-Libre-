import 'dart:convert';
import 'package:cine_libre/services/series_service.dart';
import 'package:http/http.dart' as http;
import '../models/movie.dart';
import '../models/series.dart';

class TMDbService {
  static const String _apiKey = '81580be9c155e2ae0636bc0e7c7e0a97';
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  Future<List<Movie>> fetchPopularMovies() async {
    final url = Uri.parse('$_baseUrl/movie/popular?api_key=$_apiKey&language=es-ES');
    
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'] ?? [];

      return Future.wait(results.map((movieJson) => _completeMovieData(movieJson)).toList());
    } else {
      throw Exception('Error al cargar películas populares: ${response.statusCode}');
    }
  }

  Future<List<Series>> fetchPopularSeries() async {
  final response = await http.get(
    Uri.parse('$_baseUrl/tv/popular?api_key=$_apiKey&language=es-ES'),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['results'].map<Series>((json) => Series.fromJson(json)).toList();
  } else {
    throw Exception('Error al cargar series populares');
  }
}


  Future<Movie> _completeMovieData(Map<String, dynamic> json) async {
    final int id = json['id']; // ✅ Ahora es `int`

    // Obtener información detallada con idioma en español
    final detailsUrl = Uri.parse('$_baseUrl/movie/$id?api_key=$_apiKey&language=es-ES');
    final detailsResponse = await http.get(detailsUrl);
    final detailsData = detailsResponse.statusCode == 200 ? jsonDecode(detailsResponse.body) : {};

    // Obtener tráiler de YouTube
    final videosUrl = Uri.parse('$_baseUrl/movie/$id/videos?api_key=$_apiKey&language=es-ES');
    final videosResponse = await http.get(videosUrl);
    final videosData = videosResponse.statusCode == 200 ? jsonDecode(videosResponse.body) : {};
    final trailer = (videosData['results'] as List?)?.firstWhere(
      (video) => video['type'] == 'Trailer',
      orElse: () => null,
    );

    return Movie(
      id: id,
      title: detailsData['title'] ?? 'Sin título',
      description: detailsData['overview'] ?? 'Sin descripción',
      youtubeId: trailer != null ? trailer['key'] : '',
      imageUrl: detailsData['poster_path'] != null
          ? 'https://image.tmdb.org/t/p/w500${detailsData['poster_path']}'
          : '',
      genre: (detailsData['genres'] as List?)
      ?.map((g) => SeriesService.genreTranslation[g['name']] ?? g['name'])
      .join(', ') ?? 'Desconocido',
      duration: detailsData['runtime'] != null ? '${detailsData['runtime']} min' : 'Desconocida',
      rating: (detailsData['vote_average'] as num?)?.toDouble() ?? 0.0,
      isFeatured: (detailsData['vote_average'] ?? 0) >= 7.5,
    );
  }
}
