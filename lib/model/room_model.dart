import 'package:planty_connect/model/group_model.dart';
import 'package:planty_connect/model/user_model.dart';

class RoomModel {
  String id;
  String lastMessage;
  List<String> membersId;
  DateTime lastMessageTime;
  bool isGroup;
  GroupModel groupModel;
  UserModel userModel;

  RoomModel({
    this.id,
    this.lastMessage,
    this.lastMessageTime,
    this.isGroup,
    this.membersId,
  });

  factory RoomModel.fromMap(Map<String, dynamic> data) => RoomModel(
        id: data['id'],
        lastMessageTime:data['lastMessageTime']==null?data['createdAt'].toDate(): data['lastMessageTime'].toDate(),
        lastMessage:data['lastMessage']==null?"": data['lastMessage'],
        isGroup:data['isGroup']==null?true: data['isGroup'],
        membersId: data['membersId'].cast<String>(),
      );
}
