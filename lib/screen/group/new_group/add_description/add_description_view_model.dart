import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:planty_connect/model/group_model.dart';
import 'package:planty_connect/model/send_notification_model.dart';
import 'package:planty_connect/model/user_model.dart';
import 'package:planty_connect/screen/dashboard/dashboard.dart';
import 'package:planty_connect/screen/home/home_screen.dart';
import 'package:planty_connect/utils/app.dart';
import 'package:planty_connect/utils/app_state.dart';
import 'package:planty_connect/utils/exception.dart';
import 'package:stacked/stacked.dart';

class AddDescriptionViewModel extends BaseViewModel {
  List<UserModel> members;

  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  File image;

  final ImagePicker picker = ImagePicker();

  init(List<UserModel> users) async {
    if(appState.currentUser.isAdmin==false){
      setBusy(true);
      this.members = users;
      setBusy(false);
    }

  }

  void doneClick() async {
    Get.focusScope.unfocus();
    if (formKey.currentState.validate()) {
      setBusy(true);

      GroupModel groupModel = GroupModel()..members = [];

      groupModel.name = title.text.trim();
      groupModel.description = description.text.trim();

      List<String> membersId = [];

      if(appState.currentUser.isAdmin==false){
        members.forEach((element) {
          groupModel.members.add(GroupMember(
            memberId: element.uid,
            isAdmin: false,
          ));
          membersId.add(element.uid);
        });
      }


      membersId.add(appState.currentUser.uid);

      groupModel.members.insert(
          0,
          GroupMember(
            memberId: appState.currentUser.uid,
            isAdmin: true,
          ));

      if (image == null) {
        groupModel.groupImage = null;
      } else {
        String imageUrl = await storageService.uploadGroupIcon(image);
        if (imageUrl == null) {
          groupModel.groupImage = null;
        } else {
          groupModel.groupImage = imageUrl;
        }
      }

      groupModel.createdAt = DateTime.now();
      groupModel.createdBy = appState.currentUser.uid;

      try {
        DocumentReference groupData =
            await groupService.createGroup(groupModel);
        Map<String, dynamic> data = {
          "isGroup": true,
          "id": groupData.id,
          "membersId": membersId,
          "lastMessage": "Tap here",
          "lastMessageTime": DateTime.now(),
          'typing_id': null,
        };

        /*if(appState.currentUser.isAdmin==false){*/
          membersId.forEach((element) {
            data['${element}_newMessage'] = 1;
          });


          await chatRoomService.createChatRoom(data);
          membersId.remove(appState.currentUser.uid);
          if(appState.currentUser.isAdmin == false){
            List<String> tokenList = members.map((e) => e.fcmToken).toList();
            tokenList.removeWhere((element) => (element == appState.currentUser.fcmToken));
            messagingService.sendNotification(
              SendNotificationModel(
                fcmTokens: tokenList,
                roomId: groupData.id,
                id: groupData.id,
                body: "Tap here to chat",
                title:
                "${appState.currentUser.name} create a group ${groupModel.name}",
                isGroup: true,
              ),
            );
          }

     /*   }else{

          await chatRoomService.createChatRoom(data);
          membersId.remove(appState.currentUser.uid);
 *//*         messagingService.sendNotification(
            SendNotificationModel(
              fcmTokens: tokenList,
              roomId: groupData.id,
              id: groupData.id,
              body: "Tap here to chat",
              title:
              "${appState.currentUser.name} create a group ${groupModel.name}",
              isGroup: true,
            ),
          );*//*
        }*/



        Get.offAll(() => DashBoard());
      } catch (e) {}
      setBusy(false);
    }
  }

  void imagePick() async {
    Get.focusScope.unfocus();
    try {
      // ignore: deprecated_member_use
      final pickedFile = await picker.getImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        image = File(pickedFile.path);
        notifyListeners();
      }
    } catch (e) {
      handleException(e);
    }
  }
}
