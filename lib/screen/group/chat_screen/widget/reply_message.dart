import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:planty_connect/model/message_model.dart';
import 'package:planty_connect/utils/app.dart';
import 'package:planty_connect/utils/color_res.dart';
import 'package:planty_connect/utils/styles.dart';

class ReplyMessage extends StatelessWidget {
  final MMessage message;

  ReplyMessage(this.message);

  @override
  Widget build(BuildContext context) {
    if (message.mDataType == "text") {
      return Text(message.mContent);
    } else if (message.mDataType == "photo") {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          message.mContent,
          height: 100,
          width: 100,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return FutureBuilder<FullMetadata>(
        future: storageService.getData(message.mContent),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            FullMetadata document = snapshot.data;
            return Text(
              document.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle(
                color: ColorRes.black,
                fontSize: 14,
              ),
            );
          } else {
            return SizedBox(
              height: 30,
            );
          }
        },
      );
    }
  }
}
