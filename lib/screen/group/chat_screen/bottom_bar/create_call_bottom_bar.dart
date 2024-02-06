import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:planty_connect/model/group_model.dart';
import 'package:planty_connect/model/user_model.dart';
import 'package:planty_connect/screen/group/group_details/add_member/widgets/user_card.dart';
import 'package:planty_connect/service/call_service/call_methods.dart';
import 'package:planty_connect/service/call_service/call_utilities.dart';
import 'package:planty_connect/utils/app.dart';
import 'package:planty_connect/utils/app_state.dart';
import 'package:planty_connect/utils/color_res.dart';
import 'package:planty_connect/utils/styles.dart';

// ignore: must_be_immutable
class CreateCallBottomBar extends StatefulWidget {
  CreateCallBottomBar(GroupModel groupModel) {
    this.groupModel = groupModel;
  }

  GroupModel groupModel;

  @override
  _CreateCallBottomBarState createState() => _CreateCallBottomBarState();
}

class _CreateCallBottomBarState extends State<CreateCallBottomBar> {
  List<UserModel> members = [];
  List<String> membersId = [];
  List<UserModel> selectedMembers = [];

  @override
  void initState() {
    fillMembersId();
    fillMemberModel().then((value) {
      Future.delayed(Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {});
        }
      });
    });
    super.initState();
  }

  void fillMembersId() {
    widget.groupModel.members.forEach((element) {
      if (element.memberId != appState.currentUser.uid) {
        membersId.add(element.memberId);
      }
    });
  }

  Future<void> fillMemberModel() async {
    membersId.forEach((element) async {
      await userService.getUserModel(element).then((userModel) {
        members.add(userModel);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: callMethods.callStream(uid: appState.currentUser.uid),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data.data() != null) {
            Get.back();
          }
          return Container(
            height: Get.height / 1.7,
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      bottom: 10,
                      left: 10,
                      top: 15,
                    ),
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppRes.selectContact,
                          style: AppTextStyle(
                              color: ColorRes.green, weight: FontWeight.w600),
                        ),
                        selectedMembers.length > 0
                            ? Container(
                                child: Row(
                                  children: [
                                    InkWell(
                                      onTap: onVideoCallTap,
                                      child: Container(
                                        padding: EdgeInsets.only(
                                            right: 10, left: 10),
                                        child: Icon(Icons.video_call),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {},
                                      child: Container(
                                        padding: EdgeInsets.only(
                                            right: 10, left: 10),
                                        child: Icon(Icons.call),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        return UserCard(
                          user: members[index],
                          onTap: selectUserClick,
                          isSelected: isSelected(members[index]),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  bool isSelected(UserModel userModel) {
    return selectedMembers.contains(userModel);
  }

  void selectUserClick(UserModel user) async {
    if (selectedMembers.contains(user))
      selectedMembers.remove(user);
    else
      selectedMembers.add(user);
    setState(() {});
  }

  Future<void> onVideoCallTap() async {
    var status = await Permission.camera.request();
    var status1 = await Permission.microphone.request();
    if (status.isGranted && status1.isGranted) {
      CallUtils.dial(
        from: appState.currentUser,
        toList: selectedMembers,
        context: context,
      );
    }
  }
}
