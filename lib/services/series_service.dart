import 'dart:convert';
import 'package:cine_libre/models/series.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SeriesService {
  static const String _apiKey = '81580be9c155e2ae0636bc0e7c7e0a97';
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  static final Map<int, String> genreTranslation = {
    10759: "Acción y aventura",
  16: "Animación",
  35: "Comedia",
  80: "Crimen",
  99: "Documental",
  18: "Drama",
  10751: "Familiar",
  10762: "Infantil",
  9648: "Misterio",
  10764: "Reality Show",
  10765: "Ciencia ficción y fantasía",
  10766: "Telenovela",
  10767: "Talk Show",
  10768: "Guerra y política",
  37: "Oeste",
  };


  String resumenCorto(String overview, {int maxLength = 100}) {
    if (overview.isEmpty) return "No hay descripción disponible.";
    return overview.length <= maxLength
        ? overview
        : '${overview.substring(0, maxLength).trim()}...';
  }

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

    // Verificar si la descripción en español está vacía
  if (data['overview'] == null || data['overview'].trim().isEmpty) {
  final englishResponse = await http.get(
    Uri.parse('$_baseUrl/tv/$seriesId?api_key=$_apiKey&language=en-US'),
  );

  if (englishResponse.statusCode == 200) {
    final englishData = json.decode(englishResponse.body);
    if (englishData['overview'] != null && englishData['overview'].isNotEmpty) {
      data['overview'] = await translateTextLibre(englishData['overview']); 
      debugPrint("🔄 Descripción traducida: ${data['overview']}"); // Verifica que se traduzca correctamente
    }
  }
}
    // Traducir géneros
   data['genres'] = (data['genres'] as List<dynamic>?)
    ?.map((genre) => genreTranslation[genre['name']] ?? genre['name'])
    .toList() ?? []; // Si es null, asignar una lista vacía

    return data;
  } else {
    debugPrint('❌ Error al obtener detalles de la serie: ${response.statusCode}');
    throw Exception('Error al obtener detalles de la serie');
  }
}

Future<String> translateTextLibre(String text) async {
  final response = await http.post(
    Uri.parse('https://libretranslate.com/translate'),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "q": text,
      "source": "en",
      "target": "es",
      "format": "text"
    }),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['translatedText'];
  } else {
    return text; // Usa el original si hay error
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

      // Agregar resumen corto a los episodios
      data['episodes'] = (data['episodes'] as List<dynamic>?)
          ?.map((ep) => {
                'name': ep['name'],
                'runtime': ep['runtime'] ?? "Desconocido",
                'overview': resumenCorto(ep['overview'] ?? ""),
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

    // Traducir géneros
    detailsJson['genres'] = (detailsJson['genres'] as List<dynamic>?)
        ?.map((genre) => genreTranslation[genre['name']] ?? genre['name'])
        .toList();

    // Obtener trailer
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
