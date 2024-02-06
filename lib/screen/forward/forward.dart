import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:planty_connect/model/group_model.dart';
import 'package:planty_connect/model/message_model.dart';
import 'package:planty_connect/model/user_model.dart';
import 'package:planty_connect/screen/forward/forward_view_model.dart';
import 'package:planty_connect/screen/forward/widgets/group_card.dart';
import 'package:planty_connect/screen/forward/widgets/user_card.dart';
import 'package:planty_connect/utils/app.dart';
import 'package:planty_connect/utils/color_res.dart';
import 'package:planty_connect/utils/styles.dart';
import 'package:stacked/stacked.dart';

class Forward extends StatelessWidget {
  final List<MessageModel> messages;

  Forward(this.messages);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ForwardViewModel>.reactive(
      onModelReady: (model) async {
        model.init(messages);
      },
      viewModelBuilder: () => ForwardViewModel(),
      builder: (context, model, child) {
        return WillPopScope(
          onWillPop: () async {
            Get.back();
            return false;
          },
          child: Scaffold(
            appBar: AppBar(
                backgroundColor: ColorRes.background,
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
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppRes.forward,
                      style: AppTextStyle(
                        color: ColorRes.dimGray,
                        weight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      AppRes.select_person_or_group,
                      style: AppTextStyle(
                        color: ColorRes.dimGray,
                        fontSize: 14,
                      ),
                    ),
                  ],
                )),
            body: model.isBusy
                ? Center(
                    child: Platform.isIOS
                        ? CupertinoActivityIndicator()
                        : CircularProgressIndicator(),
                  )
                : ListView.builder(
                    itemCount: model.rooms.length,
                    itemBuilder: (context, index) {
                      final roomModel = model.rooms[index];
                      if (roomModel.isGroup) {
                        return StreamBuilder<DocumentSnapshot>(
                          stream: groupService.getGroupStream(roomModel.id),
                          builder: (context, groupSnap) {
                            if (groupSnap.connectionState ==
                                    ConnectionState.active &&
                                groupSnap.hasData) {
                              roomModel.groupModel = GroupModel.fromMap(
                                  groupSnap.data.data(), groupSnap.data.id);
                              return GroupCard(
                                roomModel,
                                model.selectUserClick,
                                model.isSelected(roomModel),
                              );
                            } else {
                              return Container();
                            }
                          },
                        );
                      } else {
                        return StreamBuilder<DocumentSnapshot>(
                          stream: userService
                              .getRoomUserStream(roomModel.membersId),
                          builder: (context, personSnap) {
                            if (personSnap.connectionState ==
                                    ConnectionState.active &&
                                personSnap.hasData) {
                              roomModel.userModel =
                                  UserModel.fromMap(personSnap.data.data());
                              return UserCard(
                                roomModel,
                                model.selectUserClick,
                                model.isSelected(roomModel),
                              );
                            } else {
                              return Container();
                            }
                          },
                        );
                      }
                    },
                  ),
            floatingActionButton: FloatingActionButton(
              onPressed: model.nextClick,
              child: Icon(
                Icons.navigate_next_rounded,
                color: ColorRes.white,
              ),
              backgroundColor: ColorRes.green,
            ),
          ),
        );
      },
    );
  }
}
