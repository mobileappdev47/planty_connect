import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:planty_connect/utils/color_res.dart';
import 'package:planty_connect/utils/debug.dart';

void handleException(exception) {
  Debug.print(exception);
  if (exception is PlatformException) {
    if (exception.code == "network_error") {
      Get.snackbar(
        "Failed",
        "Please check your internet connection",
        duration: Duration(seconds: 5),
        backgroundColor: ColorRes.red,
        colorText: ColorRes.white,
        icon: Icon(
          Icons.cancel,
          color: ColorRes.white,
          size: 32,
        ),
      );
    } else {
      Get.snackbar(
        "Failed",
        exception.message,
        duration: Duration(seconds: 5),
        backgroundColor: ColorRes.red,
        colorText: ColorRes.white,
        icon: Icon(
          Icons.cancel,
          color: ColorRes.white,
          size: 32,
        ),
      );
    }
  } else if (exception is FirebaseAuthException) {
    Get.snackbar(
      "Failed",
      exception.code == "user-not-found"
          ? "Can not find account with this email"
          : exception.code == "wrong-password"
              ? "The password is invalid"
              : exception.message,
      duration: Duration(seconds: 5),
      backgroundColor: ColorRes.red,
      colorText: ColorRes.white,
      icon: Icon(
        Icons.cancel,
        color: ColorRes.white,
        size: 32,
      ),
    );
  } else {
    Get.snackbar(
      "Failed",
      exception.toString(),
      duration: Duration(seconds: 5),
      backgroundColor: ColorRes.red,
      colorText: ColorRes.white,
      icon: Icon(
        Icons.cancel,
        color: ColorRes.white,
        size: 32,
      ),
    );
  }
}
