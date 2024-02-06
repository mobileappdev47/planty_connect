class UserModel {
  String name;
  String email;
  String password;
  String fcmToken;
  String profilePicture;
  String uid;
  bool isAdmin;

  UserModel({
    this.name,
    this.email,
    this.fcmToken,
    this.profilePicture,
    this.uid,
    this.isAdmin
  });

  factory UserModel.fromMap(Map<String, dynamic> data) => UserModel(
    name: data['name'],
    email: data['email'],
    fcmToken: data['fcmToken'],
    profilePicture: data['profilePicture'],
    uid: data['uid'],
    isAdmin:data['isAdmin']

  );

  Map<String, dynamic> toMap() => {
    "name" : name,
    "email" : email,
    "fcmToken" : fcmToken,
    "profilePicture" : profilePicture,
    "uid" : uid,
    "isAdmin":isAdmin
  };
}
