import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:planty_connect/model/user_model.dart';
import 'package:planty_connect/screen/dashboard/dashboard.dart';
import 'package:planty_connect/screen/home/home_screen.dart';
import 'package:planty_connect/screen/login/sign_in_screen.dart';
import 'package:planty_connect/utils/app.dart';
import 'package:stacked/stacked.dart';

class SignUpViewModel extends BaseViewModel {
  void init() async {}

  final formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void submitButtonTap() async {
    Get.focusScope.unfocus();
    if (formKey.currentState.validate()) {
      setBusy(true);
      String profilePicture =
          "https://eu.ui-avatars.com/api/?name=${nameController.text.trim()}&background=2BC289&color=fff&size=256";
      UserModel userModel = UserModel(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        profilePicture: profilePicture,


      );
      userModel.password = passwordController.text;
      userModel.isAdmin = false;
      final fcmToken = await messagingService.getFcmToken();
      userModel.fcmToken = fcmToken;
      try {
        await authService.signUp(userModel);
        Get.offAll(() => DashBoard());
      } catch (e) {
        setBusy(false);
      }
    }
  }

  String nameValidation(String value) {
    if (value.trim().isEmpty)
      return AppRes.please_enter_full_name;
    else if (!value.trim().contains(" "))
      return AppRes.please_enter_valid_full_name;
    else
      return null;
  }

  String emailValidation(String value) {
    if (value.isEmpty)
      return AppRes.please_enter_email;
    else if (!isEmail(value))
      return AppRes.please_enter_valid_email;
    else
      return null;
  }

  String passwordValidation(String value) {
    if (value.isEmpty)
      return AppRes.please_enter_password;
    else if (value.length < 6)
      return AppRes.please_enter_min_6_characters;
    else
      return null;
  }

  void signInClick() {
    Get.off(() => SignInScreen());
  }
}
