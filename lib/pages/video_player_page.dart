import 'package:cine_libre/models/episode.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:cine_libre/models/movie.dart';

class VideoPlayerPage extends StatefulWidget {
  final Movie movie;
  final Episode episode;

  const VideoPlayerPage({
    super.key,
    required this.movie,
    required this.episode,
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late YoutubePlayerController _controller;

  String extractYoutubeId(String urlOrId) {
    if (urlOrId.contains('youtube.com') || urlOrId.contains('youtu.be')) {
      Uri? uri = Uri.tryParse(urlOrId);
      if (uri == null) return '';
      if (uri.host.contains('youtu.be')) {
        return uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : '';
      }
      return uri.queryParameters['v'] ?? '';
    }
    return urlOrId;
  }

  @override
  void initState() {
    super.initState();
    final videoId = widget.movie.isSeries
        ? extractYoutubeId(widget.episode.videoUrl)
        : widget.movie.youtubeId!;
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(controller: _controller),
      builder: (context, player) {
        return Scaffold(
          appBar: AppBar(title: Text(widget.movie.title)),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              player,
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.episode.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (!widget.movie.isSeries) ...[
                      const SizedBox(height: 8),
                      Text(
                        widget.movie.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ]
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
