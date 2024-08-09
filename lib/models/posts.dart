import 'package:cloud_firestore/cloud_firestore.dart';

class Posts {
  final String id;
  final String uid;
  final String name;
  final String username;
  final String message;
  final Timestamp timestamp;
  final int likeCount;
  final List<String> likedBy;

  Posts(
      {required this.id,
      required this.uid,
      required this.name,
      required this.username,
      required this.message,
      required this.timestamp,
      required this.likeCount,
      required this.likedBy});

  factory Posts.fromDocument(DocumentSnapshot doc) {
    return Posts(
        id: doc.id,
        uid: doc['uid'],
        name: doc['name'],
        username: doc['username'],
        message: doc['message'],
        timestamp: doc['timestamp'],
        likeCount: doc['likeCount'],
        likedBy: List<String>.from(doc['likedBy'] ?? []));
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'username': username,
      'message': message,
      'timestamp': timestamp,
      'likeCount': likeCount,
      'likedBy': likedBy
    };
  }
}
