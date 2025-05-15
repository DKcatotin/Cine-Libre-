import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/favorite.dart';
import '../models/movie.dart';
import '../models/series.dart';

class FavoritesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Referencia a la colección de favoritos
  CollectionReference get _favoritesRef => _firestore.collection('favorites');
  
  // Obtener el ID del usuario actual
  String get userId => _auth.currentUser?.uid ?? '';
  
  // Verificar si el usuario está autenticado
  bool get isAuthenticated => _auth.currentUser != null;
  
  // Obtener todos los favoritos del usuario actual
  Stream<List<Favorite>> getFavorites() {
    if (!isAuthenticated) return Stream.value([]);
    
    return _favoritesRef
        .where('userId', isEqualTo: userId)
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Favorite.fromMap(doc.id, doc.data() as Map<String, dynamic>);
          }).toList();
        });
  }
  
  // Verificar si un contenido específico está en favoritos
  Future<bool> isFavorite(int contentId, String type) async {
    if (!isAuthenticated) return false;
    
    final querySnapshot = await _favoritesRef
        .where('userId', isEqualTo: userId)
        .where('contentId', isEqualTo: contentId)
        .where('type', isEqualTo: type)
        .limit(1)
        .get();
    
    return querySnapshot.docs.isNotEmpty;
  }
 // En lib/services/favorites_service.dart, dentro de addMovieToFavorites:

Future<void> addMovieToFavorites(dynamic movie) async {
  if (!isAuthenticated) return;
  
  // Asegurarse de que la URL de la imagen siempre sea válida
  String imageUrl;
  if (movie is Movie) {
    imageUrl = movie.fullPosterUrl;
  } else {
    // Si no es una instancia de Movie, intentar acceder a la propiedad imageUrl
    imageUrl = movie.imageUrl ?? '';
  }
  
  final favorite = Favorite(
    id: '', // Firestore generará el ID
    userId: userId,
    contentId: movie.id,
    title: movie.title,
    imageUrl: imageUrl,
    type: 'movie',
    addedAt: DateTime.now(),
  );
  
  await _favoritesRef.add(favorite.toMap());
}

// Similar para addSeriesToFavorites:

Future<void> addSeriesToFavorites(dynamic series) async {
  if (!isAuthenticated) return;
  
  // Asegurarse de que la URL de la imagen siempre sea válida
  String imageUrl;
  if (series is Series) {
    imageUrl = series.fullPosterUrl;
  } else {
    // Si no es una instancia de Series, intentar acceder a la propiedad imageUrl
    imageUrl = series.imageUrl ?? '';
  }
  
  final favorite = Favorite(
    id: '', // Firestore generará el ID
    userId: userId,
    contentId: series.id,
    title: series is Series ? series.name : series.title,
    imageUrl: imageUrl,
    type: 'series',
    addedAt: DateTime.now(),
  );
  
  await _favoritesRef.add(favorite.toMap());
}

// Agregar método para alternar favoritos
Future<bool> toggleFavorite(dynamic content, String type) async {
  if (!isAuthenticated) return false;
  
  final contentId = content.id;
  final isCurrentlyFavorite = await isFavorite(contentId, type);
  
  if (isCurrentlyFavorite) {
    await removeFavorite(contentId, type);
    return false;
  } else {
    if (type == 'movie') {
      await addMovieToFavorites(content);
    } else {
      await addSeriesToFavorites(content);
    }
    return true;
  }
}
  // Remover un contenido de favoritos
  Future<void> removeFavorite(int contentId, String type) async {
    if (!isAuthenticated) return;
    
    final querySnapshot = await _favoritesRef
        .where('userId', isEqualTo: userId)
        .where('contentId', isEqualTo: contentId)
        .where('type', isEqualTo: type)
        .get();
    
    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }
}