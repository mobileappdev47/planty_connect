import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:planty_connect/service/auth_service/auth_service.dart';
import 'package:planty_connect/service/chat_room_service/chat_room_service.dart';
import 'package:planty_connect/service/group_service/group_service.dart';
import 'package:planty_connect/service/messaging/messaging_service.dart';
import 'package:planty_connect/service/storage_service/storage_service.dart';
import 'package:planty_connect/service/user_service/user_service.dart';
import 'package:planty_connect/utils/color_res.dart';
import 'package:planty_connect/utils/exception.dart';
import 'package:planty_connect/utils/styles.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class AppRes {
  /// Define all static strings here
  /// example app name, tab title, form title, strings, etc.

  static const String appName = "Planty Connect";

  static const String sign_in = "Sign In";
  static const String sign_up = "Sign Up";
  static const String forgot_password = "Forgot Password?";
  static const String submit = "Submit";
  static const String newGroup = "New Group";
  static const String select_person_or_group = "Select person or group";
  static const String new_personal_chat = "New Personal Chat";
  static const String add_participants = "Add Participants";
  static const String select_person = "Select Person";
  static const String participants = "Participants";
  static const String add_description = "Add Description";
  static const String type_group_title_here = "Type group title here...";
  static const String type_your_name_here = "Type your name here...";
  static const String type_group_description_here =
      "Type group description here...";
  static const String provide_group_description_and_icon =
      "Provide group description and icon (Optional)";

  static const String email = "Email";
  static const String password = "Password";
  static const String full_name = "Full Name";

  static const String welcome = "Welcome";
  static const String no_user_found = "No user found :(";
  static const String no_user_or_group_found = "No user or group found :(";

  static const String sign_in_successfully = "Sign in successfully";
  static const String sign_up_successfully = "Sign up successfully";

  static const String send_email_successfully =
      "Password reset link has been sent to your email successfully";

  /// validation strings
  static const String can_not_be_empty = "Can not be empty";
  static const String select_at_least_one_member = "Select at least one member";
  static const String select_at_least_one_person = "Select at least one person";
  static const String please_enter_full_name = "Please enter full name";
  static const String please_enter_valid_full_name =
      "Please enter valid full name";
  static const String please_enter_email = "Please enter email";
  static const String please_enter_valid_email = "Please enter valid email";
  static const String please_enter_password = "Please enter password";
  static const String please_enter_min_6_characters =
      "Please enter min 6 characters";

  static const String type_a_message = "Type a message...";

  static const String icons = 'assets/icons/';
  static const String images = 'assets/images/';

  static const String create_group = "Create Group";
  static const String create_personal_chat = "Create Personal Chat";

  static const String document = "Document";
  static const String video = "Video";
  static const String gallery = "Gallery";
  static const String audio = "Audio";

  static const String block = "Block";
  static const String make_admin = "Make Admin";
  static const String remove_admin = "Remove Admin";
  static const String remove_from_group = "Remove From Group";
  static const String delete_group = "Delete Group";
  static const String info = "Info";
  static const String left_group = "Left Group";
  static const String send_message = "Send Message";
  static const String done = "Done";

  static const String delete = "Delete";
  static const String reply = "Reply";
  static const String forward = "Forward";
  static const String forwardMultiple = "Forward multiple";
  static const String deleteMultiple = "Delete multiple";

  static const String selectContact = "Select contacts to call";
}

class AssetsRes {
  static String whatsAppIcon = AppRes.icons + "whatsapp_icon" + ".png";
  static String profileImage = AppRes.images + "profile" + ".png";
  static String groupImage = AppRes.images + "group_image" + ".png";
  static String galleryImage = AppRes.images + "gallery_image" + ".png";
}

showErrorToast(String message, {String title}) {
  Get.snackbar(title ?? "Error", message,
      backgroundColor: ColorRes.red, colorText: ColorRes.white);
}

showSuccessToast(String message, {String title}) {
  Get.snackbar(title ?? "Successful", message,
      backgroundColor: ColorRes.green, colorText: ColorRes.white);
}

// Horizontal Spacing
Widget horizontalSpaceTiny = SizedBox(width: 5.h);
Widget horizontalSpaceSmall = SizedBox(width: 10.h);
Widget horizontalSpaceRegular = SizedBox(width: 15.h);
Widget horizontalSpaceMedium = SizedBox(width: 20.h);
Widget horizontalSpaceLarge = SizedBox(width: 30.h);
Widget horizontalSpaceMassive = SizedBox(width: 50.h);

