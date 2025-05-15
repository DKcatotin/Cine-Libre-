import 'package:flutter/material.dart';
import '../services/favorites_service.dart';
import '../models/favorite.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesService = FavoritesService();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Favoritos'),
      ),
      body: StreamBuilder<List<Favorite>>(
        stream: favoritesService.getFavorites(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final favorites = snapshot.data ?? [];
          
          if (favorites.isEmpty) {
            return const Center(
              child: Text('No tienes favoritos todavía'),
            );
          }

          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final favorite = favorites[index];
              return ListTile(
                title: Text(favorite.title),
                subtitle: Text(favorite.type),
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(favorite.imageUrl),
                ),
              );
            },
          );
        },
      ),
    );
  }
}