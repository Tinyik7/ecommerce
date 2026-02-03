import 'package:get/get.dart';

import '../../../data/local/my_shared_pref.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/auth_service.dart';
import '../../settings/controllers/settings_controller.dart';

class ProfileDetailController extends GetxController {
  UserModel? user;
  bool isLoading = false;

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
