import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerPage extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerPage({super.key, required this.videoUrl});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late YoutubePlayerController _youtubeController;
  late WebViewController _webViewController;
  bool isYouTube = false;
  late String formattedUrl;

  @override
  void initState() {
    super.initState();
    isYouTube = _isYouTubeUrl(widget.videoUrl);

    // Si es YouTube, transforma el ID en una URL válida
    formattedUrl = isYouTube ? _formatYoutubeUrl(widget.videoUrl) : widget.videoUrl;

    if (isYouTube) {
      final videoId = _extractYoutubeId(formattedUrl);
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
      );
    } else {
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse(formattedUrl));
    }
  }

  @override
  void dispose() {
    if (isYouTube) {
      _youtubeController.dispose();
    }
    super.dispose();
  }

  // Detecta si la URL es de YouTube
  bool _isYouTubeUrl(String url) {
    return url.contains("youtube.com") || url.contains("youtu.be") || url.length == 11;
  }

  // Extrae el ID del video de YouTube
  String _extractYoutubeId(String url) {
    Uri? uri = Uri.tryParse(url);
    if (uri == null) return url; // Si ya es un ID, lo devuelve como está
    if (uri.host.contains("youtu.be")) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : '';
    }
    return uri.queryParameters["v"] ?? '';
  }

  // Convierte un ID en una URL válida de YouTube
  String _formatYoutubeUrl(String videoIdOrUrl) {
    if (videoIdOrUrl.startsWith("http")) {
      return videoIdOrUrl;
    }
    return "https://www.youtube.com/watch?v=$videoIdOrUrl";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reproduciendo video')),
      body: isYouTube
          ? YoutubePlayer(controller: _youtubeController)
          : WebViewWidget(controller: _webViewController),
    );
  }
}
