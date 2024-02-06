import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:media_picker/media_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:planty_connect/model/group_model.dart';
import 'package:planty_connect/model/message_model.dart';
import 'package:planty_connect/model/send_notification_model.dart';
import 'package:planty_connect/model/user_model.dart';
import 'package:planty_connect/screen/dashboard/dashboard.dart';
import 'package:planty_connect/screen/forward/forward.dart';
import 'package:planty_connect/screen/group/chat_screen/chat_screen.dart';
import 'package:planty_connect/screen/group/chat_screen/widget/message_dialog_view.dart';
import 'package:planty_connect/screen/group/group_details/group_details.dart';
import 'package:planty_connect/screen/group/chat_screen/bottom_bar/create_call_bottom_bar.dart';
import 'package:planty_connect/screen/video_picker/video_picker_screen.dart';
import 'package:planty_connect/utils/app.dart';
import 'package:planty_connect/utils/app_state.dart';
import 'package:planty_connect/utils/color_res.dart';
import 'package:planty_connect/utils/debug.dart';
import 'package:stacked/stacked.dart';

class ChatScreenViewModel extends BaseViewModel {
  TextEditingController controller = TextEditingController();

  GroupModel groupModel;
  bool isFromHome;
  List<UserModel> members = [];
  List<String> membersId = [];

  void init(GroupModel groupModel, bool isFromHome) async {
    setBusy(true);
    appState.currentActiveRoom = groupModel.groupId;
    this.isFromHome = isFromHome;
    this.groupModel = groupModel;
    for (var value in groupModel.members) {
      UserModel doc = await userService.getUserModel(value.memberId);
      members.add(doc);
    }
    getMembersId();
    listScrollController.addListener(manageScrollDownBtn);
    setBusy(false);
  }

  updateGroupInfo(GroupModel groupModel) async {
    members.clear();
    this.groupModel = groupModel;
    this.groupModel = groupModel;
    print(groupModel.members);
    for (var value in groupModel.members) {
      if (value.memberId != appState.currentUser.uid) {
        UserModel doc = await userService.getUserModel(value.memberId);
        members.add(doc);
      }
    }
  }

  void onBack() {
    clearNewMessage();
    appState.currentActiveRoom = null;
    updateTyping(null);
    if (isFromHome)
      Get.back();
    else
      Get.offAll(() => DashBoard());
  }

  Future<void> headerClick() async {






    focusNode.unfocus();
    updateTyping(null);

    await Get.to(() => GroupDetails(groupModel)).then((value) async {
      value = (value ?? false);
      if (value) {
        roomDocument =
            await chatRoomService.getParticularRoom(groupModel.groupId);
        Map<String, dynamic> data = roomDocument.data();
        membersId = data['membersId'].map<String>((e) => e.toString()).toList();
        clearNewMessage();
      }
      return value;
    });
  }

  FocusNode focusNode = FocusNode();

  bool isAttachment = false;
  bool isTyping = false;
  int chatLimit = 20;
  MMessage message;

  final ScrollController listScrollController = ScrollController();

  List<DocumentSnapshot> listMessage = [];

  final ImagePicker picker = ImagePicker();


  bool uploadingMedia = false;


  List<MessageModel> selectedMessages = [];
  bool isSelectionMode = false;
  bool showScrollDownBtn = false;
  bool isDeleteMode = false;
  bool isForwardMode = false;
  bool isReply = false;

  void onScrollDownTap() {
    listScrollController.position.jumpTo(0);
  }

  void manageScrollDownBtn() {
    if (listScrollController.position.pixels > 150) {
      if (!showScrollDownBtn) {
        showScrollDownBtn = true;
        notifyListeners();
      }
    } else {
      if (showScrollDownBtn) {
        showScrollDownBtn = false;
        notifyListeners();
      }
    }
  }

  Future<void> onTextFieldChange() async {
    bool nullId = await isTypingIdNull();
    if (controller.text.isEmpty) {
      isTyping = false;
      updateTyping(null);
      notifyListeners();
    } else {
      if (!isTyping || nullId) {
        isTyping = true;
        updateTyping(appState.currentUser.uid);
        notifyListeners();
      }
    }
  }

  updateTyping(
    String data,
  ) async {
    chatRoomService.updateLastMessage(
      {"typing_id": (appIsBG == true) ? null : data},
      groupModel.groupId,
    );
    appIsBG = false;
  }

  Future<bool> isTypingIdNull() async {

    bool nullId = await chatRoomService
        .getParticularRoom(groupModel.groupId)
        .then((value) {
      Map<String, dynamic> data = value.data();
      if (data['typing_id'] == null) {
        return true;
      }
      return false;
    });
    return nullId;
  }

  DocumentSnapshot roomDocument;

