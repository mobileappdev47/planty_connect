import 'package:flutter/material.dart';
import 'package:planty_connect/utils/color_res.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ScrollDownButton extends StatelessWidget {
  const ScrollDownButton({Key key, this.onTap}) : super(key: key);

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ColorRes.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 2,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          height: 28.h,
          width: 28.h,
          margin: EdgeInsets.symmetric(horizontal: 16),
          child: Icon(
            Icons.arrow_circle_down,
            size: 25.h,
            color: ColorRes.green,
          ),
        ),
      ),
    );
  }
}
