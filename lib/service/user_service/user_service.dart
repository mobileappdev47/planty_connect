import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planty_connect/model/user_model.dart';
import 'package:planty_connect/service/auth_service/auth_service.dart';
import 'package:planty_connect/utils/app.dart';
import 'package:planty_connect/utils/app_state.dart';
import 'package:planty_connect/utils/exception.dart';
import 'package:planty_connect/utils/firestore_collections.dart';
import 'package:rxdart/rxdart.dart';

class UserService {
  CollectionReference users =
      FirebaseFirestore.instance.collection(FireStoreCollections.users);

  Future<void> createUser(UserModel userModel) async {
    try {
      await users.doc(userModel.uid).set(userModel.toMap());
    } catch (e) {
      handleException(e);
      throw e;
    }
  }

  Stream<QuerySnapshot> getUsersStream() {
    try {
      return users
          .where("uid", isNotEqualTo: firebaseAuth.currentUser.uid)
          .snapshots();
    } catch (e) {
      handleException(e);
      throw e;
    }
  }

  CombineLatestStream<QuerySnapshot, List<QuerySnapshot>> roomStream() {
    try {
      Stream<QuerySnapshot> s1 = users
          .where("uid", isNotEqualTo: firebaseAuth.currentUser.uid)
          .snapshots();
      Stream<QuerySnapshot> s2 = groupService.streamGroup();
      return CombineLatestStream.list<QuerySnapshot>([s1, s2]);
    } catch (e) {
      handleException(e);
      throw e;
    }
  }

  Future<DocumentSnapshot> getUser(String uid) async {
    try {
      return await users.doc(uid).get();
    } catch (e) {
      handleException(e);
      throw e;
    }
  }

  Stream<DocumentSnapshot> getUserStream(String uid) {
    try {
      return users.doc(uid).snapshots();
    } catch (e) {
      handleException(e);
      throw e;
    }
  }

  Stream<DocumentSnapshot> getRoomUserStream(List<String> membersId) {
    try {
      String id = membersId
          .firstWhere((element) => element != appState.currentUser.uid);
      return users.doc(id).snapshots();
    } catch (e) {
      handleException(e);
      throw e;
    }
  }

  Future<QuerySnapshot> getUsers() async {
    try {
      return await users
          .where("uid", isNotEqualTo: firebaseAuth.currentUser.uid)
          .get();
    } catch (e) {
      handleException(e);
      throw e;
    }
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await users.doc(uid).update(data);
    } catch (e) {
      handleException(e);
      throw e;
    }
  }

  Future<UserModel> getUserModel(String uid) async {
    try {
      DocumentSnapshot doc = await users.doc(uid).get();
      return UserModel.fromMap(doc.data());
    } catch (e) {
      handleException(e);
      throw e;
    }
  }
}
