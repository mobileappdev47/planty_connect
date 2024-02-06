import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:planty_connect/model/user_model.dart';
import 'package:planty_connect/screen/dashboard/dashboard.dart';
import 'package:planty_connect/screen/forgot_password/forgot_password_screen.dart';
import 'package:planty_connect/screen/home/home_screen.dart';
import 'package:planty_connect/screen/register/sign_up_screen.dart';
import 'package:planty_connect/utils/app.dart';
import 'package:planty_connect/utils/app_state.dart';
import 'package:stacked/stacked.dart';

class SignInViewModel extends BaseViewModel {
  void init() async {}

  final formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void submitButtonTap() async {
    Get.focusScope.unfocus();
    if (formKey.currentState.validate()) {
      setBusy(true);
      final fcmToken = await messagingService.getFcmToken();
      try {
        await authService.signIn(
          UserModel(
            email: emailController.text.trim(),
            fcmToken: fcmToken,
          )..password = passwordController.text,
        );
        await FirebaseFirestore.instance.collection("users").where("isAdmin",isEqualTo: true).get().then((value){
      appState.adminUid = value.docs[0].data()['uid'];
        });
        notifyListeners();
        Get.offAll(() => DashBoard());
      } catch (e) {
        setBusy(false);
      }
    }
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

  void signUpClick() {
    Get.off(() => SignUpScreen());
  }

  void forgotPasswordClick() {
    Get.to(() => ForgotPasswordScreen());
  }
}
