import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:planty_connect/screen/dashboard/dashboard_view_model.dart';
import 'package:planty_connect/screen/home/home_screen.dart';
import 'package:planty_connect/screen/public_screen/public_screen.dart';

import 'package:planty_connect/utils/app.dart';
import 'package:planty_connect/utils/color_res.dart';
import 'package:planty_connect/utils/styles.dart';
import 'package:stacked/stacked.dart';

class DashBoard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DashboardViewModel>.reactive(
      onModelReady: (model){
      model.onInit();
      },
        viewModelBuilder: () => DashboardViewModel(),
        builder: (context, model, child) {
          return Scaffold(
            backgroundColor: ColorRes.purple,
            appBar: AppBar(
              backgroundColor: ColorRes.purple,
              elevation: 0,
              title: Text(
                AppRes.appName,
                style: AppTextStyle(
                  color: ColorRes.white,
                  weight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              actions: [
                PopupMenuButton<String>(
                  onSelected: (String value) {
                    if (value == "create_group") {
                      model.createGroupClick();
                    } else {
                      model.personalChatClick();
                    }
                  },
                  child: Icon(
                    Icons.add_circle_outline,
                    color: ColorRes.white,
                  ),
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'create_group',
                      child: Text(AppRes.create_group),
                    ),
                    const PopupMenuItem<String>(
                      value: 'create_user',
                      child: Text(AppRes.create_personal_chat),
                    ),
                  ],
                ),
              /*  IconButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => SearchScreen())),
                  icon: Icon(
                    Icons.search,
                    color: ColorRes.black,
                  ),
                ),*/
                IconButton(
                  onPressed: model.gotoSettingPage,
                  icon: Icon(
                    Icons.more_vert_outlined,
                    color: ColorRes.white,
                  ),
                ),
              ],
            ),
            body:model.isBusy?Center(child: CircularProgressIndicator(),):  DefaultTabController(
              length: 2,
              child: Scaffold(
                appBar:PreferredSize(
                  preferredSize: Size(Get.width,50),
                  child:  AppBar(
                    backgroundColor: ColorRes.purple,

                    bottom: TabBar(
                      indicatorColor: ColorRes.white,
                      controller: model.tabController,
                      tabs: [
                        Tab(text: "Chats",),
                        Tab(text: "Groups",),
                      ],
                    ),
                  ),
                ),
                body:TabBarView(
                    controller: model.tabController,
                    children: [
                      HomeScreen(),
                      PublicScreen(),
                    ]),
              ),
            ),
          );
        });
  }
}
