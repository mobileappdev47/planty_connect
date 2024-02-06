import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:planty_connect/screen/login/sign_in_view_model.dart';
import 'package:planty_connect/utils/app.dart';
import 'package:planty_connect/utils/color_res.dart';
import 'package:planty_connect/utils/common_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:planty_connect/utils/styles.dart';
import 'package:stacked/stacked.dart';

class SignInScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorRes.background,
      body: ViewModelBuilder<SignInViewModel>.reactive(
        onModelReady: (model) async {
          model.init();
        },
        viewModelBuilder: () => SignInViewModel(),
        builder: (context, model, child) {
          return SafeArea(
            child: Stack(
              children: [
                Center(
                  child: Form(
                    key: model.formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            AppRes.sign_in,
                            style: AppTextStyle(
                              fontSize: 32,
                              color: ColorRes.green,
                              weight: FontWeight.bold,
                            ),
                          ),
                          verticalSpaceMassive,
                          TextFieldWidget(
                            controller: model.emailController,
                            title: AppRes.email,
                            validation: model.emailValidation,
                            readOnly: model.isBusy,
                          ),
                          TextFieldWidget(
                            controller: model.passwordController,
                            title: AppRes.password,
                            validation: model.passwordValidation,
                            obs: true,
                            readOnly: model.isBusy,
                          ),
                          Padding(
                            padding: EdgeInsets.all(20.0),
                            child: model.isBusy
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: ColorRes.green,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: EdgeInsets.all(4),
                                    child: Center(
                                      child: Platform.isMacOS
                                          ? CupertinoActivityIndicator()
                                          : CircularProgressIndicator(),
                                    ),
                                  )
                                : EvolveButton(
                                    onTap: model.submitButtonTap,
                                    title: AppRes.sign_in,
                                  ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: model.forgotPasswordClick,
                                    child: Text(
                                      AppRes.forgot_password,
                                      textAlign: TextAlign.start,
                                      style: AppTextStyle(
                                        fontSize: 16,
                                        color: ColorRes.green,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: model.signUpClick,
                                    child: Text(
                                      AppRes.sign_up,
                                      textAlign: TextAlign.end,
                                      style: AppTextStyle(
                                        fontSize: 16,
                                        color: ColorRes.green,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(
                    Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
                    size: 30.h,
                    color: ColorRes.green,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
