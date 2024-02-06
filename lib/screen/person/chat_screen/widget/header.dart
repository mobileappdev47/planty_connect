import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:planty_connect/model/user_model.dart';
import 'package:planty_connect/service/call_service/call_utilities.dart';
import 'package:planty_connect/utils/app.dart';
import 'package:planty_connect/utils/color_res.dart';
import 'package:planty_connect/utils/styles.dart';

class Header extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback headerClick;
  final UserModel userModel;
  final UserModel sender;
  final bool isForwardMode;
  final bool isDeleteMode;
  final VoidCallback deleteClick;
  final VoidCallback forwardClick;
  final VoidCallback clearClick;
  final bool typing;

  Header({
    @required this.onBack,
    @required this.headerClick,
    @required this.userModel,
    @required this.sender,
    this.isDeleteMode,
    this.isForwardMode,
    this.deleteClick,
    this.forwardClick,
    this.clearClick,
    this.typing,
  });

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.grey
    ));
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
            boxShadow: [
              BoxShadow(
                  spreadRadius: 1.0,
                  blurRadius: 1.0,
                  offset: Offset(-1,0),
                  color: Colors.grey
              )
            ]
        ),
        height: 60,
        child: Row(
          children: [
            isDeleteMode || isForwardMode
                ? Container(
                    margin: EdgeInsets.symmetric(horizontal: 13),
                    child: InkWell(
                      onTap: clearClick,
                      child: Icon(
                        Icons.clear,
                        color: ColorRes.dimGray,
                      ),
                    ),
                  )
                : Container(
                    margin: EdgeInsets.symmetric(horizontal: 13),
                    child: InkWell(
                      onTap: onBack,
                      child: Icon(
                        Platform.isIOS
                            ? Icons.arrow_back_ios
                            : Icons.arrow_back,
                        color: ColorRes.dimGray,
                      ),
                    ),
                  ),
            Expanded(
              child: InkWell(
                onTap: () {
                  headerClick.call();
                },
                child: Container(
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        height: 30,
                        width: 30,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: FadeInImage(
                            image: NetworkImage(userModel.profilePicture),
                            height: 30,
                            width: 30,
                            fit: BoxFit.cover,
                            placeholder: AssetImage(AssetsRes.profileImage),
                          ),
                        ),
                      ),
                      horizontalSpaceSmall,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              userModel.name,
                              style: AppTextStyle(
                                color: ColorRes.dimGray,
                                fontSize: 16,
                              ),
                            ),
                            if (typing != null && typing)
                              Text(
                                "typing...",
                                style: AppTextStyle(
                                  color: ColorRes.green,
                                  fontSize: 14,
                                ),
                              )
                            else
                              Container(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            isDeleteMode
                ? IconButton(
                    onPressed: deleteClick,
                    icon: Icon(
                      Icons.delete_rounded,
                      color: ColorRes.green,
                    ),
                  )
                : isForwardMode
                    ? IconButton(
                        onPressed: forwardClick,
                        icon: Icon(
                          Icons.fast_forward_rounded,
                          color: ColorRes.green,
                        ),
                      )
                    : IconButton(
                        onPressed: () async {
                    /*      var status = await Permission.camera.request();
                          var status1 = await Permission.microphone.request();
                          if(status.isGranted && status1.isGranted){
                            CallUtils.dial(
                              from: sender,
                              toList: [userModel],
                              context: context,
                            );
                          }*/
                        },
                        icon: Icon(
                          Icons.call,
                          color: ColorRes.white,
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
