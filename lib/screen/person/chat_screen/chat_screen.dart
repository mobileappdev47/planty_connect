import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:planty_connect/model/call_model.dart';
import 'package:planty_connect/model/message_model.dart';
import 'package:planty_connect/model/user_model.dart';
import 'package:planty_connect/screen/call/incoming_call/incoming_screen.dart';
import 'package:planty_connect/screen/person/chat_screen/widget/InputBottomBar.dart';
import 'package:planty_connect/screen/person/chat_screen/chat_screen_view_model.dart';
import 'package:planty_connect/screen/person/chat_screen/widget/header.dart';
import 'package:planty_connect/screen/person/chat_screen/widget/message_view/message_view.dart';
import 'package:planty_connect/screen/person/chat_screen/widget/scroll_down_button.dart';
import 'package:planty_connect/service/call_service/call_methods.dart';
import 'package:planty_connect/utils/app.dart';
import 'package:planty_connect/utils/app_state.dart';
import 'package:planty_connect/utils/color_res.dart';
import 'package:planty_connect/utils/common_widgets.dart';
import 'package:planty_connect/utils/styles.dart';
import 'package:stacked/stacked.dart';

AppLifecycleState appLifeState;

// ignore: must_be_immutable
class ChatScreen extends StatefulWidget {
  final UserModel receiver;
  final bool isFromHome;
  String roomId;

