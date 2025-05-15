// import 'package:flutter/material.dart';
// import '../services/favorites_service.dart';
// import '../models/movie.dart';
// import '../models/series.dart';

// class ContentCard extends StatefulWidget {
//   final dynamic item;
//   final bool isSeries;
//   final VoidCallback onTap;

//   const ContentCard({
//     super.key,
//     required this.item,
//     required this.isSeries,
//     required this.onTap,
//   });

//   @override
//   State<ContentCard> createState() => _ContentCardState();
// }

// class _ContentCardState extends State<ContentCard> {
//   final FavoritesService _favoritesService = FavoritesService();
//   bool _isFavorite = false;
//   bool _isCheckingFavorite = true;

//   @override
//   void initState() {
//     super.initState();
//     _checkIfFavorite();
//   }

//   Future<void> _checkIfFavorite() async {
//     if (_favoritesService.currentUser == null) {
//       setState(() {
//         _isFavorite = false;
//         _isCheckingFavorite = false;
//       });
//       return;
//     }

//     final id = widget.isSeries
//         ? (widget.item as Series).id.toString()
//         : (widget.item as Movie).id.toString();

//     final result = await _favoritesService.isFavorite(
//       itemId: id,
//       isSeries: widget.isSeries,
//     );

//     if (mounted) {
//       setState(() {
//         _isFavorite = result;
//         _isCheckingFavorite = false;
//       });
//     }
//   }

//   Future<void> _toggleFavorite() async {
//     final item = widget.item;
//     final isSeries = widget.isSeries;
//     late String id;
//     late String title;
//     late String imageUrl;
//     late String description;
//     late String genre;

//     if (isSeries) {
//       final series = item as Series;
//       id = series.id.toString();
//       title = series.name;
//       imageUrl = series.fullPosterUrl;
//       description = series.overview;
//       genre = series.genres.join(', ');
//     } else {
//       final movie = item as Movie;
//       id = movie.id.toString();
//       title = movie.title;
//       imageUrl = movie.fullPosterUrl;
//       description = movie.description;
//       genre = movie.genre;
//     }

//     final result = await _favoritesService.toggleFavorite(
//       id: id,
//       title: title,
//       imageUrl: imageUrl,
//       isSeries: isSeries,
//       description: description,
//       genre: genre,
//     );

//     if (mounted && result) {
//       setState(() {
//         _isFavorite = !_isFavorite;
//       });

//       // Mostrar mensaje
//       final message = _isFavorite
//           ? '${isSeries ? 'Serie' : 'Película'} agregada a favoritos'
//           : '${isSeries ? 'Serie' : 'Película'} eliminada de favoritos';

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: _isFavorite ? Colors.green : Colors.red,
//           duration: const Duration(seconds: 1),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: widget.onTap,
//       child: Card(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         elevation: 4,
//         child: Stack(
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Imagen de portada
//                 ClipRRect(
//                   borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
//                   child: Image.network(
//                     widget.isSeries
//                         ? (widget.item as Series).fullPosterUrl
//                         : (widget.item as Movie).fullPosterUrl,
//                     height: 170,
//                     width: double.infinity,
//                     fit: BoxFit.cover,
//                     errorBuilder: (_, __, ___) => Container(
//                       height: 170,
//                       color: Colors.grey.shade800,
//                       child: const Icon(Icons.broken_image, size: 50, color: Colors.white),
//                     ),
//                   ),
//                 ),
//                 // Título
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text(
//                     widget.isSeries
//                         ? (widget.item as Series).name
//                         : (widget.item as Movie).title,
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//             // Botón de favorito
//             Positioned(
//               top: 5,
//               right: 5,
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.black54,
//                   shape: BoxShape.circle,
//                 ),
//                 child: _isCheckingFavorite
//                     ? const SizedBox(
//                         width: 40,
//                         height: 40,
//                         child: Padding(
//                           padding: EdgeInsets.all(8.0),
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                           ),
//                         ),
//                       )
//                     : IconButton(
//                         icon: Icon(
//                           _isFavorite ? Icons.favorite : Icons.favorite_border,
//                           color: _isFavorite ? Colors.red : Colors.white,
//                         ),
//                         onPressed: _toggleFavorite,
//                         tooltip: _isFavorite ? 'Quitar de favoritos' : 'Agregar a favoritos',
//                       ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }