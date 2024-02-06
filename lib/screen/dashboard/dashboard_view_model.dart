import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:planty_connect/screen/group/new_group/add_description/add_description.dart';
import 'package:planty_connect/screen/group/new_group/select_member/select_members.dart';
import 'package:planty_connect/screen/person/settings/setting.dart';
import 'package:planty_connect/utils/app_state.dart';
import 'package:stacked/stacked.dart';

class DashboardViewModel extends BaseViewModel {
  TabController tabController;

  void createGroupClick() {
    Get.to(() => appState.currentUser.isAdmin == true
        ? AddDescription([])
        : SelectMembers(true));
  }

  void personalChatClick() {
    Get.to(() => SelectMembers(false));
  }

  gotoSettingPage() {
    Get.to(() => SettingDetails());
  }

  onInit() async {
    setBusy(true);
    await FirebaseFirestore.instance
        .collection("users")
        .where("isAdmin", isEqualTo: true)
        .get()
        .then((value) {
      appState.adminUid = value.docs[0].data()['uid'];
    });
    setBusy(false);
    notifyListeners();
  }
}
