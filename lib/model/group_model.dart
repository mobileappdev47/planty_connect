class GroupModel{
  String groupId;
  String createdBy;
  String name;
  String description;
  String groupImage;
  List<GroupMember> members;
  DateTime createdAt;

  GroupModel({
    this.groupId,
    this.name,
    this.description,
    this.groupImage,
    this.members,
    this.createdAt,
    this.createdBy,
  });

  factory GroupModel.fromMap(Map<String, dynamic> data,String id) {
    try{
      return GroupModel(
        name: data['name'],
        createdBy: data['createdBy'],
        groupId: id,
        description: data['description'],
        groupImage: data['groupImage'],
        members: List<GroupMember>.from(data['members'].map((x) => GroupMember.fromMap(x))),
        createdAt: data['createdAt'].toDate(),
      );
    }catch(e){
      return GroupModel(
        name: "",
        createdBy: "",
        groupId: "",
        description: "",
        groupImage: null,
        members: [],
        createdAt: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toMap() => {
    "name" : name,
    "createdBy" : createdBy,
    "description" : description,
    "groupImage" : groupImage,
    "members" : List<dynamic>.from(members.map((x) => x.toMap())),
    "createdAt" : createdAt,
  };
}

class GroupMember{
  String memberId;
  bool isAdmin;

  GroupMember({this.memberId, this.isAdmin});

  factory GroupMember.fromMap(Map<String, dynamic> data) => GroupMember(
    memberId: data['memberId'],
    isAdmin: data['isAdmin'],
  );

  Map<String, dynamic> toMap() => {
    "memberId" : memberId,
    "isAdmin" : isAdmin,
  };
}