// Vertical Spacing
Widget verticalSpaceTiny = SizedBox(height: 5.h);
Widget verticalSpaceSmall = SizedBox(height: 10.h);
Widget verticalSpaceRegular = SizedBox(height: 15.h);
Widget verticalSpaceMedium = SizedBox(height: 20.h);
Widget verticalSpaceLarge = SizedBox(height: 30.h);
Widget verticalSpaceMassive = SizedBox(height: 50.h);

AuthService authService = AuthService();
UserService userService = UserService();
MessagingService messagingService = MessagingService();
GroupService groupService = GroupService();
StorageService storageService = StorageService();
ChatRoomService chatRoomService = ChatRoomService();

bool isEmail(String email) {
  String p =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regExp = new RegExp(p);
  return regExp.hasMatch(email);
}

String hFormat(DateTime date) {
  if (DateTime.now().difference(date).inDays == 1) {
    return "yesterday";
  } else if (DateTime.now().difference(date).inDays > 364) {
    return DateFormat('dd-MM-yyyy').format(date);
  } else if (DateTime.now().difference(date).inDays > 1) {
    return DateFormat('dd-MM').format(date);
  } else {
    return DateFormat('hh:mm a').format(date);
  }
}

String convertSize(int size) {
  String newSize = "";
  int kbSize = size ~/ 1024;
  if (kbSize > 1024) {
    newSize = "${(size ~/ 1024) ~/ 1024} mb";
  } else {
    newSize = "${size ~/ 1024} kb";
  }
  return newSize;
}

Future<bool> checkForExist(String name, String type) async {
  String appFolder =
      Platform.isIOS ? "/media/$type/" : "PlantyConnect/media/$type/";
  Directory directory;
  if (Platform.isIOS) {
    directory = await getApplicationDocumentsDirectory();
  } else {
    directory = Directory("/storage/emulated/0/");
  }

  String filePath = "${directory.path}$appFolder$name";
  try {
    final data = await File(filePath).exists();
    return data;
  } catch (e) {
    print(e);
    return false;
  }
}

Future<bool> checkForSenderExist(String name, String type) async {
  String appFolder =
      Platform.isIOS ? "/media/$type/sent/" : "PlantyConnect/media/$type/sent/";
  Directory directory;
  if (Platform.isIOS) {
    directory = await getApplicationDocumentsDirectory();
  } else {
    directory = Directory("/storage/emulated/0/");
  }

  String filePath = "${directory.path}$appFolder$name";
  try {
    final data = await File(filePath).exists();
    return data;
  } catch (e) {
    print(e);
    return false;
  }
}

Future<String> getDownloadPath(String name, String type) async {
  Directory directory;
  if (Platform.isIOS) {
    directory = await getApplicationDocumentsDirectory();

    try {
      var status = await Permission.storage.request();
      if (status.isGranted) {
        if (!await Directory(directory.path + "/media").exists()) {
          await Directory(directory.path + "/media").create();
          if (!await Directory(directory.path + "/media/$type").exists()) {
            await Directory(directory.path + "/media/$type").create();
          }
        } else if (!await Directory(directory.path + "/media/$type").exists()) {
          await Directory(directory.path + "/media/$type").create();
        }

        directory = Directory(directory.path + "/media/$type");

        String filePath = "${directory.path}/$name";
        return filePath;
      } else {
        return null;
      }
    } catch (e) {
      handleException(e);
      return null;
    }
  } else {
    directory = Directory("/storage/emulated/0/");

    try {
      var status = await Permission.storage.request();
      if (status.isGranted) {
        if (!await Directory(directory.path + "PlantyConnect").exists()) {
          await Directory(directory.path + "PlantyConnect").create();
          if (!await Directory(directory.path + "PlantyConnect/media")
              .exists()) {
            await Directory(directory.path + "PlantyConnect/media").create();
            if (!await Directory(directory.path + "PlantyConnect/media/$type")
                .exists()) {
              await Directory(directory.path + "PlantyConnect/media/$type")
                  .create();
            }
          } else if (!await Directory(
                  directory.path + "PlantyConnect/media/$type")
              .exists()) {
            await Directory(directory.path + "PlantyConnect/media/$type")
                .create();
          }
        } else if (!await Directory(directory.path + "PlantyConnect/media")
            .exists()) {
          await Directory(directory.path + "PlantyConnect/media").create();
          if (!await Directory(directory.path + "PlantyConnect/media/$type")
              .exists()) {
            await Directory(directory.path + "PlantyConnect/media/$type")
                .create();
          }
        } else if (!await Directory(
                directory.path + "PlantyConnect/media/$type")
            .exists()) {
          await Directory(directory.path + "PlantyConnect/media/$type")
              .create();
        }

        directory = Directory(directory.path + "PlantyConnect/media/$type");

        String filePath = "${directory.path}/$name";
        return filePath;
      } else {
        return null;
      }
    } catch (e) {
      handleException(e);
      return null;
    }
  }
}

