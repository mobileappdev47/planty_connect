import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:planty_connect/utils/app.dart';
import 'package:planty_connect/utils/color_res.dart';
import 'package:planty_connect/utils/common_widgets.dart';

// ignore: must_be_immutable
class PersonInfoDialog extends StatelessWidget {
  final String title;
  final Function(String) doneTap;

  PersonInfoDialog(this.title, this.doneTap) {
    nameController = TextEditingController(text: title);
  }

  get divider => Container(
        height: 0.5,
        width: Get.width,
        color: ColorRes.dimGray.withOpacity(0.3),
      );

  TextEditingController nameController;

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
              controller: nameController,
              decoration: InputDecoration(
                hintText: AppRes.type_your_name_here,
              ),
              validator: (s) {
                if (s.isEmpty) {
                  return AppRes.can_not_be_empty;
                } else {
                  return null;
                }
              },
            ),
            verticalSpaceMedium,
            EvolveButton(
              onTap: () {
                if (_formKey.currentState.validate()) {
                  Get.back();
                  doneTap.call(
                    nameController.text.trim(),
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
}
