import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:planty_connect/model/group_model.dart';
import 'package:planty_connect/model/user_model.dart';
import 'package:planty_connect/screen/group/group_details/group_details_view_model.dart';
import 'package:planty_connect/utils/app.dart';
import 'package:planty_connect/utils/app_state.dart';
import 'package:planty_connect/utils/color_res.dart';
import 'package:planty_connect/utils/styles.dart';

class MembersCard extends StatelessWidget {
  final List<GroupMember> groupMembers;
  final GroupDetailsViewModel model;

  MembersCard(this.groupMembers, this.model);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: groupMembers.length,
      shrinkWrap: true,
      padding: EdgeInsets.all(0),
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return StreamBuilder<DocumentSnapshot>(
          stream: userService.getUserStream(groupMembers[index].memberId),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              UserModel userModel = UserModel.fromMap(snapshot.data.data());
              return GestureDetector(
                onTap: () {
                  if (userModel.uid != appState.currentUser.uid) {
                    model.groupMembersTap.call(
                      groupMembers[index],
                      groupMembers
                          .firstWhere((element) =>
                              element.memberId == appState.currentUser.uid)
                          .isAdmin,
                      model,
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: Image.network(
                            userModel.profilePicture,
                            height: 40,
                            width: 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          width: Get.width,
                          child: Text(
                            userModel.uid == appState.currentUser.uid
                                ? "You"
                                : userModel.name,
                            style: AppTextStyle(
                              color: ColorRes.black,
                              fontSize: 16,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      groupMembers[index].isAdmin
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: ColorRes.green),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "admin",
                                style: AppTextStyle(
                                  color: ColorRes.green,
                                  fontSize: 14,
                                ),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
              );
            } else {
              return Container();
            }
          },
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider();
      },
    );
  }
}
