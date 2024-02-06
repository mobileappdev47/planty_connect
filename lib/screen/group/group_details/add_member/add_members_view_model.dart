import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:planty_connect/model/group_model.dart';
import 'package:planty_connect/model/message_model.dart';
import 'package:planty_connect/model/send_notification_model.dart';
import 'package:planty_connect/model/user_model.dart';
import 'package:planty_connect/utils/app.dart';
import 'package:planty_connect/utils/app_state.dart';
import 'package:stacked/stacked.dart';

class AddMembersViewModel extends BaseViewModel {
  List<UserModel> users;
  List<UserModel> selectedMembers = [];
  GroupModel groupModel;
  List<String> membersId = [];

  init(GroupModel groupModel) async {
    this.groupModel = groupModel;

    setBusy(true);
    QuerySnapshot querySnapshot = await userService.getUsers();
    if (querySnapshot.docs.isNotEmpty) {
      users =
          querySnapshot.docs.map((e) => UserModel.fromMap(e.data())).toList();
    } else {
      users = [];
    }

    if (users.isNotEmpty) {
      groupModel.members.forEach((mem) {
        membersId.add(mem.memberId);
        users.removeWhere((element) => element.uid == mem.memberId);
      });
    }
    setBusy(false);
  }

  void sendMessage(String type, String content, MMessage message) async {
    DateTime messageTime = DateTime.now();
    DocumentSnapshot roomDocument;
    List<UserModel> members = [];

    for (var value in groupModel.members) {
      UserModel doc = await userService.getUserModel(value.memberId);
      members.add(doc);
    }
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

  void nextClick() {
    if (selectedMembers.isEmpty) {
      Get.back();
    } else {
      setBusy(true);
      List<String> fcmTokens = [];
      selectedMembers.forEach((element) {
        fcmTokens.add(element.fcmToken);
        membersId.add(element.uid);
        groupModel.members.add(GroupMember(
          isAdmin: false,
          memberId: element.uid,
        ));
      });
      fcmTokens.removeWhere((element) => (element == appState.currentUser.fcmToken));
      groupService.updateGroupMember(groupModel.groupId,
          List<dynamic>.from(groupModel.members.map((x) => x.toMap())));
      chatRoomService.updateGroupMembers(groupModel.groupId, membersId);

      selectedMembers.forEach((element) async {
        chatRoomService.updateGroupNewMessage(groupModel.groupId, element.uid);

        UserModel user =
            await userService.getUserModel(appState.currentUser.uid);
        sendMessage('alert', '${element.name} added by ${user.name}', null);
      });

      selectedMembers.forEach((element) {
        chatRoomService.updateGroupNewMessage(groupModel.groupId, element.uid);
      });
      messagingService.sendNotification(
        SendNotificationModel(
          fcmTokens: fcmTokens,
          roomId: groupModel.groupId,
          id: groupModel.groupId,
          body: "Tap here to chat",
          title:
              "${appState.currentUser.name} add you into a group ${groupModel.name}",
          isGroup: true,
        ),
      );
      Get.back(result: groupModel);
    }
  }

  bool isSelected(UserModel userModel) {
    return selectedMembers.contains(userModel);
  }

  void selectUserClick(UserModel user) async {
    if (selectedMembers.contains(user))
      selectedMembers.remove(user);
    else
      selectedMembers.add(user);

    notifyListeners();
  }
}
