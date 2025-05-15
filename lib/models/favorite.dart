import 'package:cloud_firestore/cloud_firestore.dart';

class Favorite {
  final String id;
  final String userId;
  final int contentId;
  final String title;
  final String imageUrl;
  final String type; // 'movie' o 'series'
  final DateTime addedAt;

  Favorite({
    required this.id,
    required this.userId,
    required this.contentId,
    required this.title,
    required this.imageUrl,
    required this.type,
    required this.addedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'contentId': contentId,
      'title': title,
      'imageUrl': imageUrl,
      'type': type,
      'addedAt': addedAt,
    };
  }

  factory Favorite.fromMap(String id, Map<String, dynamic> map) {
  DateTime getDateTime() {
    final addedAt = map['addedAt'];
    if (addedAt is Timestamp) {
      return addedAt.toDate();
    } else if (addedAt is DateTime) {
      return addedAt;
    } else {
      return DateTime.now();
    }
  }

  return Favorite(
    id: id,
    userId: map['userId'] ?? '',
    contentId: map['contentId'] ?? 0,
    title: map['title'] ?? '',
    imageUrl: map['imageUrl'] ?? '',
    type: map['type'] ?? 'movie',
    addedAt: getDateTime(),
  );
}
}