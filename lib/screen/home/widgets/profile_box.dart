import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:planty_connect/utils/app.dart';

Widget profileBox(bool isVal, String img) {
  return Container(
    height: 30,
    width: 30,
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(60),border: Border.all(color: isVal?Colors.transparent: Colors.black)),
    child: isVal == true
        ? ClipRRect(
      borderRadius: BorderRadius.circular(60),
          child: FadeInImage(
              height: 30,
              width: 30,
              fit: BoxFit.cover,
              placeholder: AssetImage(AssetsRes.groupImage),
              image: NetworkImage(img)),
        )
        : Icon(Icons.person),
  );
}
