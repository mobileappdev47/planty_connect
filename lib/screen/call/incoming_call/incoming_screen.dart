import 'package:flutter/material.dart';
import 'package:planty_connect/model/call_model.dart';
import 'package:planty_connect/screen/call/incoming_call/incoming_screen_view_model.dart';
import 'package:planty_connect/screen/person/chat_screen/widget/cached_image.dart';
import 'package:stacked/stacked.dart';

// ignore: must_be_immutable
class IncomingScreen extends StatelessWidget {
  IncomingScreen({
    this.call,
  });

  Call call;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<IncomingViewModel>.reactive(
      onModelReady: (model) {
        model.init(call: this.call);
      },
      builder: (context, model, child) {
        return Scaffold(
          body: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 100),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Incoming...",
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),
                SizedBox(height: 20),
                CachedImage(
                  call.callerPic,
                  isRound: true,
                  radius: 180,
                ),
                SizedBox(height: 15),
                Text(
                  call.callerName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.call_end),
                      color: Colors.redAccent,
                      onPressed: model.onCallCut,
                    ),
                    SizedBox(width: 25),
                    IconButton(
                      icon: Icon(Icons.call),
                      color: Colors.green,
                      onPressed: model.onCallTake,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      viewModelBuilder: () => IncomingViewModel(),
    );
  }
}
