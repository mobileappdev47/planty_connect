import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:planty_connect/utils/app.dart';
import 'package:stacked/stacked.dart';

class ForgotPasswordViewModel extends BaseViewModel {
  void init() async {}

  final formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void submitButtonTap() async {
    Get.focusScope.unfocus();
    if (formKey.currentState.validate()) {
      setBusy(true);
      try {
        await authService.forgotPassword(emailController.text.trim());
        emailController.clear();
        setBusy(false);
        showSuccessToast(AppRes.send_email_successfully);
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
}
