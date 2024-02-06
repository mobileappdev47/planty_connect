import 'dart:io';

import 'package:flutter/material.dart';
import 'package:planty_connect/utils/app.dart';
import 'package:planty_connect/utils/color_res.dart';
import 'package:planty_connect/utils/styles.dart';

class DescriptionArea extends StatelessWidget {
  final TextEditingController title;
  final TextEditingController description;
  final Function imagePick;
  final File image;
  final GlobalKey<FormState> formKey;

  DescriptionArea({
    @required this.title,
    @required this.description,
    @required this.imagePick,
    @required this.image,
    @required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorRes.white,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () {
                    imagePick.call();
                  },
                  child: image == null
                      ? Container(
                          alignment: Alignment.center,
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: ColorRes.dimGray.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(60),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: ColorRes.white,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: Container(
                            alignment: Alignment.center,
                            height: 50,
                            width: 50,
                            child: Image.file(
                              image,
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                ),
                horizontalSpaceSmall,
                Expanded(
                  child: TextFormField(
                    controller: title,
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
                )
              ],
            ),
            verticalSpaceMedium,
            Text(
              AppRes.provide_group_description_and_icon,
              style: AppTextStyle(
                color: ColorRes.dimGray,
                fontSize: 14,
              ),
            ),
            verticalSpaceSmall,
            TextField(
              controller: description,
              decoration: InputDecoration(
                hintText: AppRes.type_group_description_here,
              ),
              minLines: 1,
              maxLines: 5,
            ),
          ],
        ),
      ),
    );
  }
}
