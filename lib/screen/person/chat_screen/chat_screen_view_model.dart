import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:media_picker/media_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:planty_connect/model/message_model.dart';
import 'package:planty_connect/model/send_notification_model.dart';
import 'package:planty_connect/model/user_model.dart';
import 'package:planty_connect/screen/dashboard/dashboard.dart';
import 'package:planty_connect/screen/forward/forward.dart';
import 'package:planty_connect/screen/home/home_screen.dart';
import 'package:planty_connect/screen/person/chat_screen/chat_screen.dart';
import 'package:planty_connect/screen/person/chat_screen/widget/message_dialog_view.dart';
import 'package:planty_connect/screen/person/person_details/person_details.dart';
import 'package:planty_connect/screen/video_picker/video_picker_screen.dart';
import 'package:planty_connect/utils/app.dart';
import 'package:planty_connect/utils/app_state.dart';
import 'package:planty_connect/utils/color_res.dart';
import 'package:stacked/stacked.dart';

class ChatScreenViewModel extends BaseViewModel {
  TextEditingController controller = TextEditingController();
  FocusNode focusNode = FocusNode();

  UserModel receiver;
  bool isFromHome;
  bool isAttachment = false;
  bool isTyping = false;
  String roomId;
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
  DocumentSnapshot roomDocument;

  void init(UserModel receiver, bool isFromHome, String roomId) async {
    setBusy(true);
    appState.currentActiveRoom = roomId;
    this.isFromHome = isFromHome;
    this.receiver = receiver;
    this.roomId = roomId;
    listScrollController.addListener(manageScrollDownBtn);
    setBusy(false);
  }

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

  void onBack() {
    appState.currentActiveRoom = null;
    updateTyping(false);
    if (isFromHome)
      Get.back();
    else
      Get.offAll(() => DashBoard());
  }

  void headerClick() {
    updateTyping(false);
    focusNode.unfocus();
    Get.to(() => PersonDetails(receiver, roomId));
  }

  void onTextFieldChange() {
    if (appLifeState != AppLifecycleState.paused) {
      if (controller.text.isEmpty) {
        isTyping = false;
        updateTyping(false);
        notifyListeners();
      } else {
        updateTyping(true);
        if (!isTyping) {
          isTyping = true;
          notifyListeners();
        }
      }
    }
  }

  updateTyping(bool data) async {
    chatRoomService.updateLastMessage(
      {"${appState.currentUser.uid}_typing": data},
      roomId,
    );
  }

  void unBlockTap() {
    Get.back();
    chatRoomService.updateLastMessage({
      "blockBy": null,
    }, roomId);
  }

  void onSend(MMessage message) async {
    if (controller.text.trim().isNotEmpty) {
      sendMessage("text", controller.text.trim(), message);
      controller.clear();
      isTyping = false;
      updateTyping(false);
      notifyListeners();
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
  }

  void sendMessage(String type, String content, MMessage message) async {
    DateTime messageTime = DateTime.now();
    if (roomId == null) {
      String chatId = '';
      if (receiver.uid.hashCode <= appState.currentUser.uid.hashCode) {
        chatId = '${receiver.uid}-${appState.currentUser.uid}';
      } else {
        chatId = '${appState.currentUser.uid}-${receiver.uid}';
      }
      roomId = chatId;
      await chatRoomService.createChatRoom({
        "isGroup": false,
        "id": chatId,
        "membersId": [appState.currentUser.uid, receiver.uid],
        "lastMessage": "Tap here",
        "${appState.currentUser.uid}_typing": false,
        "${receiver.uid}_typing": false,
        "${appState.currentUser.uid}_newMessage": 0,
        "${receiver.uid}_newMessage": 0,
        "newMessage": 0,
        "lastMessageTime": messageTime,
        "blockBy": null,
      });
      roomDocument = await chatRoomService.getParticularRoom(roomId);
    }

    MessageModel messageModel = MessageModel(
      content: content,
      sender: appState.currentUser.uid,
      sendTime: messageTime.millisecondsSinceEpoch,
      type: type,
      receiver: receiver.uid,
      mMessage: message,
    );

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
    }

    SendNotificationModel notificationModel = SendNotificationModel(
      isGroup: false,
      title: appState.currentUser.name,
      body: notificationBody,
      fcmToken: receiver.fcmToken,
      roomId: roomId,
      id: appState.currentUser.uid,
    );

    chatRoomService.sendMessage(messageModel, roomId);
    int newMessage = roomDocument.get("${receiver.uid}_newMessage");
    newMessage++;
    chatRoomService.updateLastMessage(
      {
        "lastMessage": notificationBody,
        "lastMessageTime": messageTime,
        "${receiver.uid}_newMessage": newMessage
      },
      roomId,
    );

    // ignore: unnecessary_statements
    receiver.fcmToken != appState.currentUser.fcmToken
        ? messagingService.sendNotification(notificationModel)
        // ignore: unnecessary_statements
        : null;

    // ignore: invalid_use_of_protected_member
    if (listScrollController.positions.isNotEmpty) {
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  void clearNewMessage() async {
    chatRoomService.updateLastMessage(
      {"${appState.currentUser.uid}_newMessage": 0},
      roomId,
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
      String imageUrl =
          await storageService.uploadImage(File(imagePath.path), roomId);
      if (imageUrl != null) {
        sendMessage("photo", imageUrl, null);
      }
      uploadingMedia = false;
      notifyListeners();
    }
  }

  void onGalleryTap(BuildContext context) async {
    isAttachment = false;
    notifyListeners();

    List<String> result = await MediaPicker.pickImages(quantity: 10,withCamera: false);

    uploadingMedia = true;
    notifyListeners();

    result.forEach((value) async{
      String filePath = await FlutterAbsolutePath.getAbsolutePath(value);
      File imagePath = File(filePath);

      String imageUrl = await storageService
          .uploadImage(File(imagePath.path), roomId)
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
                await storageService.uploadDocument(File(file.path), roomId);
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
    isAttachment = false;
    notifyListeners();

    /*FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: true,
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
              await storageService.uploadVideo(File(file.path), roomId);
          if (imageUrl != null) {
            sendMessage("video", imageUrl, null);
            String filePath = await getUploadPath(file.name, "video");
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
    }*/

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
          await storageService.uploadVideo(File(file.path), roomId);
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
              await storageService.uploadMusic(File(file.path), roomId);
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
          chatRoomService.deleteMessage(messageModel.id, roomId);
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
          chatRoomService.deleteMessage(value.id, roomId);
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
}
