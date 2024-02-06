import 'package:flutter/material.dart';
import 'package:planty_connect/model/room_model.dart';
import 'package:planty_connect/model/user_model.dart';
import 'package:planty_connect/utils/app.dart';
import 'package:planty_connect/utils/color_res.dart';
import 'package:planty_connect/utils/styles.dart';

class UserCard extends StatelessWidget {
  final RoomModel user;
  final Function(UserModel, String) onTap;
  final bool typing;
  final int newBadge;

  UserCard(this.user, this.onTap, {this.typing = false, this.newBadge = 0});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap.call(user.userModel, user.id);
      },
      child: Container(
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                  blurRadius: 2.0,
                  spreadRadius: 1.0,
                  offset: Offset(0, 0),
                  color: Colors.grey.withOpacity(0.5))
            ]),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 40,
                width: 40,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: FadeInImage(
                    image: NetworkImage(user.userModel.profilePicture),
                    height: 40,
                    width: 40,
                    fit: BoxFit.cover,
                    placeholder: AssetImage(AssetsRes.profileImage),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.userModel.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle(
                          color: ColorRes.black,
                          fontSize: 16,
                          weight: FontWeight.bold,
                        ),
                      ),
                      typing
                          ? Text(
                              "typing...",
                              style: AppTextStyle(
                                color: ColorRes.green,
                                fontSize: 14,
                              ),
                            )
                          : Text(
                              user.lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyle(
                                color: ColorRes.grey.withOpacity(0.5),
                                fontSize: 14,
                                weight: FontWeight.w600,
                              ),
                            ),
                    ],
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(hFormat(user.lastMessageTime)),
                  newBadge == 0
                      ? Container()
                      : Container(
                          height: 20,
                          width: 20,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: ColorRes.green,
                            borderRadius: BorderRadius.circular(60),
                          ),
                          child: Text(
                            newBadge.toString(),
                            style: AppTextStyle(
                              color: ColorRes.white,
                              fontSize: 14,
                              weight: FontWeight.bold,
                            ),
                          ),
                        )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
