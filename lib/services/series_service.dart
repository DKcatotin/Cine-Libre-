import 'dart:convert';
import 'package:cine_libre/models/series.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SeriesService {
  final String _apiKey = '81580be9c155e2ae0636bc0e7c7e0a97';
  final String _baseUrl = 'https://api.themoviedb.org/3';

  Future<List<dynamic>> fetchPopularSeries() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/tv/popular?api_key=$_apiKey&language=es-ES&page=1'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'];
    } else {
      throw Exception('Error al cargar series populares');
    }
  }

  Future<Map<String, dynamic>> fetchSeriesDetails(int seriesId) async {
  final response = await http.get(
    Uri.parse('$_baseUrl/tv/$seriesId?api_key=$_apiKey&language=es-ES'),
  );

  debugPrint('🛠 Petición realizada a la API: ${response.request?.url}');

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    debugPrint('✅ Respuesta de la API: $data');

    if (data.isEmpty) {
      throw Exception('La API devolvió un objeto vacío.');
    }

    return data;
  } else {
    debugPrint('❌ Error al obtener detalles de la serie: ${response.statusCode}');
    throw Exception('Error al obtener detalles de la serie');
  }
}

Future<String?> fetchEpisodeYoutubeUrl(int seriesId, int seasonNumber, int episodeNumber) async {
  final response = await http.get(
    Uri.parse('$_baseUrl/tv/$seriesId/season/$seasonNumber/episode/$episodeNumber/videos?api_key=$_apiKey&language=es-ES'),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final videos = data['results'] as List<dynamic>;
    final trailer = videos.firstWhere(
      (video) => video['site'] == 'YouTube' && video['type'] == 'Trailer',
      orElse: () => null,
    );
    return trailer != null ? 'https://www.youtube.com/watch?v=${trailer['key']}' : null;
  } else {
    throw Exception('Error al obtener video del episodio');
  }
}

  Future<List<dynamic>> fetchSeriesVideos(int seriesId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/tv/$seriesId/videos?api_key=$_apiKey&language=es-ES'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'];
    } else {
      throw Exception('Error al obtener videos de la serie');
    }
  }
  Future<Map<String, dynamic>> fetchSeasonEpisodes(int seriesId, int seasonNumber) async {
  final response = await http.get(
    Uri.parse('$_baseUrl/tv/$seriesId/season/$seasonNumber?api_key=$_apiKey&language=es-ES'),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);

    // Extraer detalles de episodios con descripción y duración
    data['episodes'] = (data['episodes'] as List<dynamic>?)
        ?.map((ep) => {
          'name': ep['name'],
          'runtime': ep['runtime'] ?? "Desconocido",
          'overview': ep['overview'] ?? "No hay descripción disponible",
          'videoUrl': ep['video_url'] ?? '',
        })
        .toList();

    return data;
  } else {
    throw Exception('Error al obtener los episodios de la temporada');
  }
}
Future<Series> fetchFullSeriesDetails(int seriesId) async {
  final detailsResponse = await http.get(
    Uri.parse('$_baseUrl/tv/$seriesId?api_key=$_apiKey&language=es-ES'),
  );

  if (detailsResponse.statusCode != 200) {
    throw Exception('Error al obtener detalles de la serie');
  }

  final detailsJson = json.decode(detailsResponse.body);

  // Obtener videos
  final videosResponse = await http.get(
    Uri.parse('$_baseUrl/tv/$seriesId/videos?api_key=$_apiKey&language=es-ES'),
  );

  String youtubeId = '';
  if (videosResponse.statusCode == 200) {
    final videosJson = json.decode(videosResponse.body);
    final videos = videosJson['results'] as List<dynamic>;
    final trailer = videos.firstWhere(
      (video) => video['site'] == 'YouTube' && video['type'] == 'Trailer',
      orElse: () => null,
    );
    if (trailer != null) {
      youtubeId = trailer['key'];
    }
  }
  return Series.fromJson(detailsJson, youtubeId: youtubeId);
}
}
