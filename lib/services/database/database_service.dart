/* 
this class handles:
- user profile
- post message
- likes
- comments
- report / block / delete account
- follow / unfollow
- search users

*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:warble_social_media/models/posts.dart';
import 'package:warble_social_media/models/user_profile.dart';

class DatabaseService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // USER PROFILE
  Future saveUserInfo(String name, String email) async {
    try {
      String uid = _auth.currentUser!.uid;

      String username = email.split('@')[0];

      UserProfile user = UserProfile(
          uid: uid, name: name, username: username, email: email, bio: '');

      final userMap = user.toMap();

      await _firestore.collection('Users').doc(uid).set(userMap);
    } catch (e) {
      throw Exception(e);
    }
  }

  // GET USER INFO
  Future<UserProfile> getUserInfo(String uid) async {
    try {
      final res = await _firestore.collection('Users').doc(uid).get();

      UserProfile userProfile = UserProfile.fromDocument(res);
      return userProfile;
    } catch (e) {
      throw Exception(e);
    }
  }

  // UPDATE BIO
  Future updateBio(String bio) async {
    String uid = _auth.currentUser!.uid;

    try {
      await _firestore.collection('Users').doc(uid).update({'bio': bio});
    } catch (e) {
      throw Exception(e);
    }
  }

  // POST A MESSAGE
  Future postMessage(String message) async {
    String uid = _auth.currentUser!.uid;
    try {
      UserProfile userProfile = await getUserInfo(uid);
      Posts newPost = Posts(
          id: '',
          uid: uid,
          name: userProfile.name,
          username: userProfile.username,
          message: message,
          timestamp: Timestamp.now(),
          likeCount: 0,
          likedBy: []);
      await _firestore.collection('Posts').add(newPost.toMap());
    } catch (e) {
      throw Exception(e);
    }
  }

  // DELETE A POST

  // GET ALL POSTS
  Future<List<Posts>> getAllPosts() async {
    try {
      final res = await _firestore
          .collection('Posts')
          .orderBy('timestamp', descending: true)
          .get();
      return res.docs.map((doc) => Posts.fromDocument(doc)).toList();
    } catch (e) {
      throw Exception(e);
    }
  }

  //GET A POST
}
