import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:planty_connect/model/message_model.dart';
import 'package:planty_connect/utils/app.dart';
import 'package:planty_connect/utils/color_res.dart';
import 'package:planty_connect/utils/common_widgets.dart';
import 'package:planty_connect/utils/styles.dart';

class MessageDialog extends StatelessWidget {
  final bool sender;
  final Function onReplyTap;
  final Function onForwardTap;
  final Function onForwardMultipleTap;
  final Function onDeleteMultipleTap;
  final Function onDeleteTap;
  final MessageModel message;

  MessageDialog({
    this.sender,
    this.onReplyTap,
    this.onForwardTap,
    this.onForwardMultipleTap,
    this.onDeleteMultipleTap,
    this.onDeleteTap,
    this.message,
  });

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
        cardView(AppRes.reply, onReplyTap),
        divider,
        cardView(AppRes.forward, onForwardTap),
        divider,
        cardView(AppRes.forwardMultiple, onForwardMultipleTap),
        sender ? divider : Container(),
        sender ? cardView(AppRes.delete, onDeleteTap) : Container(),
        sender ? divider : Container(),
        sender
            ? cardView(AppRes.deleteMultiple, onDeleteMultipleTap)
            : Container(),
      ],
    );
  }

  Widget cardView(String title, Function onTap) {
    return InkWell(
      onTap: () {
        onTap.call();
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
