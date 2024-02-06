import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:planty_connect/model/group_model.dart';
import 'package:planty_connect/screen/group/group_details/group_details_view_model.dart';
import 'package:planty_connect/screen/group/group_details/widgets/members_card.dart';
import 'package:planty_connect/utils/app.dart';
import 'package:planty_connect/utils/app_state.dart';
import 'package:planty_connect/utils/color_res.dart';
import 'package:planty_connect/utils/styles.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';

class GroupDetails extends StatelessWidget {
  final GroupModel groupModel;

  GroupDetails(this.groupModel);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<GroupDetailsViewModel>.reactive(
      onModelReady: (model) async {
        model.init(groupModel);
      },
      builder: (context, model, child) {
        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (_, __) {
              return <Widget>[
                SliverAppBar(
                  expandedHeight: 200.h,
                  floating: false,
                  pinned: true,
                  flexibleSpace: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      model.isExpanded = constraints.biggest.height != 80;
                      return FlexibleSpaceBar(
                        background: model.imageLoader
                            ? Center(
                                child: Platform.isIOS
                                    ? CupertinoActivityIndicator()
                                    : CircularProgressIndicator(),
                              )
                            :  InkWell(
                                onTap: model.imageClick,
                                child: groupModel.groupImage == null
                                    ? Icon(
                                        Icons.group,
                                        color: ColorRes.dimGray,
                                      )
                                    : FadeInImage(
                                        image:
                                            NetworkImage(groupModel.groupImage),
                                        fit: BoxFit.cover,
                                        placeholder:
                                            AssetImage(AssetsRes.groupImage),
                                      ),
                              ),
                      );
                    },
                  ),
                  backgroundColor: ColorRes.white,
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(
                      Platform.isIOS
                          ? Icons.arrow_back_ios_rounded
                          : Icons.arrow_back_rounded,
                      color: ColorRes.dimGray,
                    ),
                    onPressed: () {
                      Get.back(result: true);
                    },
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
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                groupModel.name,
                                style: AppTextStyle(
                                  fontSize: 18,
                                  color: ColorRes.black,
                                ),
                              ),
                              Text(
                                groupModel.description,
                                style: AppTextStyle(
                                  fontSize: 15,
                                  color: ColorRes.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        groupModel.members
                                .firstWhere((element) =>
                                    element.memberId ==
                                    appState.currentUser.uid)
                                .isAdmin
                            ? GestureDetector(
                                onTap: model.editTap,
                                child: Icon(
                                  Icons.edit,
                                  color: ColorRes.green,
                                  size: 25,
                                ),
                              )
                            : Container()
                      ],
                    ),
                  ),
                  verticalSpaceSmall,
                  model.isAdmin
                      ? InkWell(
                          onTap: model.addParticipants,
                          child: Container(
                            color: ColorRes.white,
                            height: 50,
                            width: Get.width,
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: Row(
                              children: [
                                horizontalSpaceSmall,
                                Icon(
                                  Icons.person_add,
                                  color: ColorRes.green,
                                  size: 22,
                                ),
                                horizontalSpaceMedium,
                                Text(
                                  AppRes.add_participants,
                                  style: AppTextStyle(
                                    fontSize: 18,
                                    color: ColorRes.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(),
                  model.isAdmin ? verticalSpaceSmall : Container(),
                  Container(
                    color: ColorRes.white,
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    child: MembersCard(
                      groupModel.members,
                      model,
                    ),
                  ),
                  verticalSpaceSmall,
                  InkWell(
                    onTap: () {
                      showConfirmationDialog(
                        model.leftGroupTap,
                        "Are you sure you want to left this group?",
                      );
                    },
                    child: Container(
                      color: ColorRes.white,
                      height: 50,
                      width: Get.width,
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          horizontalSpaceSmall,
                          Icon(
                            Icons.exit_to_app_rounded,
                            color: ColorRes.red,
                            size: 22,
                          ),
                          horizontalSpaceMedium,
                          Text(
                            AppRes.left_group,
                            style: AppTextStyle(
                              fontSize: 18,
                              color: ColorRes.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  verticalSpaceSmall,
                  groupModel.createdBy == appState.currentUser.uid
                      ? InkWell(
                          onTap: () {
                            showConfirmationDialog(
                              model.deleteGroupTap,
                              "Are you sure you want to delete this group?",
                            );
                          },
                          child: Container(
                            color: ColorRes.white,
                            height: 50,
                            width: Get.width,
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: Row(
                              children: [
                                horizontalSpaceSmall,
                                Icon(
                                  Icons.delete_rounded,
                                  color: ColorRes.red,
                                  size: 22,
                                ),
                                horizontalSpaceMedium,
                                Text(
                                  AppRes.delete_group,
                                  style: AppTextStyle(
                                    fontSize: 18,
                                    color: ColorRes.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        );
      },
      viewModelBuilder: () => GroupDetailsViewModel(),
    );
  }
}
