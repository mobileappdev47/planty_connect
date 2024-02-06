import 'dart:math';

import 'package:get/get.dart';
import 'package:planty_connect/model/call_model.dart';
import 'package:planty_connect/model/user_model.dart';
import 'package:planty_connect/screen/call/call_screen.dart';
import 'package:planty_connect/service/call_service/call_methods.dart';

class CallUtils {
  static final CallMethods callMethods = CallMethods();

  static dial({UserModel from, List<UserModel> toList, context}) async {
    List<dynamic> currentUser = toList.map<String>((e) => e.uid).toList();
    currentUser.add(from.uid);

    Call call = Call(
      callerId: from.uid,
      callerName: from.name,
      callerPic: from.profilePicture,
      channelId: Random().nextInt(1000).toString(),
      currentUser: currentUser,
    );

    await callMethods.makeCall(call: call).then((value){
      call.hasDialled = true;

      Get.to(() => CallScreen(call: call));
    });
  }
}