  void onSend(MMessage message) async {
    if (controller.text.trim().isNotEmpty) {
      sendMessage("text", controller.text.trim(), message);
      controller.clear();
    } else {
      Get.snackbar(
        "Alert",
        "Please! type message",
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
    isTyping = false;
    updateTyping(null);
    notifyListeners();
  }

  void sendMessage(String type, String content, MMessage message) async {
    DateTime messageTime = DateTime.now();

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

    Map<String, dynamic> data = roomDocument.data();

      membersId = data['membersId'].map<String>((e) => e.toString()).toList();
    if(!membersId.contains(appState.currentUser.uid)){
      membersId.add(appState.currentUser.uid);
      await FirebaseFirestore.instance.collection("chatRoom").doc(groupModel.groupId).update({"membersId":membersId});
    }
   // await FirebaseFirestore.instance.collection("groups").doc(groupModel.groupId).update({"lastMessage":content});




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

    List<String> tokenList = members.map((e) => e.fcmToken).toList();
    tokenList
        .removeWhere((element) => (element == appState.currentUser.fcmToken));

    SendNotificationModel notificationModel = SendNotificationModel(
      isGroup: true,
      title: appState.currentUser.name,
      body: notificationBody,
      fcmTokens: tokenList,
      roomId: groupModel.groupId,
      id: appState.currentUser.uid,
    );

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

    Debug.print("updateData = $updateData");
    chatRoomService.updateLastMessage(
      updateData,
      groupModel.groupId,
    );
    // ignore: unnecessary_statements
    (type != 'alert')
        ? messagingService.sendNotification(notificationModel)
        // ignore: unnecessary_statements
        : null;

    // ignore: invalid_use_of_protected_member
    if (listScrollController.positions.isNotEmpty) {
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  void getMembersId() {
    membersId = groupModel.members.map((element) {
      return element.memberId;
    }).toList();
  }

  clearNewMessage() async {
    chatRoomService.updateLastMessage(
      {"${appState.currentUser.uid}_newMessage": 0},
      groupModel.groupId,
    );
  }

  void onCameraTap() async {
    isAttachment = false;
    notifyListeners();
    focusNode.unfocus();
    // ignore: deprecated_member_use
    final imagePath = await picker.getImage(source: ImageSource.camera);
    if (imagePath != null) {
      uploadingMedia = true;
      notifyListeners();
      String imageUrl = await storageService.uploadImage(
          File(imagePath.path), groupModel.groupId);
      if (imageUrl != null) {
        sendMessage("photo", imageUrl, null);
      }
      uploadingMedia = false;
      notifyListeners();
    }
  }

  void onGalleryTap() async {
    isAttachment = false;
    notifyListeners();

    List<String> result = await MediaPicker.pickImages(quantity: 10,withCamera: false);

    uploadingMedia = true;
    notifyListeners();

    result.forEach((value) async{
      String filePath = await FlutterAbsolutePath.getAbsolutePath(value);
      File file = File(filePath);

      if(file.lengthSync() > 67108864){
        showErrorToast("Can not upload more than 64MB");
        if (value == result.last) {
          uploadingMedia = false;
          notifyListeners();
        }
      }
      else{
        String imageUrl = await storageService
            .uploadImage(File(file.path), groupModel.groupId)
            .then((imageUrl) {
          if (value == result.last) {
            uploadingMedia = false;
            notifyListeners();
          }
          return imageUrl;
        });
        if (imageUrl != null) {
          sendMessage("photo", imageUrl, null);
        }
      }

    });
  }

  void onDocumentTap() async {
    var status = await Permission.manageExternalStorage.request();
    if(status.isDenied){
      return null;
    }
    isAttachment = false;
    notifyListeners();
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      allowedExtensions: [
        'pdf',
        'xlsx',
        'xlsm',
        'xls',
        'ppt',
        'pptx',
        'doc',
        'docx',
        'txt',
        'text',
        'rtf',
        'zip',
      ],
    );
    if (result != null) {
      //PlatformFile file = result.files.first;
      List<PlatformFile> fileList = result.files;
      uploadingMedia = true;
      notifyListeners();

      if (fileList != null) {
        fileList.forEach((file) async {
          if (file.size > 67108864) {
            showErrorToast("Can not upload more than 64MB");
            if (file == fileList.last) {
              uploadingMedia = false;
              notifyListeners();
            }
          } else {
            print(file.path);

            String imageUrl =
            await storageService.uploadDocument(File(file.path), groupModel.groupId);
            sendMessage("document", imageUrl, null);
            await getUploadPath(file.name, "document")
                .then((filePath) async {
              await File(filePath).create(recursive: true);
              await File(filePath)
                  .writeAsBytes(await File(file.path).readAsBytes())
                  .then((value) {
                if (file == fileList.last) {
                  uploadingMedia = false;
                  notifyListeners();
                }
              });
              return filePath;
            });
          }
        });
      }
    }
  }

  void onVideoTap() async {

    uploadingMedia = true;
    notifyListeners();
    await Get.to(() => VideoPickerScreen()).then((value){

      if(value == null){
        uploadingMedia = false;
        notifyListeners();
        return null;
      }
      List<File> fileList = value;
      fileList.forEach((file) async {
        if (file.lengthSync() > 67108864) {
          showErrorToast("Can not upload more than 64MB");
          if (file == fileList.last) {
            uploadingMedia = false;
            notifyListeners();
          }
        } else {
          String imageUrl =
          await storageService.uploadVideo(File(file.path), groupModel.groupId);
          if (imageUrl != null) {
            sendMessage("video", imageUrl, null);
            String filePath = await getUploadPath(file.path.split('/').last, "video");
            await File(filePath).create(recursive: true);
            await File(filePath)
                .writeAsBytes(await File(file.path).readAsBytes())
                .then((value) {
              if (file == fileList.last) {
                uploadingMedia = false;
                notifyListeners();
              }
            });
          }
        }
      });
    });
  }

  void onAudioTap() async {
    isAttachment = false;
    notifyListeners();
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );
    if (result != null) {
      List<PlatformFile> fileList = result.files;

      uploadingMedia = true;
      notifyListeners();

      fileList.forEach((file) async {
        if (file.size > 67108864) {
          showErrorToast("Can not upload more than 64MB");
          if (file == fileList.last) {
            uploadingMedia = false;
            notifyListeners();
          }
        } else {
          String imageUrl =
          await storageService.uploadMusic(File(file.path), groupModel.groupId);
          if (imageUrl != null) {
            sendMessage("music", imageUrl, null);
            String filePath = await getUploadPath(file.name, "music");
            await File(filePath).create(recursive: true);
            await File(filePath)
                .writeAsBytes(await File(file.path).readAsBytes())
                .then((value) {
              if (file == fileList.last) {
                uploadingMedia = false;
                notifyListeners();
              }
            });
          }
        }
      });
    }
  }

  void onAttachmentTap() {
    focusNode.unfocus();
    isAttachment = !isAttachment;
    notifyListeners();
  }

  void downloadDocument(String url, String filePath) async {
    await File(filePath).create(recursive: true);
    await storageService.downloadMedia(url, filePath);
  }

  void enableForwardSelectionMode(MessageModel messageModel) {
    if (!isForwardMode) {
      isForwardMode = true;
      selectedMessages.add(messageModel);
      notifyListeners();
    }
  }

  void enableDeleteSelectionMode(MessageModel messageModel) {
    if (!isDeleteMode) {
      isDeleteMode = true;
      selectedMessages.add(messageModel);
      notifyListeners();
    }
  }

  void clearReply() {
    isReply = false;
    message = null;
    notifyListeners();
  }

  void onLongPressMessage(MessageModel messageModel, bool sender) async {
    focusNode.unfocus();
    Get.dialog(Dialog(
      child: MessageDialog(
        sender: sender,
        message: messageModel,
        onDeleteTap: () {
          chatRoomService.deleteMessage(messageModel.id, groupModel.groupId);
          Get.back();
        },
        onReplyTap: () {
          isReply = true;
          message = MMessage(
            mContent: messageModel.content,
            mDataType: messageModel.type,
            mType: Type.reply,
          );
          Get.back();
          notifyListeners();
        },
        onForwardTap: () {
          Get.back();
          Get.to(() => Forward([messageModel]));
        },
        onDeleteMultipleTap: () {
          enableDeleteSelectionMode(messageModel);
          Get.back();
        },
        onForwardMultipleTap: () {
          enableForwardSelectionMode(messageModel);
          Get.back();
        },
      ),
    ));
  }

  void onTapPressMessage(MessageModel messageModel) async {
    if (isDeleteMode) {
      if (selectedMessages
          .where((element) => element.id == messageModel.id)
          .isNotEmpty) {
        selectedMessages
            .removeWhere((element) => element.id == messageModel.id);
        if (selectedMessages.isEmpty) {
          isDeleteMode = false;
        }
      } else {
        selectedMessages.add(messageModel);
      }
      notifyListeners();
    } else if (isForwardMode) {
      if (selectedMessages
          .where((element) => element.id == messageModel.id)
          .isNotEmpty) {
        selectedMessages
            .removeWhere((element) => element.id == messageModel.id);
        if (selectedMessages.isEmpty) {
          isDeleteMode = false;
        }
      } else {
        selectedMessages.add(messageModel);
      }
      notifyListeners();
    }
  }

  void deleteClickMessages() async {
    showConfirmationDialog(
      () async {
        print("Confirmation");
        Get.back();
        for (var value in selectedMessages) {
          chatRoomService.deleteMessage(value.id, groupModel.groupId);
        }
        selectedMessages.clear();
        isDeleteMode = false;
        notifyListeners();
      },
      "Are you sure you want to delete messages?",
    );
  }

  void clearClick() {
    isForwardMode = false;
    isDeleteMode = false;
    selectedMessages.clear();
    notifyListeners();
  }

  void forwardClickMessages() async {
    final data = await Get.to(() => Forward(selectedMessages));
    if (data != null) {
      clearClick();
    }
  }

  void onAddCallTap() {
    Get.bottomSheet(
      BottomSheet(
        onClosing: (){},
        builder: (context) => CreateCallBottomBar(groupModel),
      ),
    );
  }
}
