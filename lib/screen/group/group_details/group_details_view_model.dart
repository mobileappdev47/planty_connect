import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:planty_connect/model/group_model.dart';
import 'package:planty_connect/model/message_model.dart';
import 'package:planty_connect/model/user_model.dart';
import 'package:planty_connect/screen/dashboard/dashboard.dart';
import 'package:planty_connect/screen/group/group_details/add_member/add_members.dart';
import 'package:planty_connect/screen/group/group_details/widgets/dialog_view.dart';
import 'package:planty_connect/screen/home/home_screen.dart';
import 'package:planty_connect/screen/person/chat_screen/chat_screen.dart';
import 'package:planty_connect/screen/person/person_details/person_details.dart';
import 'package:planty_connect/utils/app.dart';
import 'package:planty_connect/utils/app_state.dart';
import 'package:planty_connect/utils/color_res.dart';
import 'package:planty_connect/utils/exception.dart';
import 'package:planty_connect/utils/firestore_collections.dart';
import 'package:stacked/stacked.dart';

class GroupDetailsViewModel extends BaseViewModel {
  bool isExpanded = true;
  bool isAdmin = false;
  GroupModel groupModel;
  List<UserModel> members = [];
  List<String> membersId = [];

  final ImagePicker picker = ImagePicker();

  bool imageLoader = false;

  init(GroupModel groupModel) async {
    this.groupModel = groupModel;
    for (var value in groupModel.members) {
      UserModel doc = await userService.getUserModel(value.memberId);
      members.add(doc);
    }
    chackCurrentUserIsAdmin();
    getMembersId();
  }

  void getMembersId() {
    membersId = groupModel.members.map((element) {
      return element.memberId;
    }).toList();
  }

  void chackCurrentUserIsAdmin() {
    groupModel.members.forEach((element) {
      if (element.memberId == appState.currentUser.uid) {
        isAdmin = element.isAdmin;
      }
    });
    notifyListeners();
  }

  void sendMessage(String type, String content, MMessage message) async {
    DateTime messageTime = DateTime.now();
    DocumentSnapshot roomDocument;

    MessageModel messageModel = MessageModel(
      content: content,
      sender: appState.currentUser.uid,
      sendTime: messageTime.millisecondsSinceEpoch,
      type: type,
      receiver: groupModel.groupId,
      mMessage: message,
      senderName: appState.currentUser.name,
    );

    roomDocument = await chatRoomService.getParticularRoom(groupModel.groupId);

    String notificationBody;
    switch (type) {
      case "text":
        notificationBody = content;
        break;
      case "photo":
        notificationBody = "📷 Image";
        break;
      case "document":
        notificationBody = "📄 Document";
        break;
      case "music":
        notificationBody = "🎵 Music";
        break;
      case "video":
        notificationBody = "🎥 Video";
        break;
      case "alert":
        notificationBody = content;
        break;
    }

    chatRoomService.sendMessage(messageModel, groupModel.groupId);
    Map<String, dynamic> updateData = {};
    List<int> count = [];

    membersId.forEach((element) {
      count.add(roomDocument.get("${element}_newMessage"));
    });

    for (int i = 0; i < count.length; i++) {
      updateData['${membersId[i]}_newMessage'] = (count[i].toInt()) + 1;
    }

    updateData["lastMessage"] = notificationBody;
    updateData["lastMessageTime"] = messageTime;

    chatRoomService.updateLastMessage(
      updateData,
      groupModel.groupId,
    );
  }

