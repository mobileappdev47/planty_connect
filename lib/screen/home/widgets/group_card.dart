import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:planty_connect/model/group_model.dart';
import 'package:planty_connect/model/room_model.dart';
import 'package:planty_connect/screen/home/widgets/profile_box.dart';
import 'package:planty_connect/utils/app.dart';
import 'package:planty_connect/utils/app_state.dart';
import 'package:planty_connect/utils/color_res.dart';
import 'package:planty_connect/utils/styles.dart';

class GroupCard extends StatelessWidget {
  final RoomModel groupModel;
  final Function(GroupModel) onTap;
  final int newBadge;

  GroupCard(this.groupModel, this.onTap, {this.newBadge = 0});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap.call(groupModel.groupModel);
      },
      child: Container(
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                  blurRadius: 2.0,
                  spreadRadius: 1.0,
                  offset: Offset(0, 0),
                  color: Colors.grey.withOpacity(0.5))
            ]),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 40,
                width: 40,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: groupModel.groupModel.groupImage == null
                      ? Icon(
                          Icons.group,
                          color: ColorRes.dimGray,
                        )
                      : FadeInImage(
                          image: NetworkImage(
                            groupModel.groupModel.groupImage,
                          ),
                          height: 40,
                          width: 40,
                          fit: BoxFit.cover,
                          placeholder: AssetImage(AssetsRes.groupImage),
                        ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        groupModel.groupModel.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle(
                          color: ColorRes.black,
                          fontSize: 16,
                          weight: FontWeight.bold,
                        ),
                      ),
                      StreamBuilder<DocumentSnapshot>(
                          stream: chatRoomService
                              .streamParticularRoom(groupModel.id),
                          builder: (context, snapshot) {
                            Map<String, dynamic> data = {};
                            if (snapshot.data != null) {
                              data = snapshot.data.data();
                            }
                            String typingId = data['typing_id'];
                            if (snapshot.hasData && typingId != null)
                              return StreamBuilder<DocumentSnapshot>(
                                  stream: userService.getUserStream(typingId),
                                  builder: (context, childSnap) {
                                    Map<String, dynamic> data = {};
                                    if (childSnap.data != null) {
                                      data = childSnap.data.data();
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
                                      return Text(
                                        groupModel.lastMessage,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyle(
                                          color: ColorRes.grey.withOpacity(0.5),
                                          fontSize: 14,
                                          weight: FontWeight.w600,
                                        ),
                                      );
                                  });
                            else
                              return Text(
                                groupModel.lastMessage,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyle(
                                  color: ColorRes.grey.withOpacity(0.5),
                                  fontSize: 14,
                                  weight: FontWeight.w600,
                                ),
                              );
                          }),
                    ],
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                     Stack(
                              children: [
                                groupModel.groupModel.members.length >= 1
                                    ? Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: (profileBox(
                                          groupModel.groupModel.groupImage !=
                                              null,
                                          groupModel.groupModel.groupImage == null
                                              ? ""
                                              : groupModel.groupModel.groupImage)),
                                    )
                                    : (groupModel.groupModel.members.length >= 2
                                        ? Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                          child: Stack(
                                              children: [
                                                profileBox(
                                                    groupModel.groupModel
                                                            .groupImage !=
                                                        null,
                                                    groupModel.groupModel
                                                                .groupImage ==
                                                            null
                                                        ? ""
                                                        : groupModel.groupModel
                                                            .groupImage),
                                                Positioned(
                                                  left: 10,
                                                  child: profileBox(
                                                      groupModel.groupModel
                                                              .groupImage !=
                                                          null,
                                                      groupModel.groupModel
                                                                  .groupImage ==
                                                              null
                                                          ? ""
                                                          : groupModel.groupModel
                                                              .groupImage),
                                                ),
                                              ],
                                            ),
                                        )
                                        : Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                          child: Stack(
                                            alignment: Alignment.center,
                                              children: [
                                                profileBox(
                                                    groupModel.groupModel
                                                            .groupImage !=
                                                        null,
                                                    groupModel.groupModel
                                                                .groupImage ==
                                                            null
                                                        ? ""
                                                        : groupModel.groupModel
                                                            .groupImage),
                                                Positioned(
                                                  left: 10,
                                                  child: profileBox(
                                                      groupModel.groupModel
                                                              .groupImage !=
                                                          null,
                                                      groupModel.groupModel
                                                                  .groupImage ==
                                                              null
                                                          ? ""
                                                          : groupModel.groupModel
                                                              .groupImage),
                                                ),
                                                Positioned(
                                                  left: 20,
                                                  child: profileBox(
                                                      groupModel.groupModel
                                                              .groupImage !=
                                                          null,
                                                      groupModel.groupModel
                                                                  .groupImage ==
                                                              null
                                                          ? ""
                                                          : groupModel.groupModel
                                                              .groupImage),
                                                ),
                                              ],
                                            ),
                                        )),
                              ],
                            ),
                      Text(hFormat(groupModel.lastMessageTime)),
                    ],
                  ),
                  newBadge == 0
                      ? Container()
                      // ignore: dead_code
                      : Container(
                          height: 20,
                          width: 20,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: ColorRes.green,
                            borderRadius: BorderRadius.circular(60),
                          ),
                          child: Text(
                            newBadge.toString(),
                            style: AppTextStyle(
                              color: ColorRes.white,
                              fontSize: 14,
                              weight: FontWeight.bold,
                            ),
                          ),
                        )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