  ChatScreen(
    this.receiver,
    this.isFromHome,
    this.roomId,
  );

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    appLifeState = state;
    if (state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      print(widget.roomId);
      if (widget.roomId != null) {
        chatRoomService.updateLastMessage(
          {"${appState.currentUser.uid}_typing": false},
          widget.roomId,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ChatScreenViewModel>.reactive(
      onModelReady: (model) async {
        model.init(widget.receiver, widget.isFromHome, widget.roomId);
      },
      builder: (context, model, child) {
        widget.roomId = model.roomId;
        return Container(
          child: StreamBuilder<DocumentSnapshot>(
              stream: callMethods.callStream(uid: appState.currentUser.uid),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data.data() != null) {
                  Call call = Call.fromMap(snapshot.data.data());
                  if (!call.hasDialled) {
                    return IncomingScreen(
                      call: call,
                    );
                  } else {
                    return Container();
                  }
                } else {
                  return WillPopScope(
                    onWillPop: () async {
                      if (model.isForwardMode || model.isDeleteMode) {
                        model.clearClick();
                      } else {
                        model.onBack();
                      }
                      return false;
                    },
                    child: GestureDetector(
                      onTap: () {
                        if (model.isAttachment) {
                          model.isAttachment = false;
                          model.notifyListeners();
                        }
                      },
                      child: Scaffold(
                        backgroundColor: ColorRes.background,
                        appBar: PreferredSize(
                          preferredSize: Size(Get.width, 50),
                          child: model.roomId == null
                              ? Header(
                                  userModel: widget.receiver,
                                  sender: appState.currentUser,
                                  onBack: model.onBack,
                                  headerClick: model.headerClick,
                                  isDeleteMode: model.isDeleteMode,
                                  isForwardMode: model.isForwardMode,
                                  deleteClick: model.deleteClickMessages,
                                  forwardClick: model.forwardClickMessages,
                                  clearClick: model.clearClick,
                                )
                              : StreamBuilder<DocumentSnapshot>(
                                  stream: chatRoomService
                                      .streamParticularRoom(model.roomId),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      model.roomDocument = snapshot.data;
                                      model.clearNewMessage();
                                      return Header(
                                        userModel: widget.receiver,
                                        sender: appState.currentUser,
                                        onBack: model.onBack,
                                        headerClick: model.headerClick,
                                        isDeleteMode: model.isDeleteMode,
                                        isForwardMode: model.isForwardMode,
                                        deleteClick: model.deleteClickMessages,
                                        forwardClick:
                                            model.forwardClickMessages,
                                        clearClick: model.clearClick,
                                        typing: snapshot.data.get(
                                          "${widget.receiver.uid}_typing",
                                        ),
                                      );
                                    } else {
                                      return Header(
                                        userModel: widget.receiver,
                                        sender: appState.currentUser,
                                        onBack: model.onBack,
                                        headerClick: model.headerClick,
                                        isDeleteMode: model.isDeleteMode,
                                        isForwardMode: model.isForwardMode,
                                        deleteClick: model.deleteClickMessages,
                                        forwardClick:
                                            model.forwardClickMessages,
                                        clearClick: model.clearClick,
                                      );
                                    }
                                  },
                                ),
                        ),
                        body: model.roomId == null
                            ? model.isBusy
                                ? Center(
                                    child: Platform.isIOS
                                        ? CupertinoActivityIndicator()
                                        : CircularProgressIndicator(),
                                  )
                                : Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      AbsorbPointer(
                                        absorbing: model.isAttachment,
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: Center(
                                                child: Text("Send a message"),
                                              ),
                                            ),
                                            InputBottomBar(
                                              msgController: model.controller,
                                              onTextFieldChange:
                                                  model.onTextFieldChange,
                                              onCameraTap: model.onCameraTap,
                                              onSend: model.onSend,
                                              message: model.message,
                                              focusNode: model.focusNode,
                                              onAttachment:
                                                  model.onAttachmentTap,
                                              isTyping: model.isTyping,
                                              clearReply: model.clearReply,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SafeArea(
                                        child: AnimatedOpacity(
                                          opacity: model.isAttachment ? 1 : 0,
                                          duration: Duration(milliseconds: 500),
                                          child: model.isAttachment
                                              ? AttachmentView(
                                                  onGalleryTap: (){
                                                    model.onGalleryTap(context);
                                                  },
                                                  onAudioTap: model.onAudioTap,
                                                  onVideoTap: model.onVideoTap,
                                                  onDocumentTap:
                                                      model.onDocumentTap,
                                                )
                                              : Container(),
                                        ),
                                      ),
                                      model.uploadingMedia
                                          ? Container(
                                              height: Get.height,
                                              width: Get.width,
                                              color: ColorRes.dimGray
                                                  .withOpacity(0.3),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Platform.isIOS
                                                      ? CupertinoActivityIndicator()
                                                      : CircularProgressIndicator(),
                                                  verticalSpaceSmall,
                                                  Text("Uploading media")
                                                ],
                                              ),
                                            )
                                          : Container()
                                    ],
                                  )
                            : Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  AbsorbPointer(
                                    absorbing: model.isAttachment,
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: PaginateFirestore(
                                            padding: EdgeInsets.all(10.0),
                                            query: chatRoomService.getMessages(
                                                model.roomId, model.chatLimit),
                                            itemBuilderType:
                                                PaginateBuilderType.listView,
                                            isLive: true,
                                            itemsPerPage: 10,
                                            scrollController:
                                                model.listScrollController,
                                            itemBuilder: (context, documentSnapshots, index) {
                                              if (!model.listMessage
                                                  .contains(documentSnapshots)) {
                                                model.listMessage
                                                    .add(documentSnapshots[index]);
                                              }
                                              return MessageView(
                                                index,
                                                MessageModel.fromMap(
                                                  documentSnapshots[index].data(),
                                                  documentSnapshots[index].id,
                                                ),
                                                model.downloadDocument,
                                                model.selectedMessages,
                                                model.onTapPressMessage,
                                                model.onLongPressMessage,
                                                model.isDeleteMode,
                                                model.isForwardMode,
                                              );
                                            },
                                            onEmpty: Center(
                                              child: Text("Send message"),
                                            ),
                                            reverse: true,
                                          ),
                                        ),
                                        StreamBuilder<DocumentSnapshot>(
                                          stream: chatRoomService
                                              .streamParticularRoom(
                                                  model.roomId),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              return snapshot.data
                                                          .get("blockBy") ==
                                                      null
                                                  ? InputBottomBar(
                                                      msgController:
                                                          model.controller,
                                                      onTextFieldChange: model
                                                          .onTextFieldChange,
                                                      onCameraTap:
                                                          model.onCameraTap,
                                                      onSend: model.onSend,
                                                      message: model.message,
                                                      focusNode:
                                                          model.focusNode,
                                                      onAttachment:
                                                          model.onAttachmentTap,
                                                      isTyping: model.isTyping,
                                                      clearReply:
                                                          model.clearReply,
                                                    )
                                                  : snapshot.data
                                                              .get("blockBy") ==
                                                          appState
                                                              .currentUser.uid
                                                      ? InkWell(
                                                          onTap: () {
                                                            showConfirmationDialog(
                                                              model.unBlockTap,
                                                              "Are you sure you want to unblock this use?",
                                                            );
                                                          },
                                                          child: Container(
                                                            height: 50,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: ColorRes
                                                                  .white,
                                                              border: Border.all(
                                                                  color:
                                                                      ColorRes
                                                                          .red),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          25),
                                                            ),
                                                            width: Get.width,
                                                            margin:
                                                                EdgeInsets.only(
                                                              left: 5,
                                                              bottom: 5,
                                                              right: 5,
                                                            ),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                              horizontal: 12,
                                                              vertical: 8,
                                                            ),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                horizontalSpaceSmall,
                                                                Icon(
                                                                  Icons.block,
                                                                  color:
                                                                      ColorRes
                                                                          .red,
                                                                  size: 22,
                                                                ),
                                                                horizontalSpaceMedium,
                                                                Text(
                                                                  "Unblock",
                                                                  style:
                                                                      AppTextStyle(
                                                                    fontSize:
                                                                        18,
                                                                    color:
                                                                        ColorRes
                                                                            .red,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        )
                                                      : Container(
                                                          height: 50,
                                                          decoration:
                                                              BoxDecoration(
                                                            color:
                                                                ColorRes.white,
                                                            border: Border.all(
                                                                color: ColorRes
                                                                    .red),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        25),
                                                          ),
                                                          width: Get.width,
                                                          margin:
                                                              EdgeInsets.only(
                                                            left: 5,
                                                            bottom: 5,
                                                            right: 5,
                                                          ),
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                            horizontal: 12,
                                                            vertical: 8,
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              horizontalSpaceSmall,
                                                              Icon(
                                                                Icons.block,
                                                                color: ColorRes
                                                                    .red,
                                                                size: 22,
                                                              ),
                                                              horizontalSpaceMedium,
                                                              Text(
                                                                "You have been blocked",
                                                                style:
                                                                    AppTextStyle(
                                                                  fontSize: 18,
                                                                  color:
                                                                      ColorRes
                                                                          .red,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                            } else {
                                              return Container();
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  SafeArea(
                                    child: AnimatedOpacity(
                                      opacity: model.isAttachment ? 1 : 0,
                                      duration: Duration(milliseconds: 500),
                                      child: model.isAttachment
                                          ? AttachmentView(
                                              onGalleryTap: (){
                                                model.onGalleryTap(context);
                                              },
                                              onAudioTap: model.onAudioTap,
                                              onVideoTap: model.onVideoTap,
                                              onDocumentTap:
                                                  model.onDocumentTap,
                                            )
                                          : Container(),
                                    ),
                                  ),
                                  model.showScrollDownBtn
                                      ? Align(
                                          alignment: Alignment.bottomRight,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 60),
                                            child: ScrollDownButton(
                                              onTap: model.onScrollDownTap,
                                            ),
                                          ),
                                        )
                                      : Container(),
                                  model.uploadingMedia
                                      ? Container(
                                          height: Get.height,
                                          width: Get.width,
                                          color:
                                              ColorRes.dimGray.withOpacity(0.3),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Platform.isIOS
                                                  ? CupertinoActivityIndicator()
                                                  : CircularProgressIndicator(),
                                              verticalSpaceSmall,
                                              Text("Uploading media")
                                            ],
                                          ),
                                        )
                                      : Container()
                                ],
                              ),
                      ),
                    ),
                  );
                }
              }),
        );
      },
      viewModelBuilder: () => ChatScreenViewModel(),
    );
  }
}
