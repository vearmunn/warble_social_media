import 'package:get/get.dart';
import 'package:warble_social_media/services/auth/auth_service.dart';
import 'package:warble_social_media/services/database/database_service.dart';

class AuthController extends GetxController {
  final _auth = AuthService();
  final _db = DatabaseService();

  var isLoading = false.obs;

  void loginUser(String email, String password) async {
    try {
      isLoading.toggle();
      await _auth.login(email, password);
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  void registerUser(
      {required String name,
      required String email,
      required String password}) async {
    try {
      isLoading.toggle();
      await _auth.register(email, password);
      await _db.saveUserInfo(name, email);
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  void logoutUser() async {
    _auth.logout();
  }
}
