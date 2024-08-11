import 'package:get/get.dart';
import 'package:warble_social_media/models/comment.dart';
import 'package:warble_social_media/models/user_profile.dart';

import '../models/posts.dart';
import '../services/auth/auth_service.dart';
import '../services/database/database_service.dart';

class DatabaseController extends GetxController {
  final _auth = AuthService();
  final _db = DatabaseService();

  var isLoading = false.obs;
  Rx<UserProfile> userInfo =
      UserProfile(bio: '', email: '', name: '', uid: '', username: '').obs;
  RxList<Posts> allPosts = <Posts>[].obs;
  RxList<Posts> allUserPosts = <Posts>[].obs;

  // local list to track posts liked by current user
  RxList<String> likedPosts = <String>[].obs;

  // local map to track counts for each post
  RxMap<String, int> likedCounts = <String, int>{}.obs;

  RxList<Comment> allComments = <Comment>[].obs;
  RxMap<String, List<Comment>> specificPostsComments =
      <String, List<Comment>>{}.obs;

  RxList<String> blockedUserIds = <String>[].obs;
  RxList<UserProfile> blockedUserList = <UserProfile>[].obs;

  Future getUserInfo(String uid) async {
    try {
      isLoading.value = true;
      final res = await _db.getUserInfo(uid);
      userInfo.value = res;
      getAllUserPosts(uid);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future updateBio(String bio) async {
    try {
      isLoading.value = true;
      await _db.updateBio(bio);

      await getUserInfo(_auth.getCurrentUserID());
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future addPost(String message) async {
    try {
      isLoading.value = true;
      await _db.postMessage(message);
      await getAllPosts();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future deletePost(String id) async {
    try {
      isLoading.value = true;
      await _db.deletePost(id);
      await getAllPosts();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future getAllPosts() async {
    try {
      isLoading.value = true;

      // get list of blocked users
      await getBlockedUserIds();

      // get list of all posts
      final res = await _db.getAllPosts();
      allPosts.value = res;

      // filter posts, only showing posts whom users are not blocked by current user
      allPosts.value =
          allPosts.where((post) => !blockedUserIds.contains(post.uid)).toList();

      // get current user posts
      getAllUserPosts(_auth.getCurrentUserID());

      initializeLikeMap();
      initializeCommentMap();

      // get all comments
      await getAllComments();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void getAllUserPosts(String uid) {
    allUserPosts.value = allPosts.where((post) => post.uid == uid).toList();
  }

  void initializeLikeMap() {
    final currentUserID = _auth.getCurrentUserID();

    // clear liked posts for when new user signs in
    likedPosts.clear();

    for (var post in allPosts) {
      // update like count map
      likedCounts[post.id] = post.likeCount;

      // if the current user liked this post
      if (post.likedBy.contains(currentUserID)) {
        // add this post id to local list of liked posts
        likedPosts.add(post.id);
      }
    }
  }

  // does current user like this post?
  bool isPostLikedByCurrentUser(String postID) => likedPosts.contains(postID);

  Future toggleLike(String postID) async {
    /* 
    
    This first part will update the local values first so that the UI will fell
    immediate and responsive. We will update UI optimistically, and revert back
    if anything goes wrong while writing to the database.

    Optimistically updating the local values like this is important, because:
    reading and writing from the database takes some time. So we dont want to
    give the user a slow lagged experience.

    */

    // store original values in case it fails
    final likedPostsOriginal = likedPosts;
    final likedCountsOriginal = likedCounts;

    // perform like / unlike
    if (likedPosts.contains(postID)) {
      likedPosts.remove(postID);
      likedCounts[postID] = (likedCounts[postID] ?? 0) - 1;
    } else {
      likedPosts.add(postID);
      likedCounts[postID] = (likedCounts[postID] ?? 0) + 1;
    }

    // Now let's try to update it in the database

    try {
      await _db.toogleLike(postID);
    } catch (e) {
      //revert back to initial state if update fails
      likedPosts = likedPostsOriginal;
      likedCounts = likedCountsOriginal;
    }
  }

  Future addComment(String postID, String message) async {
    try {
      isLoading.value = true;
      await _db.addComment(postID, message);
      await getAllPosts();
      // getSpecificCommentsofPost(postID);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future getAllComments() async {
    try {
      isLoading.value = true;
      final res = await _db.getComments();
      allComments.value = res;
      allComments.value = allComments
          .where((comment) => !blockedUserIds.contains(comment.uid))
          .toList();
      getPostsComments();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void initializeCommentMap() {
    for (var post in allPosts) {
      specificPostsComments[post.id] = [];
    }
  }

  void getPostsComments() {
    for (var comment in allComments) {
      specificPostsComments[comment.postId] =
          allComments.where((item) => item.postId == comment.postId).toList();
      specificPostsComments[comment.postId]!
          .sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }
  }

  Future deleteComment(String commentID) async {
    try {
      isLoading.value = true;
      await _db.deleteComment(commentID);
      await getAllPosts();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future reportUser(String userID, String postID, String commentID) async {
    try {
      isLoading.value = true;
      await _db.reportUser(userID, postID, commentID);
      Get.snackbar('Success', 'User reported!');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future blockUser(String userID) async {
    try {
      isLoading.value = true;
      await _db.blockUser(userID);
      await getAllPosts();
      Get.snackbar('Success', 'User blocked!');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future getBlockedUserIds() async {
    try {
      isLoading.value = true;
      final res = await _db.getListBlockedUserIds();
      blockedUserIds.value = res;
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future getBlockedUsersData() async {
    try {
      isLoading.value = true;

      final res =
          await Future.wait(blockedUserIds.map((id) => _db.getUserInfo(id)));
      blockedUserList.value = res.whereType<UserProfile>().toList();
      print(blockedUserList);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future unblockUser(String uid, String name) async {
    try {
      isLoading.value = true;

      await _db.unblockUser(uid);
      await getAllPosts();
      await getBlockedUsersData();
      Get.snackbar('Success', '$name is unblocked!');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
