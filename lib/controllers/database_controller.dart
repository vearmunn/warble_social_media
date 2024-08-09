import 'package:get/get.dart';
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

  Future getAllPosts() async {
    try {
      isLoading.value = true;
      final res = await _db.getAllPosts();
      allPosts.value = res;
      getAllUserPosts(_auth.getCurrentUserID());
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void getAllUserPosts(String uid) {
    allUserPosts.value = allPosts.where((post) => post.uid == uid).toList();
  }
}