  Future<void> leftGroupTap() async {
    List<String> adminId = [];
    groupModel.members.forEach((element) {
      if (element.isAdmin) {
        adminId.add(element.memberId);
      }
    });

    if (adminId.length == 1 && isAdmin == true) {
      Get.back();
      Get.snackbar(
        "Alert",
        "Please! create admin of another group-member for left the group",
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
      groupModel.members.remove(groupModel.members.firstWhere(
          (element) => element.memberId == appState.currentUser.uid));
      members.removeWhere((element) => element.uid == appState.currentUser.uid);
      if (groupModel.members.isEmpty) {
        deleteGroupTap();
        return;
      }
      List<String> membersId =
          groupModel.members.map((e) => e.memberId).toList();
      this.membersId = membersId;
      groupService.updateGroupMember(groupModel.groupId,
          List<dynamic>.from(groupModel.members.map((x) => x.toMap())));
      chatRoomService.updateGroupMembers(groupModel.groupId, membersId);

      await removeNewMessageStr(appState.currentUser.uid).then((value) async {
        UserModel user =
            await userService.getUserModel(appState.currentUser.uid);
        sendMessage('alert', "${user.name} left", null);
      });
      Get.offAll(() => DashBoard());
    }
  }

  void deleteGroupTap() {
    groupService.deleteGroup(groupModel.groupId);
    chatRoomService.deleteChatRoom(groupModel.groupId);
    Get.offAll(() => DashBoard());
  }

  void infoTap(GroupMember member) async {
    UserModel userModel = await userService.getUserModel(member.memberId);
    appState.currentActiveRoom = null;
    await Get.to(() => PersonDetails(userModel, null));
    appState.currentActiveRoom = groupModel.groupId;
  }

  void makeAdminTap(GroupMember member) {
    int index = groupModel.members.indexOf(member);
    groupModel.members[index].isAdmin = true;
    groupService.updateGroupMember(groupModel.groupId,
        List<dynamic>.from(groupModel.members.map((x) => x.toMap())));
    notifyListeners();
  }

  void removeAdminTap(GroupMember member) {
    int index = groupModel.members.indexOf(member);
    groupModel.members[index].isAdmin = false;
    groupService.updateGroupMember(groupModel.groupId,
        List<dynamic>.from(groupModel.members.map((x) => x.toMap())));
    notifyListeners();
  }

  Future<void> removeFromGroupTap(GroupMember member) async {
    groupModel.members.remove(member);
    members.removeWhere((element) => element.uid == member.memberId);
    List<String> membersId = groupModel.members.map((e) => e.memberId).toList();
    this.membersId = membersId;
    groupService.updateGroupMember(groupModel.groupId,
        List<dynamic>.from(groupModel.members.map((x) => x.toMap())));
    chatRoomService
        .updateGroupMembers(groupModel.groupId, membersId)
        .then((value) async {
      await removeNewMessageStr(member.memberId).then((value) async {
        UserModel user1 =
            await userService.getUserModel(appState.currentUser.uid);
        UserModel user2 = await userService.getUserModel(member.memberId);
        sendMessage('alert', "${user1.name} removed ${user2.name}", null);
      });
    });
    notifyListeners();
  }

  Future<void> removeNewMessageStr(String userId) async {
    CollectionReference chatRoom =
        FirebaseFirestore.instance.collection(FireStoreCollections.chatRoom);

    await chatRoom
        .doc(groupModel.groupId)
        .update({'${userId}_newMessage': FieldValue.delete()});
  }

  void sendMessageTap(GroupMember member) async {
    try {
      UserModel userModel = await userService.getUserModel(member.memberId);
      String chatId = '';
      if (userModel.uid.hashCode <= appState.currentUser.uid.hashCode) {
        chatId = '${userModel.uid}-${appState.currentUser.uid}';
      } else {
        chatId = '${appState.currentUser.uid}-${userModel.uid}';
      }
      DocumentSnapshot doc = await chatRoomService.isRoomAvailable(chatId);
      appState.currentActiveRoom = chatId;
      await Get.to(
          () => ChatScreen(userModel, true, doc.exists ? chatId : null));
      appState.currentActiveRoom = groupModel.groupId;
    } catch (e) {}
  }

  void updateGroupTap(String title, String desc) async {
    groupModel.name = title;
    groupModel.description = desc;

    await groupService.getGroup(groupModel.groupId).then((value) async {
      Map<String, dynamic> data = value.data();
      String oldGroupName = data['name'];

      if (oldGroupName != title) {
        UserModel user =
            await userService.getUserModel(appState.currentUser.uid);
        sendMessage(
            'alert',
            "${user.name} changed the subject from $oldGroupName to $title",
            null);
      }
    });

    groupService.updateGroupDesc(groupModel.groupId, title, desc);
    notifyListeners();
  }

  void editTap() {
    Get.dialog(
      Dialog(
        child: GroupInfoDialog(
          groupModel.name,
          groupModel.description,
          updateGroupTap,
        ),
      ),
    );
  }

  void groupMembersTap(
    GroupMember member,
    bool isAdmin,
    GroupDetailsViewModel model,
  ) {
    Get.dialog(
      Dialog(
        child: GroupMemberDialog(
          member,
          isAdmin,
          groupModel,
          model,
        ),
      ),
    );
  }

  void addParticipants() async {
    final data = await Get.to(() => AddMembers(groupModel));
    if (data != null) {
      groupModel = data as GroupModel;
      notifyListeners();
    }
  }

  void imageClick() async {

    if(groupModel.createdBy == appState.currentUser.uid){
      try {
        // ignore: deprecated_member_use
        final pickedFile = await picker.getImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          imageLoader = true;
          notifyListeners();
          String imageUrl =
          await storageService.uploadGroupIcon(File(pickedFile.path));
          if (imageUrl != null) {
            groupModel.groupImage = imageUrl;
            groupService.updateGroup(
              groupModel.groupId,
              {"groupImage": imageUrl},
            );
          }
          imageLoader = false;
          notifyListeners();
        }
      } catch (e) {
        handleException(e);
      }
    }
    else{
     if(groupModel.createdBy!=appState.adminUid){
       try {
         // ignore: deprecated_member_use
         final pickedFile = await picker.getImage(source: ImageSource.gallery);
         if (pickedFile != null) {
           imageLoader = true;
           notifyListeners();
           String imageUrl =
           await storageService.uploadGroupIcon(File(pickedFile.path));
           if (imageUrl != null) {
             groupModel.groupImage = imageUrl;
             groupService.updateGroup(
               groupModel.groupId,
               {"groupImage": imageUrl},
             );
           }
           imageLoader = false;
           notifyListeners();
         }
       } catch (e) {
         handleException(e);
       }
     }
    }


  }
}
