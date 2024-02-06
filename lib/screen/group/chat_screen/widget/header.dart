import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:planty_connect/model/group_model.dart';
import 'package:planty_connect/utils/app.dart';
import 'package:planty_connect/utils/app_state.dart';
import 'package:planty_connect/utils/color_res.dart';
import 'package:planty_connect/utils/styles.dart';

class Header extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback headerClick;
  final GroupModel groupModel;
  final bool isForwardMode;
  final bool isDeleteMode;
  final VoidCallback deleteClick;
  final VoidCallback forwardClick;
  final VoidCallback clearClick;
  final VoidCallback addCall;

  Header({
    this.onBack,
    this.headerClick,
    this.groupModel,
    this.isForwardMode,
    this.isDeleteMode,
    this.deleteClick,
    this.forwardClick,
    this.clearClick,
    this.addCall,
  });

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.grey
    ));
    return SafeArea(
      child: Container(

        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  spreadRadius: 1.0,
                  blurRadius: 1.0,
                  offset: Offset(-1,0),
                  color: Colors.grey
              )
            ]
        ),
        height: 60,
        child: Row(
          children: [
            isDeleteMode || isForwardMode
                ? Container(
                    margin: EdgeInsets.symmetric(horizontal: 13),
                    child: InkWell(
                      onTap: clearClick,
                      child: Icon(
                        Icons.clear,
                        color: ColorRes.dimGray,
                      ),
                    ),
                  )
                : InkWell(
                    onTap: onBack,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 13),
                      child: Icon(
                        Platform.isIOS
                            ? Icons.arrow_back_ios
                            : Icons.arrow_back,
                        color: ColorRes.dimGray,
                      ),
                    ),
                  ),
            Expanded(
              child: InkWell(
                onTap: () {
                  headerClick.call();
                },
                child: Container(
                  height: 60,

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: groupModel.groupImage == null
                              ? Icon(
                                  Icons.group,
                                  color: ColorRes.dimGray,
                                )
                              : FadeInImage(
                                  image: NetworkImage(groupModel.groupImage),
                                  height: 40,
                                  width: 40,
                                  fit: BoxFit.cover,
                                  placeholder: AssetImage(AssetsRes.groupImage),
                                ),
                        ),
                      ),
                      horizontalSpaceSmall,
                      Expanded(
                        child: StreamBuilder<DocumentSnapshot>(
                            stream: chatRoomService
                                .streamParticularRoom(groupModel.groupId),
                            builder: (context, snapshot) {
                              Map<String, dynamic> data = {};
                              if (snapshot.data != null) {
                                data = snapshot.data.data();
                              }
                              String typingId = data == null ? appState.currentUser.uid:  data['typing_id'];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    groupModel.name,
                                    style: AppTextStyle(
                                      color: ColorRes.dimGray,
                                      fontSize: 16,
                                    ),
                                  ),
                                  snapshot.hasData
                                      ? (data!=null &&  data['typing_id'] != null &&
                                              data['typing_id'] !=
                                                  appState.currentUser.uid)
                                          ? StreamBuilder<DocumentSnapshot>(
                                              stream: userService
                                                  .getUserStream(typingId),
                                              builder: (context, snapshot) {
                                                Map<String, dynamic> data = {};
                                                if (snapshot.data != null) {
                                                  data = snapshot.data.data();
                                                }
                                                if (snapshot.hasData)
                                                  return Text(
                                                    "${data['name']} typing...",
                                                    style: AppTextStyle(
                                                      color: ColorRes.green,
                                                      fontSize: 14,
                                                    ),
                                                  );
                                                else
                                                  return Container();
                                              })
                                          : Container()
                                      : Container(),
                                ],
                              );
                            }),
                      ),
                    /*  InkWell(
                        onTap: addCall,
                        child: Container(
                          margin: EdgeInsets.only(right: 10),
                          child: Icon(
                            Icons.add_call,
                            size: 22,
                          ),
                        ),
                      ),*/
                    ],
                  ),
                ),
              ),
            ),
            isDeleteMode
                ? IconButton(
                    onPressed: deleteClick,
                    icon: Icon(
                      Icons.delete_rounded,
                      color: ColorRes.green,
                    ),
                  )
                : isForwardMode
                    ? IconButton(
                        onPressed: forwardClick,
                        icon: Icon(
                          Icons.fast_forward_rounded,
                          color: ColorRes.green,
                        ),
                      )
                    : Container(),
          ],
        ),
      ),
    );
  }

  Future<String> getTyperName(String uid) async {
    return await userService.getUser(uid).then((value) {
      Map<String, dynamic> data = value.data();
      return data['name'];
    });
  }
}
