import 'package:flutter/material.dart';
import 'package:planty_connect/model/room_model.dart';
import 'package:planty_connect/utils/color_res.dart';
import 'package:planty_connect/utils/styles.dart';

class GroupCard extends StatelessWidget {
  final RoomModel groupModel;
  final bool isSelected;
  final Function(RoomModel) onTap;

  GroupCard(
    this.groupModel,
    this.onTap,
    this.isSelected,
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap.call(groupModel);
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 40,
                width: 40,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: groupModel.groupModel.groupImage == null
                      ? Icon(
                          Icons.group,
                          color: ColorRes.dimGray,
                        )
                      : Image.network(
                          groupModel.groupModel.groupImage,
                          height: 40,
                          width: 40,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    groupModel.groupModel.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle(
                      color: ColorRes.black,
                      fontSize: 16,
                      weight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              isSelected
                  ? Icon(
                      Icons.check_circle,
                      color: ColorRes.green,
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
