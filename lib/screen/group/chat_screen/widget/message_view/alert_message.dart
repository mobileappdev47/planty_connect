import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:planty_connect/utils/color_res.dart';
import 'package:planty_connect/utils/styles.dart';

// ignore: must_be_immutable
class AlertMessage extends StatelessWidget {
  String message;

  AlertMessage(this.message);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 3, horizontal: 8),
        margin: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: ColorRes.lightGray,
          boxShadow: [
            BoxShadow(
              color: ColorRes.black,
              offset: Offset(0, 0.5),
              blurRadius: 0.5,
            ),
          ],
        ),
        constraints: BoxConstraints(
          maxWidth: Get.width / 1.2,
        ),
        child: Text(
          message,
          style: AppTextStyle(
            color: ColorRes.black,
            fontSize: 11.5,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
