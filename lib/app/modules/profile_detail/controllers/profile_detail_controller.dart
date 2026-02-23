import 'package:get/get.dart';

import '../../../data/local/my_shared_pref.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/auth_service.dart';
import '../../settings/controllers/settings_controller.dart';

class ProfileDetailController extends GetxController {
  UserModel? user;
  bool isLoading = false;
  bool isSaving = false;
  bool isChangingPassword = false;

  @override
  void onInit() {
    super.onInit();
    _loadFromCache();
    refreshUser();
  }

  void _loadFromCache() {
    final id = MySharedPref.getInt('user_id') ?? 0;
    final username = MySharedPref.getString('user_name') ?? 'Echoes User';
    final email = MySharedPref.getString('user_email') ?? 'mail@example.com';
    final role = MySharedPref.getUserRole();
    user = UserModel(id: id, username: username, email: email, role: role);
  }

  Future<void> refreshUser() async {
    try {
      isLoading = true;
      update();
      final fetched = await AuthService.instance.fetchCurrentUser();
      if (fetched != null) {
        user = fetched;
        await MySharedPref.setString('user_name', fetched.username);
        await MySharedPref.setString('user_email', fetched.email);
        if (fetched.role != null) {
          await MySharedPref.setUserRole(fetched.role!);
        }
        _syncSettingsController(fetched);
      }
    } catch (_) {
      // ignore network errors silently; cached data already shown
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> updateProfile({
    String? username,
    String? email,
    String? name,
  }) async {
    try {
      isSaving = true;
      update();
      final updated = await AuthService.instance.updateProfile(
        username: username,
        email: email,
        name: name,
      );
      user = updated;
      await MySharedPref.setString('user_name', updated.username);
      await MySharedPref.setString('user_email', updated.email);
      if (updated.role != null) {
        await MySharedPref.setUserRole(updated.role!);
      }
      _syncSettingsController(updated);
      Get.snackbar('success_title'.tr, 'profile_updated'.tr);
    } on AuthConflictException catch (e) {
      Get.snackbar('error_title'.tr, e.message);
    } catch (e) {
      Get.snackbar('error_title'.tr, e.toString());
    } finally {
      isSaving = false;
      update();
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      isChangingPassword = true;
      update();
      await AuthService.instance.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      Get.snackbar('success_title'.tr, 'password_updated'.tr);
    } on InvalidCurrentPasswordException {
      Get.snackbar('error_title'.tr, 'error_invalid_current_password'.tr);
    } on UnauthorizedException {
      Get.snackbar('error_title'.tr, 'error_session_expired'.tr);
    } catch (e) {
      Get.snackbar('error_title'.tr, e.toString());
    } finally {
      isChangingPassword = false;
      update();
    }
  }

  void _syncSettingsController(UserModel updated) {
    if (Get.isRegistered<SettingsController>()) {
      final settings = Get.find<SettingsController>();
      settings
        ..userName = updated.username
        ..userEmail = updated.email
        ..userRole = updated.role ?? settings.userRole;
      settings.update();
    }
  }
}
