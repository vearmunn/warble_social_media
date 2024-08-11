import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String postId;
  final String uid;
  final String message;
  final String name;
  final String username;
  final Timestamp timestamp;

  Comment(
      {required this.id,
      required this.postId,
      required this.uid,
      required this.message,
      required this.name,
      required this.username,
      required this.timestamp});

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
        id: doc.id,
        postId: doc['postId'],
        uid: doc['uid'],
        message: doc['message'],
        name: doc['name'],
        username: doc['username'],
        timestamp: doc['timestamp']);
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'uid': uid,
      'message': message,
      'name': name,
      'username': username,
      'timestamp': timestamp
    };
  }
}
