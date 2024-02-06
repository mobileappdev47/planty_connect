import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:planty_connect/model/group_model.dart';
import 'package:planty_connect/screen/home/widgets/profile_box.dart';
import 'package:planty_connect/screen/public_screen/public_screen_view_model.dart';
import 'package:planty_connect/service/chat_room_service/chat_room_service.dart';
import 'package:planty_connect/service/group_service/group_service.dart';
import 'package:planty_connect/utils/app.dart';
import 'package:planty_connect/utils/app_state.dart';
import 'package:planty_connect/utils/color_res.dart';
import 'package:stacked/stacked.dart';
import 'package:planty_connect/screen/group/chat_screen/chat_screen.dart'
    as Group;

class PublicScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    ChatRoomService chatRoomService = ChatRoomService();
    GroupService groupService = GroupService();
    String plus = "+";
    return ViewModelBuilder<PublicScreenViewModel>.reactive(
      onModelReady: (model){
//model.onInit();
      },
        viewModelBuilder: () => PublicScreenViewModel(),
        builder: (context, model, child) {
          return Scaffold(
            body: model.isBusy?Center(child: CircularProgressIndicator(),): StreamBuilder(
                stream:chatRoomService.publicRoom(),
                builder: (context, snapshots) {
                  return (snapshots.connectionState == ConnectionState.waiting)
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : SizedBox(
                          height: Get.height - 100,
                          child: snapshots.data.docs.isEmpty
                              ? Center(
                                  child: Text(
                                      "There is no any group created by admin"),
                                )
                              : ListView.builder(
                                  itemCount: snapshots.data.docs.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    GroupModel groupModel = GroupModel.fromMap(
                                        snapshots.data.docs[index].data(),
                                        snapshots.data.docs[index].id);
                                    //print(groupModel.groupId);
                        /*            var data =
                                        snapshots.data.docs[index].data();*/
                           /*         var doc = FirebaseFirestore.instance.collection("chatRoom").doc(snapshots.data.docs[index].id).get();
                                    print(doc);*/

                                    return InkWell(
                                      onTap: () {
                                        bool lst = groupModel.members.any(
                                            (element) =>
                                                element.memberId ==
                                                appState.currentUser.uid);
                                        if (lst == false) {
                                          showDialog(
                                            context: context,
                                            builder: (context) =>
                                                new AlertDialog(
                                              title: new Text('Message'),
                                              content: Text(
                                                  'Are Sure You want to Join '),
                                              actions: <Widget>[
                                                new FlatButton(
                                                  onPressed: () async {
                                                    groupModel.members.add(
                                                        GroupMember(
                                                            isAdmin: false,
                                                            memberId: appState
                                                                .currentUser
                                                                .uid));
                                                    /*setState(() {});*/
                                                    await
                                                    groupService.group.doc(groupModel.groupId)
                                                        .update({
                                                      "members":
                                                          List<dynamic>.from(
                                                              groupModel
                                                                  .members
                                                                  .map((x) => x
                                                                      .toMap()))
                                                    }).then((value) async {
                                                      Get.back();
                                                      Get.to(() =>
                                                          Group.ChatScreen(
                                                              groupModel,
                                                              true));
                                                      await chatRoomService.chatRoom.doc(groupModel
                                                              .groupId)
                                                          .get()
                                                          .then((value) async {
                                                        Map map = value.data();
                                                        List membersId = map[
                                                                'membersId']
                                                            .map<String>((e) =>
                                                                e.toString())
                                                            .toList();
                                                        if (!membersId.contains(
                                                            appState.currentUser
                                                                .uid)) {
                                                          membersId.add(appState
                                                              .currentUser.uid);
                                                          await chatRoomService.chatRoom.doc(groupModel
                                                                  .groupId)
                                                              .update({
                                                            "membersId":
                                                                membersId
                                                          });
                                                        }
                                                      });
                                                    });

                                                    // dismisses only the dialog and returns nothing
                                                  },
                                                  child: new Text('Join '),
                                                ),
                                                new FlatButton(
                                                  onPressed: () {
                                                    Navigator.of(context,
                                                            rootNavigator: true)
                                                        .pop(); // dismisses only the dialog and returns nothing
                                                  },
                                                  child: new Text('Cancel'),
                                                ),
                                              ],
                                            ),
                                          );
                                        } else {
                                          Get.to(() => Group.ChatScreen(
                                              groupModel, true));
                                        }
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
                                          padding: EdgeInsets.all(6),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    height: 40,
                                                    width: 40,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(60),
                                                      child: groupModel
                                                                  .groupImage ==
                                                              null
                                                          ? Icon(
                                                              Icons.group,
                                                              color:
                                                                  ColorRes.dimGray,
                                                            )
                                                          : FadeInImage(
                                                              image: NetworkImage(
                                                                groupModel
                                                                    .groupImage,
                                                              ),
                                                              height: 40,
                                                              width: 40,
                                                              fit: BoxFit.cover,
                                                              placeholder: AssetImage(
                                                                  AssetsRes
                                                                      .groupImage),
                                                            ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(groupModel.name),
                                                      snapshots.data.docs[index].data()['lastMessage']!=null?   Text(snapshots.data.docs[index].data()['lastMessage']):SizedBox()
                                                    ],
                                                  )
                                                ],
                                              ),
                                              Stack(
                                                children: [
                                                  groupModel.members.length == 1
                                                      ? Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                                    child: (profileBox(
                                                        groupModel.groupImage !=
                                                            null,
                                                        groupModel.groupImage == null
                                                            ? ""
                                                            : groupModel.groupImage)),
                                                  )
                                                      : (groupModel.members.length == 2
                                                      ? Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                                    child: SizedBox(
                                                      width: 70,
                                                      child: Stack(
                                                        children: [
                                                          profileBox(
                                                              groupModel
                                                                  .groupImage !=
                                                                  null,
                                                              groupModel
                                                                  .groupImage ==
                                                                  null
                                                                  ? ""
                                                                  : groupModel
                                                                  .groupImage),
                                                          Positioned(
                                                            left: 28,
                                                            child: profileBox(
                                                                groupModel
                                                                    .groupImage !=
                                                                    null,
                                                                groupModel
                                                                    .groupImage ==
                                                                    null
                                                                    ? ""
                                                                    : groupModel
                                                                    .groupImage),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                      : Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                                    child: SizedBox(
                                                      width: 70,
                                                      child: Stack(
                                                        alignment: Alignment.center,
                                                        children: [
                                                          profileBox(
                                                              groupModel
                                                                  .groupImage !=
                                                                  null,
                                                              groupModel
                                                                  .groupImage ==
                                                                  null
                                                                  ? ""
                                                                  : groupModel
                                                                  .groupImage),
                                                          Positioned(
                                                            left: 28,
                                                            child: profileBox(
                                                                groupModel
                                                                    .groupImage !=
                                                                    null,
                                                                groupModel
                                                                    .groupImage ==
                                                                    null
                                                                    ? ""
                                                                    : groupModel
                                                                    .groupImage),
                                                          ),
                                                          Positioned(
                                                            left: 38,
                                                            child: Container(
                                                              height: 30,
                                                              width: 30,
                                                              decoration: BoxDecoration(
                                                                color: Colors.grey,
                                                                borderRadius: BorderRadius.circular(60),

                                                              ),
                                                              child: Center(child: Text("${groupModel.members.length<=99?(groupModel.members.length-2).toString():groupModel.members.length.toString()+plus}"),),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )),
                                                ],
                                              ),
                                         /*     Row(
                                                children: [
                                                  Icon(Icons.person),
                                                 // SizedBox(width: 5,),
                                                  Text(groupModel.members.length.toString())
                                                ],
                                              )*/
                                            ],
                                          ),
                                        ),
                                      ),
                                    );


                                  }));
                }),
          );
        });
  }
}
