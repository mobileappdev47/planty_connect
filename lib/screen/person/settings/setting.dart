import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:planty_connect/model/call_model.dart';
import 'package:planty_connect/screen/call/incoming_call/incoming_screen.dart';
import 'package:planty_connect/screen/person/settings/setting_view_model.dart';
import 'package:planty_connect/service/call_service/call_methods.dart';
import 'package:planty_connect/utils/app.dart';
import 'package:planty_connect/utils/app_state.dart';
import 'package:planty_connect/utils/color_res.dart';
import 'package:planty_connect/utils/styles.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';

class SettingDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SettingViewModel>.reactive(
      onModelReady: (model) async {
        model.init();
      },
      builder: (context, model, child) {
        return Container(
          child: StreamBuilder<DocumentSnapshot>(
              stream: callMethods.callStream(uid: appState.currentUser.uid),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data.data() != null) {
                  Call call = Call.fromMap(snapshot.data.data());
                  if (!call.hasDialled) {
                    return IncomingScreen(call: call,);
                  } else {
                    return Container();
                  }
                } else {
                  return Scaffold(
                    body: NestedScrollView(
                      headerSliverBuilder: (_, __) {
                        return <Widget>[
                          SliverAppBar(
                            expandedHeight: 200.h,
                            floating: false,
                            pinned: true,
                            flexibleSpace: LayoutBuilder(
                              builder: (BuildContext context,
                                  BoxConstraints constraints) {
                                model.isExpanded =
                                    constraints.biggest.height != 80;
                                return FlexibleSpaceBar(
                                  background: model.imageLoader
                                      ? Center(
                                          child: Platform.isIOS
                                              ? CupertinoActivityIndicator()
                                              : CircularProgressIndicator(),
                                        )
                                      : InkWell(
                                          onTap: model.imageClick,
                                          child: appState.currentUser
                                                      .profilePicture ==
                                                  null
                                              ? Icon(
                                                  Icons.group,
                                                  color: ColorRes.dimGray,
                                                )
                                              : FadeInImage(
                                                  image: NetworkImage(appState
                                                      .currentUser
                                                      .profilePicture),
                                                  fit: BoxFit.cover,
                                                  placeholder: AssetImage(
                                                      AssetsRes.profileImage),
                                                ),
                                        ),
                                );
                              },
                            ),
                            backgroundColor: ColorRes.white,
                            elevation: 0,
                            leading: IconButton(
                              icon: Icon(
                                Platform.isIOS
                                    ? Icons.arrow_back_ios_rounded
                                    : Icons.arrow_back_rounded,
                                color: ColorRes.dimGray,
                              ),
                              onPressed: () => Get.back(),
                            ),
                          ),
                        ];
                      },
                      body: SingleChildScrollView(
                        child: Column(
                          children: [
                            verticalSpaceSmall,
                            Container(
                              color: ColorRes.white,
                              width: Get.width,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          appState.currentUser.name,
                                          style: AppTextStyle(
                                            fontSize: 18,
                                            color: ColorRes.black,
                                          ),
                                        ),
                                        Text(
                                          "This is not your username or pin. This name \nwill be visible to your contacts.",
                                          style: AppTextStyle(
                                            fontSize: 14,
                                            color: ColorRes.dimGray
                                                .withOpacity(0.5),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: model.editTap,
                                    child: Icon(
                                      Icons.edit,
                                      color: ColorRes.green,
                                      size: 25,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            verticalSpaceSmall,
                            InkWell(
                              onTap: model.logoutTap,
                              child: Container(
                                color: ColorRes.white,
                                width: Get.width,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 7),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.exit_to_app_rounded,
                                      color: ColorRes.green,
                                      size: 25,
                                    ),
                                    horizontalSpaceMedium,
                                    Text(
                                      "Log Out",
                                      style: AppTextStyle(
                                        fontSize: 18,
                                        color: ColorRes.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              }),
        );
      },
      viewModelBuilder: () => SettingViewModel(),
    );
  }
}
