import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:planty_connect/model/group_model.dart';
import 'package:planty_connect/screen/group/group_details/group_details_view_model.dart';
import 'package:planty_connect/utils/app.dart';
import 'package:planty_connect/utils/color_res.dart';
import 'package:planty_connect/utils/common_widgets.dart';
import 'package:planty_connect/utils/styles.dart';

class GroupMemberDialog extends StatelessWidget {
  final GroupMember member;
  final bool isAdmin;
  final GroupModel groupModel;
  final GroupDetailsViewModel model;

  GroupMemberDialog(this.member, this.isAdmin, this.groupModel, this.model);

  get divider => Container(
        height: 0.5,
        width: Get.width,
        color: ColorRes.dimGray.withOpacity(0.3),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        cardView(AppRes.info, model.infoTap),
        divider,
        isAdmin
            ? member.isAdmin
                ? cardView(AppRes.remove_admin, model.removeAdminTap)
                : cardView(AppRes.make_admin, model.makeAdminTap)
            : Container(),
        isAdmin ? divider : Container(),
        isAdmin
            ? cardView(AppRes.remove_from_group, model.removeFromGroupTap)
            : Container(),
        isAdmin ? divider : Container(),
        cardView(AppRes.send_message, model.sendMessageTap),
      ],
    );
  }

  Widget cardView(String title, Function(GroupMember) onTap) {
    return InkWell(
      onTap: () {
        onTap.call(member);
        Get.back();
      },
      child: Container(
        height: 45,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          title,
          style: AppTextStyle(
            color: ColorRes.black,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class GroupInfoDialog extends StatelessWidget {
  final String title;
  final String description;
  final Function(String, String) doneTap;

  GroupInfoDialog(this.title, this.description, this.doneTap) {
    titleController = TextEditingController(text: title);
    descController = TextEditingController(text: description);
  }

  get divider => Container(
        height: 0.5,
        width: Get.width,
        color: ColorRes.dimGray.withOpacity(0.3),
      );

  TextEditingController titleController;
  TextEditingController descController;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: AppRes.type_group_title_here,
              ),
              validator: (s) {
                if (s.isEmpty) {
                  return AppRes.can_not_be_empty;
                } else {
                  return null;
                }
              },
            ),
            verticalSpaceSmall,
            TextField(
              controller: descController,
              minLines: 4,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: AppRes.type_group_title_here,
              ),
            ),
            verticalSpaceSmall,
            EvolveButton(
              onTap: () {
                if (_formKey.currentState.validate()) {
                  Get.back();
                  doneTap.call(
                    titleController.text.trim(),
                    descController.text.trim(),
                  );
                }
              },
              title: AppRes.done,
            )
          ],
        ),
      ),
    );
  }

  Widget cardView(String title, onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 45,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          title,
          style: AppTextStyle(
            color: ColorRes.black,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
