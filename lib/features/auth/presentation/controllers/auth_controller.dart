import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/entities.dart';

class AuthController extends GetxController {
  final user = Rxn<User>();
  final isLoading = false.obs;
  final errorMsg = ''.obs;

  Future<bool> login(String email, String password) async {
    isLoading.value = true;
    errorMsg.value = '';

    await Future.delayed(const Duration(milliseconds: 800));

    if (email.trim() == AppConstants.adminEmail &&
        password.trim() == AppConstants.adminPassword) {
      user.value = const User(
        email: AppConstants.adminEmail,
        name: 'Alex Morgan',
        role: 'NOC Engineer',
      );
      final box = Hive.box(HiveKeys.settingsBox);
      await box.put(HiveKeys.loggedInKey, true);
      isLoading.value = false;
      return true;
    } else {
      errorMsg.value = 'Invalid credentials. Try admin@plexus.com';
      isLoading.value = false;
      return false;
    }
  }

  Future<void> logout() async {
    final box = Hive.box(HiveKeys.settingsBox);
    await box.put(HiveKeys.loggedInKey, false);
    user.value = null;
    Get.offAllNamed(AppRoutes.login);
  }
}
