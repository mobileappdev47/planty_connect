import 'package:flutter/material.dart';
import 'package:planty_connect/model/message_model.dart';
import 'package:planty_connect/screen/person/chat_screen/widget/reply_message.dart';
import 'package:planty_connect/utils/app.dart';
import 'package:planty_connect/utils/color_res.dart';
import 'package:planty_connect/utils/styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InputBottomBar extends StatelessWidget {
  InputBottomBar({
    this.msgController,
    this.onTextFieldChange,
    this.onCameraTap,
    this.onSend,
    this.focusNode,
    this.onAttachment,
    this.isTyping,
    this.message,
    this.clearReply,
  });

  final TextEditingController msgController;
  final VoidCallback onTextFieldChange;
  final VoidCallback onCameraTap;
  final VoidCallback onAttachment;
  final Function(MMessage) onSend;
  final FocusNode focusNode;
  final bool isTyping;
  final MMessage message;
  final Function clearReply;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: message == null
          ? Container(
              padding: EdgeInsets.only(
                left: 5,
              ),
              margin: EdgeInsets.only(left: 5, bottom: 5, right: 5),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: 5),
                      padding: EdgeInsets.only(left: 5),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: ColorRes.green,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: TextField(
                              style: AppTextStyle(color: ColorRes.white),
                              maxLines: 5,
                              focusNode: focusNode,
                              textCapitalization: TextCapitalization.sentences,
                              minLines: 1,
                              onChanged: (_) {
                                onTextFieldChange();
                              },
                              controller: msgController,
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: AppRes.type_a_message,
                                counterText: '',
                                hintStyle: AppTextStyle(
                                  fontSize: 15,
                                  color: ColorRes.white,
                                ),
                                contentPadding:
                                    EdgeInsets.only(left: 10.h, bottom: 5.h),
                              ),
                            ),
                          ),
                          isTyping
                              ? Container()
                              : Container(
                                  padding: EdgeInsets.only(left: 13, right: 5),
                                  child: RotationTransition(
                                    turns: AlwaysStoppedAnimation(135 / 360),
                                    child: InkWell(
                                      onTap: () {
                                        onAttachment.call();
                                      },
                                      child: Icon(
                                        Icons.attachment,
                                        size: 28,
                                        color: ColorRes.white,
                                      ),
                                    ),
                                  ),
                                ),
                          isTyping
                              ? Container()
                              : Container(
                                  padding: EdgeInsets.only(left: 5, right: 11),
                                  child: InkWell(
                                    onTap: onCameraTap,
                                    child: Icon(
                                      Icons.camera_alt,
                                      color: ColorRes.white,
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      onSend.call(message);
                    },
                    child: Container(
                      height: 50,
                      padding: EdgeInsets.only(left: 13, right: 11),
                      decoration: BoxDecoration(
                        color: ColorRes.green,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(
                        Icons.send,
                        color: ColorRes.white,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Container(
              padding: EdgeInsets.only(
                left: 5,
              ),
              margin: EdgeInsets.only(left: 5, bottom: 5, right: 5),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: message.mDataType == "photo" ? 7 : 16,
                        vertical: 6),
                    margin: EdgeInsets.only(bottom: 5),
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: ColorRes.green,
                        ),
                        borderRadius: BorderRadius.circular(25),
                        color: ColorRes.green.withOpacity(0.1)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ReplyMessage(message),
                        InkWell(
                          onTap: () {
                            clearReply.call();
                          },
                          child: Icon(
                            Icons.close_rounded,
                            color: ColorRes.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: 5),
                          padding: EdgeInsets.only(left: 5),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: ColorRes.green,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: TextField(
                                  style: AppTextStyle(color: ColorRes.white),
                                  maxLines: 5,
                                  focusNode: focusNode,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  minLines: 1,
                                  onChanged: (_) {
                                    onTextFieldChange();
                                  },
                                  controller: msgController,
                                  keyboardType: TextInputType.multiline,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: AppRes.type_a_message,
                                    counterText: '',
                                    hintStyle: AppTextStyle(
                                      fontSize: 15,
                                      color: ColorRes.white,
                                    ),
                                    contentPadding: EdgeInsets.only(
                                        left: 10.h, bottom: 5.h),
                                  ),
                                ),
                              ),
                              isTyping
                                  ? Container()
                                  : Container(
                                      padding:
                                          EdgeInsets.only(left: 13, right: 5),
                                      child: RotationTransition(
                                        turns:
                                            AlwaysStoppedAnimation(135 / 360),
                                        child: InkWell(
                                          onTap: () {
                                            if (message != null)
                                              clearReply.call();
                                            else
                                              onAttachment.call();
                                          },
                                          child: Icon(
                                            Icons.attachment,
                                            size: 28,
                                            color: ColorRes.white,
                                          ),
                                        ),
                                      ),
                                    ),
                              isTyping
                                  ? Container()
                                  : Container(
                                      padding:
                                          EdgeInsets.only(left: 5, right: 11),
                                      child: InkWell(
                                        onTap: () {
                                          if (message != null)
                                            clearReply.call();
                                          else
                                            onCameraTap.call();
                                        },
                                        child: Icon(
                                          Icons.camera_alt,
                                          color: ColorRes.white,
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (msgController.text.trim().isNotEmpty) {
                            clearReply.call();
                            onSend.call(message);
                          }
                        },
                        child: Container(
                          height: 50,
                          padding: EdgeInsets.only(left: 13, right: 11),
                          decoration: BoxDecoration(
                            color: ColorRes.green,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Icon(
                            Icons.send,
                            color: ColorRes.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
