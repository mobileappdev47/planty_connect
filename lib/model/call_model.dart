class Call {
  String callerId;
  String callerName;
  String callerPic;
  String receiverId;
  String receiverName;
  String receiverPic;
  String channelId;
  bool hasDialled;
  List<dynamic> currentUser;

  Call({
    this.callerId,
    this.callerName,
    this.callerPic,
    this.receiverId,
    this.receiverName,
    this.receiverPic,
    this.channelId,
    this.hasDialled,
    this.currentUser
  });

  // to map
  Map<String, dynamic> toMap() {
    Map<String, dynamic> callMap = Map();
    callMap["caller_id"] = callerId;
    callMap["caller_name"] = callerName;
    callMap["caller_pic"] = callerPic;
    callMap["receiver_id"] = receiverId;
    callMap["receiver_name"] = receiverName;
    callMap["receiver_pic"] = receiverPic;
    callMap["channel_id"] = channelId;
    callMap["has_dialled"] = hasDialled;
    callMap["current_user"] = currentUser;
    return callMap;
  }

  Call.fromMap(Map callMap) {
    this.callerId = callMap["caller_id"];
    this.callerName = callMap["caller_name"];
    this.callerPic = callMap["caller_pic"];
    this.receiverId = callMap["receiver_id"];
    this.receiverName = callMap["receiver_name"];
    this.receiverPic = callMap["receiver_pic"];
    this.channelId = callMap["channel_id"];
    this.hasDialled = callMap["has_dialled"];
    this.currentUser = callMap["current_user"];
  }
}
