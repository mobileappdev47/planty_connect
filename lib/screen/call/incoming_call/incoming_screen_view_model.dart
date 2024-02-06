import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:planty_connect/model/call_model.dart';
import 'package:planty_connect/screen/call/call_screen.dart';
import 'package:planty_connect/service/call_service/call_methods.dart';
import 'package:stacked/stacked.dart';

class IncomingViewModel extends BaseViewModel {
  void init({Call call}) {
    this.call = call;
  }

  Call call;
  bool isCallMissed = true;
  final CallMethods callMethods = CallMethods();

  void onCallCut() async {
    isCallMissed = false;
    //Todo : changes for personal call
    //await callMethods.endCall(call: call);
    await callMethods.endCall(call: call);
  }

  void onCallTake() async {
    isCallMissed = false;
    var status = await Permission.camera.request();
    var status1 = await Permission.microphone.request();
    if (status.isGranted && status1.isGranted) {
      Get.to(() => CallScreen(call: call));
    }
  }
}
