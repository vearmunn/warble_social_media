import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:warble_social_media/models/comment.dart';
import 'package:warble_social_media/models/user_profile.dart';

import '../models/posts.dart';
import '../services/auth/auth_service.dart';
import '../services/database/database_service.dart';

class DatabaseController extends GetxController {
// VARIABLES ----------------------------------------------------------------------
  final _auth = AuthService();
  final _db = DatabaseService();

  var isLoading = false.obs;
  var errMessage = ''.obs;
  Rx<UserProfile> userInfo =
      UserProfile(bio: '', email: '', name: '', uid: '', username: '').obs;
  RxList<Posts> allPosts = <Posts>[].obs;
  RxList<Posts> allUserPosts = <Posts>[].obs;
  RxList<Posts> allFollowingPosts = <Posts>[].obs;

  // local list to track posts liked by current user
  RxList<String> likedPosts = <String>[].obs;

  // local map to track counts for each post
  RxMap<String, int> likedCounts = <String, int>{}.obs;

  RxList<Comment> allComments = <Comment>[].obs;
  RxMap<String, List<Comment>> specificPostsComments =
      <String, List<Comment>>{}.obs;

  RxList<String> blockedUserIds = <String>[].obs;
  RxList<UserProfile> blockedUserList = <UserProfile>[].obs;

  RxMap<String, List<String>> followers = <String, List<String>>{}.obs;
  RxMap<String, List<String>> following = <String, List<String>>{}.obs;
  RxMap<String, int> followersCount = <String, int>{}.obs;
  RxMap<String, int> followingCount = <String, int>{}.obs;
  RxBool isFollowing = false.obs;
  RxList<UserProfile> followerProfiles = <UserProfile>[].obs;
  RxList<UserProfile> followingProfiles = <UserProfile>[].obs;

