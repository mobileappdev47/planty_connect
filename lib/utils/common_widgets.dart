import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:planty_connect/utils/app.dart';
import 'package:planty_connect/utils/color_res.dart';
import 'package:planty_connect/utils/styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EvolveButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final double width;
  final double height;

  EvolveButton({
    @required this.title,
    @required this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: width ?? Get.width / 2,
        height: height ?? 50.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: ColorRes.green,
        ),
        alignment: Alignment.center,
        child: Container(
          child: Text(
            title,
            style: AppTextStyle(weight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class TextFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String title;
  final String Function(String) validation;
  bool obs;
  final bool readOnly;

  TextFieldWidget({
    @required this.controller,
    @required this.title,
    @required this.validation,
    this.obs = false,
    @required this.readOnly,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 7),
      child: TextFormField(
        readOnly: readOnly,
        obscureText: obs,
        controller: controller,
        validator: validation,
        keyboardType: title.toLowerCase() == "email"
            ? TextInputType.emailAddress
            : title.toLowerCase() == "password"
                ? TextInputType.visiblePassword
                : TextInputType.text,
        decoration: InputDecoration(
          filled: true,
          fillColor: ColorRes.creamColor,
          border: InputBorder.none,
          hintText: title,
          counterText: '',
          hintStyle: AppTextStyle(
            fontSize: 14,
            color: ColorRes.grey,
          ),
          contentPadding: EdgeInsets.only(left: 10.h),
        ),
      ),
    );
  }
}

class AttachmentView extends StatelessWidget {
  final Function onDocumentTap;
  final Function onVideoTap;
  final Function onGalleryTap;
  final Function onAudioTap;

  AttachmentView({
    @required this.onDocumentTap,
    @required this.onVideoTap,
    @required this.onGalleryTap,
    @required this.onAudioTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorRes.creamColor,
      height: 90.h,
      width: Get.width,
      margin: EdgeInsets.only(
        bottom: 60,
        left: 16,
        right: 16,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          iconTile(
            text: AppRes.document,
            icon: Icons.insert_drive_file,
            onTap: onDocumentTap,
          ),
          iconTile(
            text: AppRes.video,
            icon: Icons.videocam_rounded,
            onTap: onVideoTap,
          ),
          iconTile(
            text: AppRes.gallery,
            icon: Icons.image_rounded,
            onTap: onGalleryTap,
          ),
          iconTile(
            text: AppRes.audio,
            icon: Icons.headset_mic_rounded,
            onTap: onAudioTap,
          ),
        ],
      ),
    );
  }

  Widget iconTile({
    IconData icon,
    String text,
    VoidCallback onTap,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            radius: 25,
            backgroundColor: ColorRes.green,
            child: Icon(
              icon,
              color: ColorRes.white,
              size: 21.h,
            ),
          ),
        ),
        verticalSpaceTiny,
        Text(
          text,
          style: AppTextStyle(
            fontSize: 14.h,
            color: ColorRes.black,
          ),
        ),
      ],
    );
  }
}