Future<String> getUploadPath(String name, String type) async {
  Directory directory;
  if (Platform.isIOS) {
    directory = await getApplicationDocumentsDirectory();

    try {
      var status = await Permission.storage.request();
      if (status.isGranted) {
        if (!await Directory(directory.path + "/media").exists()) {
          await Directory(directory.path + "/media").create();
          if (!await Directory(directory.path + "/media/$type").exists()) {
            await Directory(directory.path + "/media/$type").create();
          }
        } else if (!await Directory(directory.path + "/media/$type").exists()) {
          await Directory(directory.path + "/media/$type").create();
        }

        if (!await Directory(directory.path + "/media/$type/sent").exists()) {
          await Directory(directory.path + "/media/$type/sent").create();
        }

        directory = Directory(directory.path + "/media/$type/sent");

        String filePath = "${directory.path}/$name";
        return filePath;
      } else {
        return null;
      }
    } catch (e) {
      handleException(e);
      return null;
    }
  } else {
    directory = Directory("/storage/emulated/0/");

    try {
      var status = await Permission.storage.request();
      if (status.isGranted) {
        if (!await Directory(directory.path + "PlantyConnect").exists()) {
          await Directory(directory.path + "PlantyConnect").create();
          if (!await Directory(directory.path + "PlantyConnect/media")
              .exists()) {
            await Directory(directory.path + "PlantyConnect/media").create();
            if (!await Directory(directory.path + "PlantyConnect/media/$type")
                .exists()) {
              await Directory(directory.path + "PlantyConnect/media/$type")
                  .create();
            }
          } else if (!await Directory(
                  directory.path + "PlantyConnect/media/$type")
              .exists()) {
            await Directory(directory.path + "PlantyConnect/media/$type")
                .create();
          }
        } else if (!await Directory(directory.path + "PlantyConnect/media")
            .exists()) {
          await Directory(directory.path + "PlantyConnect/media").create();
          if (!await Directory(directory.path + "PlantyConnect/media/$type")
              .exists()) {
            await Directory(directory.path + "PlantyConnect/media/$type")
                .create();
          }
        } else if (!await Directory(
                directory.path + "PlantyConnect/media/$type")
            .exists()) {
          await Directory(directory.path + "PlantyConnect/media/$type")
              .create();
        }

        if (!await Directory(directory.path + "PlantyConnect/media/$type/sent")
            .exists()) {
          await Directory(directory.path + "PlantyConnect/media/$type/sent")
              .create();
        }

        directory =
            Directory(directory.path + "PlantyConnect/media/$type/sent");

        String filePath = "${directory.path}/$name";
        return filePath;
      } else {
        return null;
      }
    } catch (e) {
      handleException(e);
      return null;
    }
  }
}

showConfirmationDialog(Function call, String title) {
  return Get.dialog(
    Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          verticalSpaceSmall,
          Text(
            "Confirmation",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          verticalSpaceSmall,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(title),
          ),
          verticalSpaceMedium,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () => Get.back(),
                child: Container(
                  padding: EdgeInsets.all(8),
                  color: ColorRes.dimGray,
                  child: Text(
                    "Cancel",
                    style: AppTextStyle(
                      color: ColorRes.white,
                    ),
                  ),
                ),
              ),
              horizontalSpaceSmall,
              InkWell(
                onTap: call,
                child: Container(
                  padding: EdgeInsets.all(8),
                  color: ColorRes.green,
                  child: Text(
                    "Confirm",
                    style: AppTextStyle(
                      color: ColorRes.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          verticalSpaceSmall,
        ],
      ),
    ),
  );
}