  RxList<UserProfile> searchResults = <UserProfile>[].obs;
  RxBool isSearching = false.obs;

// METHODS ----------------------------------------------------------------------
  Future getUserInfo(String uid) async {
    try {
      isLoading.value = true;
      final res = await _db.getUserInfo(uid);
      userInfo.value = res;
      await getFollowers(uid);
      await getFollowing(uid);
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

      // get following posts
      await getAllFollowingPosts();

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

  Future getAllFollowingPosts() async {
    final currentUid = _auth.getCurrentUserID();
    isLoading.value = true;
    final followinguids = await _db.getUserFollowingUids(currentUid);
    allFollowingPosts.value = allPosts
        .where((post) =>
            followinguids.contains(post.uid) || post.uid == currentUid)
        .toList();
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

  /*
  
  FOLLOW
  
  */

  // get counts for followers & following locally: fiven a uid
  int getFollowerCount(String uid) => followersCount[uid] ?? 0;
  int getFollowingCount(String uid) => followingCount[uid] ?? 0;

  // load followers
  Future getFollowers(String uid) async {
    try {
      final currentUserID = _auth.getCurrentUserID();
      isLoading.value = true;

      // get the list of follower uids from firebase
      final res = await _db.getUsersFollowerUids(uid);

      // update local data
      followers[uid] = res;
      followersCount[uid] = res.length;
      isFollowing.value = followers[uid]!.contains(currentUserID);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // load following
  Future getFollowing(String uid) async {
    try {
      isLoading.value = true;

      // get the list of following uids from firebase
      final res = await _db.getUserFollowingUids(uid);

      // update local data
      following[uid] = res;
      followingCount[uid] = res.length;
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // follow user
  Future followUser(String targetUid) async {
    // get current uid
    final currentUid = _auth.getCurrentUserID();

    // initilize with empty list if null
    followers.putIfAbsent(currentUid, () => []);
    following.putIfAbsent(currentUid, () => []);

    /*
   
    optimistic UI changes : Update the local data & revert back if database request fails
   
    */

    // follow if current user is not one of the target user's followers
    if (!followers[targetUid]!.contains(currentUid)) {
      // add current user to target user's follower list
      followers[targetUid]?.add(currentUid);

      // update follower count
      followersCount[targetUid] = (followersCount[targetUid] ?? 0) + 1;

      // add target user to current user's following list
      following[currentUid]?.add(targetUid);

      // update following count
      followingCount[currentUid] = (followingCount[currentUid] ?? 0) + 1;

      isFollowing.value = true;
    }

    /* 
    
     UI has been optimistically updated above with local data.
     Now let's try to make this request to our database
    
    */

    try {
      await _db.followUser(targetUid);
      await _db.getUsersFollowerUids(currentUid);
      await _db.getUserFollowingUids(currentUid);
    }

    // if there is an error... revert back to original
    catch (e) {
      // remove current user from target user's followers
      followers[targetUid]?.remove(currentUid);

      // update follower count
      followersCount[targetUid] = (followersCount[targetUid] ?? 0) - 1;

      // remove target user from current user's following
      following[currentUid]?.remove(targetUid);

      // update following count
      followingCount[currentUid] = (followingCount[currentUid] ?? 0) - 1;
    }
  }

  // unfollow user
  Future unfollowUser(String targetUid) async {
    // get current uid
    final currentUid = _auth.getCurrentUserID();

    // initilize with empty list if null
    followers.putIfAbsent(currentUid, () => []);
    following.putIfAbsent(currentUid, () => []);

    /*
   
    optimistic UI changes : Update the local data & revert back if database request fails
   
    */

    // unfollow if the current user is following the target user
    if (followers[targetUid]!.contains(currentUid)) {
      // remove current user to target user's follower list
      followers[targetUid]?.remove(currentUid);

      // update follower count
      followersCount[targetUid] = (followersCount[targetUid] ?? 0) - 1;

      // remove target user to current user's following list
      following[currentUid]?.remove(targetUid);

      // update following count
      followingCount[currentUid] = (followingCount[currentUid] ?? 0) - 1;

      isFollowing.value = false;
    }

    /* 
    
     UI has been optimistically updated above with local data.
     Now let's try to make this request to our database
    
    */

    try {
      await _db.unfollowUser(targetUid);
      await _db.getUsersFollowerUids(currentUid);
      await _db.getUserFollowingUids(currentUid);
    }

    // if there is an error... revert back to original
    catch (e) {
      // add current user from target user's followers
      followers[targetUid]?.add(currentUid);

      // update follower count
      followersCount[targetUid] = (followersCount[targetUid] ?? 0) + 1;

      // add target user from current user's following
      following[currentUid]?.add(targetUid);

      // update following count
      followingCount[currentUid] = (followingCount[currentUid] ?? 0) + 1;
    }
  }

  // is current user following target user?
  // RxBool isFollowing(String uid) {
  //   final currentUid = _auth.getCurrentUserID();
  //   return followers[uid]?.contains(currentUid) ?? false;
  // }

  Future loadFollowerPorfiles(String uid) async {
    followerProfiles.clear();
    try {
      isLoading.value = true;
      for (var followerId in followers[uid]!) {
        UserProfile? followerProfile = await _db.getUserInfo(followerId);
        followerProfiles.add(followerProfile);
      }
    } catch (e) {
      isLoading.value = false;
      errMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future loadFollowingPorfiles(String uid) async {
    followingProfiles.clear();
    try {
      isLoading.value = true;
      for (var followingId in following[uid]!) {
        UserProfile? followingProfile = await _db.getUserInfo(followingId);
        followingProfiles.add(followingProfile);
      }
    } catch (e) {
      isLoading.value = false;
      errMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future searchUsers(String searchTerm) async {
    try {
      isSearching.value = true;
      isLoading.value = true;
      final res = await _db.searchUsers(searchTerm);
      searchResults.value = res;
    } catch (e) {
      isLoading.value = false;
      errMessage.value = e.toString();
      searchResults.value = [];
    } finally {
      isLoading.value = false;
    }
  }
}
