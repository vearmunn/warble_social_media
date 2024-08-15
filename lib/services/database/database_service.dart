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
import 'package:warble_social_media/models/comment.dart';
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
  Future deletePost(String id) async {
    try {
      await _firestore.collection('Posts').doc(id).delete();
    } catch (e) {
      throw Exception(e);
    }
  }

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

  // TOOGLE LIKE
  Future toogleLike(String postID) async {
    try {
      String uid = _auth.currentUser!.uid;

      // go to doc for this post
      DocumentReference postDoc = _firestore.collection('Posts').doc(postID);

      // execute like
      await _firestore.runTransaction((transaction) async {
        // get post data
        DocumentSnapshot postSnapshot = await transaction.get(postDoc);

        // get like of users who like this post
        List<String> likedBy = List<String>.from(postSnapshot['likedBy'] ?? []);

        // get like count
        int currentLikeCount = postSnapshot['likeCount'];

        // if user has not liked this post yet -> then like | if user has liked this post -> then unlike
        if (!likedBy.contains(uid)) {
          likedBy.add(uid);
          currentLikeCount++;
        } else {
          likedBy.remove(uid);
          currentLikeCount--;
        }

        // update in firebase
        transaction.update(
            postDoc, {'likedBy': likedBy, 'likeCount': currentLikeCount});
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  Future addComment(String postID, String message) async {
    try {
      String uid = _auth.currentUser!.uid;
      UserProfile user = await getUserInfo(uid);

      Comment newComment = Comment(
          id: '',
          postId: postID,
          uid: uid,
          message: message,
          name: user.name,
          username: user.username,
          timestamp: Timestamp.now());
      await _firestore.collection('Comments').add(newComment.toMap());
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<Comment>> getComments() async {
    try {
      final res = await _firestore.collection('Comments').get();
      return res.docs.map((doc) => Comment.fromDocument(doc)).toList();
    } catch (e) {
      throw Exception(e);
    }
  }

  // DELETE A POST
  Future deleteComment(String id) async {
    try {
      await _firestore.collection('Comments').doc(id).delete();
    } catch (e) {
      throw Exception(e);
    }
  }

  // REPORT USER
  Future reportUser(String userID, String postID, String commentID) async {
    String uid = _auth.currentUser!.uid;
    try {
      final newReport = {
        'reportedBy': uid,
        'userId': userID,
        'postId': postID,
        'commentId': commentID,
        'timestamp': FieldValue.serverTimestamp()
      };

      await _firestore.collection('Reports').add(newReport);
    } catch (e) {
      print('REPORT ERROR$e');
      throw Exception(e);
    }
  }

  // BLOCK USER
  Future blockUser(String uid) async {
    String currentUid = _auth.currentUser!.uid;
    try {
      await _firestore
          .collection('Users')
          .doc(currentUid)
          .collection('BlockedUsers')
          .doc(uid)
          .set({});
    } catch (e) {
      throw Exception(e);
    }
  }

  // UNBLOCK USER
  Future unblockUser(String uid) async {
    String currentUid = _auth.currentUser!.uid;
    try {
      await _firestore
          .collection('Users')
          .doc(currentUid)
          .collection('BlockedUsers')
          .doc(uid)
          .delete();
    } catch (e) {
      throw Exception(e);
    }
  }

  // GET LIST OF BLOCKED USER IDs
  Future<List<String>> getListBlockedUserIds() async {
    String currentUid = _auth.currentUser!.uid;
    try {
      final res = await _firestore
          .collection('Users')
          .doc(currentUid)
          .collection('BlockedUsers')
          .get();
      return res.docs.map((doc) => doc.id).toList();
    } catch (e) {
      throw Exception(e);
    }
  }

  /* 
  
  FOLLOW
  
  */

  // Follow User
  Future followUser(String uid) async {
    final currentUserId = _auth.currentUser!.uid;

    try {
      // add target user to the current user's following
      await _firestore
          .collection('Users')
          .doc(currentUserId)
          .collection('Following')
          .doc(uid)
          .set({});

      // add current user to the target user's followers
      await _firestore
          .collection('Users')
          .doc(uid)
          .collection('Followers')
          .doc(currentUserId)
          .set({});
    } catch (e) {
      throw Exception(e);
    }
  }

  // Unfollow User
  Future unfollowUser(String uid) async {
    final currentUserId = _auth.currentUser!.uid;

    try {
      // remove target user from the current user's following
      _firestore
          .collection('Users')
          .doc(currentUserId)
          .collection('Following')
          .doc(uid)
          .delete();

      // remove current user from the target user's followers
      _firestore
          .collection('Users')
          .doc(uid)
          .collection('Followers')
          .doc(currentUserId)
          .delete();
    } catch (e) {
      throw Exception(e);
    }
  }

  // Get a user's followers: list of uids
  Future<List<String>> getUsersFollowerUids(String uid) async {
    try {
      final res = await _firestore
          .collection('Users')
          .doc(uid)
          .collection('Followers')
          .get();
      return res.docs.map((doc) => doc.id).toList();
    } catch (e) {
      throw Exception(e);
    }
  }

  // Get a user's following: list of uids
  Future<List<String>> getUserFollowingUids(String uid) async {
    try {
      final res = await _firestore
          .collection('Users')
          .doc(uid)
          .collection('Following')
          .get();
      return res.docs.map((doc) => doc.id).toList();
    } catch (e) {
      throw Exception(e);
    }
  }

  // SEARCH

  Future<List<UserProfile>> searchUsers(String searchTerm) async {
    try {
      final res = await _firestore
          .collection('Users')
          .where('username', isGreaterThanOrEqualTo: searchTerm)
          .where('username', isLessThanOrEqualTo: '$searchTerm\uf8ff')
          .get();

      return res.docs.map((doc) => UserProfile.fromDocument(doc)).toList();
    } catch (e) {
      return [];
    }
  }
}
