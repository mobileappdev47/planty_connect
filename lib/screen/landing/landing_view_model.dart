import 'package:get/get.dart';
import 'package:planty_connect/screen/login/sign_in_screen.dart';
import 'package:planty_connect/screen/register/sign_up_screen.dart';

class LandingViewModel {
  LandingViewModel();

  void registerClick() {
    Get.to(() => SignUpScreen());
  }

  void loginClick() {
    Get.to(() => SignInScreen());
  }
}
