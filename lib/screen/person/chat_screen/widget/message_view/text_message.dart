import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:planty_connect/model/message_model.dart';
import 'package:planty_connect/screen/person/chat_screen/widget/reply_message.dart';
import 'package:planty_connect/utils/app.dart';
import 'package:planty_connect/utils/color_res.dart';
import 'package:planty_connect/utils/styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class TextMessage extends StatelessWidget {
  final MessageModel message;
  final bool sender;

  TextMessage(this.message, this.sender);

  @override
  Widget build(BuildContext context) {
    return message.mMessage != null && message.mMessage.mType == Type.reply
        ? Container(
            decoration: BoxDecoration(
              color: sender? ColorRes.green:ColorRes.grey,
              borderRadius: BorderRadius.circular(8),
            ),
            margin: EdgeInsets.only(
              left: sender ? 10 : 0,
              right: sender ? 0 : 10,
              bottom: 10,
            ),
            child: Column(
              crossAxisAlignment:
                  sender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 220.h,
                  constraints: BoxConstraints(
                    maxHeight: 200.h,
                  ),
                  decoration: BoxDecoration(
                    color: ColorRes.white.withOpacity(0.2),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8),
                      topLeft: Radius.circular(8),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ReplyMessage(message.mMessage),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: sender? ColorRes.green:ColorRes.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  width: 220.h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                        child: Linkify(
                          onOpen: (link) async {
                            if (await canLaunch(link.url)) {
                              await launch(link.url);
                            }
                          },
                          text: message.content,
                          style: AppTextStyle(
                            color: ColorRes.white,
                            fontSize: 14,
                          ),
                          linkStyle: AppTextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                              fontSize: 14),
                        ),
                      ),
                      SizedBox(width: 8.0),
                      Text(
                        hFormat(DateTime.fromMillisecondsSinceEpoch(
                            message.sendTime)),
                        style: AppTextStyle(
                          color: ColorRes.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            constraints: BoxConstraints(
              maxWidth: Get.width / 1.3,
            ),
          )
        : Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 6,
            ),
            constraints: BoxConstraints(
              maxWidth: Get.width / 1.3,
            ),
            decoration: BoxDecoration(
              color: sender? ColorRes.green:ColorRes.grey,
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.only(
              left: sender ? 10 : 0,
              right: sender ? 0 : 10,
              bottom: 10,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Flexible(
                  child: Linkify(
                    onOpen: (link) async {
                      if (await canLaunch(link.url)) {
                        await launch(link.url);
                      }
                    },
                    text: message.content,
                    style: AppTextStyle(
                      color: ColorRes.white,
                      fontSize: 14,
                    ),
                    linkStyle: AppTextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        fontSize: 14),
                  ),
                ),
                SizedBox(width: 8.0),
                Container(
                  child: Text(
                    hFormat(
                        DateTime.fromMillisecondsSinceEpoch(message.sendTime)),
                    style: AppTextStyle(
                      color: ColorRes.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  margin: EdgeInsets.only(left: 10.0),
                )
              ],
            ),
          );
  }
}
