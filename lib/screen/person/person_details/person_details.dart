import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:planty_connect/model/call_model.dart';
import 'package:planty_connect/model/user_model.dart';
import 'package:planty_connect/screen/call/incoming_call/incoming_screen.dart';
import 'package:planty_connect/screen/person/person_details/person_details_view_model.dart';
import 'package:planty_connect/service/call_service/call_methods.dart';
import 'package:planty_connect/utils/app.dart';
import 'package:planty_connect/utils/app_state.dart';
import 'package:planty_connect/utils/color_res.dart';
import 'package:planty_connect/utils/styles.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';

class PersonDetails extends StatelessWidget {
  final UserModel userModel;
  final String roomId;

  PersonDetails(this.userModel, this.roomId);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PersonDetailsViewModel>.reactive(
      onModelReady: (model) async {
        model.init(userModel, roomId);
      },
      builder: (context, model, child) {
        return Container(
          child: StreamBuilder<DocumentSnapshot>(
              stream: callMethods.callStream(uid: appState.currentUser.uid),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data.data() != null) {
                  Call call = Call.fromMap(snapshot.data.data());
                  if (!call.hasDialled) {
                    return IncomingScreen(call: call,);
                  } else {
                    return Container();
                  }
                } else {
                  return Scaffold(
                    body: NestedScrollView(
                      headerSliverBuilder: (_, __) {
                        return <Widget>[
                          SliverAppBar(
                            expandedHeight: 200.h,
                            floating: false,
                            pinned: true,
                            flexibleSpace: LayoutBuilder(builder:
                                (BuildContext context,
                                    BoxConstraints constraints) {
                              model.isExpanded =
                                  constraints.biggest.height != 80;
                              return FlexibleSpaceBar(
                                background: FadeInImage(
                                  image: NetworkImage(userModel.profilePicture),
                                  fit: BoxFit.cover,
                                  placeholder:
                                      AssetImage(AssetsRes.profileImage),
                                ),
                              );
                            }),
                            backgroundColor: ColorRes.white,
                            elevation: 0,
                            leading: IconButton(
                              icon: Icon(
                                Platform.isIOS
                                    ? Icons.arrow_back_ios_rounded
                                    : Icons.arrow_back_rounded,
                                color: ColorRes.dimGray,
                              ),
                              onPressed: () => Get.back(),
                            ),
                          ),
                        ];
                      },
                      body: SingleChildScrollView(
                        child: Column(
                          children: [
                            verticalSpaceSmall,
                            Container(
                              color: ColorRes.white,
                              width: Get.width,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              child: Text(
                                userModel.name,
                                style: AppTextStyle(
                                  fontSize: 18,
                                  color: ColorRes.black,
                                ),
                              ),
                            ),
                            verticalSpaceSmall,
                            Container(
                              color: ColorRes.white,
                              width: Get.width,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Email",
                                          style: AppTextStyle(
                                            fontSize: 18,
                                            color: ColorRes.green,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          userModel.email,
                                          style: AppTextStyle(
                                            fontSize: 14,
                                            color: ColorRes.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.message_rounded,
                                    color: ColorRes.green,
                                    size: 25,
                                  )
                                ],
                              ),
                            ),
                            verticalSpaceSmall,
                            roomId != null
                                ? StreamBuilder<DocumentSnapshot>(
                                    stream: chatRoomService
                                        .streamParticularRoom(roomId),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return snapshot.data.get("blockBy") ==
                                                null
                                            ? InkWell(
                                                onTap: () {
                                                  showConfirmationDialog(
                                                      model.blockTap,
                                                      "Are you sure you want to block this use?");
                                                },
                                                child: Container(
                                                  color: ColorRes.white,
                                                  height: 50,
                                                  width: Get.width,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8),
                                                  child: Row(
                                                    children: [
                                                      horizontalSpaceSmall,
                                                      Icon(
                                                        Icons.block,
                                                        color: ColorRes.red,
                                                        size: 22,
                                                      ),
                                                      horizontalSpaceMedium,
                                                      Text(
                                                        "Block",
                                                        style: AppTextStyle(
                                                          fontSize: 18,
                                                          color: ColorRes.red,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : snapshot.data.get("blockBy") ==
                                                    appState.currentUser.uid
                                                ? InkWell(
                                                    onTap: () {
                                                      showConfirmationDialog(
                                                          model.unBlockTap,
                                                          "Are you sure you want to unblock this use?");
                                                    },
                                                    child: Container(
                                                      color: ColorRes.white,
                                                      height: 50,
                                                      width: Get.width,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 12,
                                                              vertical: 8),
                                                      child: Row(
                                                        children: [
                                                          horizontalSpaceSmall,
                                                          Icon(
                                                            Icons.block,
                                                            color: ColorRes.red,
                                                            size: 22,
                                                          ),
                                                          horizontalSpaceMedium,
                                                          Text(
                                                            "Unblock",
                                                            style: AppTextStyle(
                                                              fontSize: 18,
                                                              color:
                                                                  ColorRes.red,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                : Container();
                                      } else {
                                        return Container();
                                      }
                                    },
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              }),
        );
      },
      viewModelBuilder: () => PersonDetailsViewModel(),
    );
  }
}
