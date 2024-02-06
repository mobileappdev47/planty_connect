import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planty_connect/model/group_model.dart';
import 'package:planty_connect/utils/exception.dart';
import 'package:planty_connect/utils/firestore_collections.dart';

class GroupService {
  CollectionReference group =
      FirebaseFirestore.instance.collection(FireStoreCollections.groups);

  Future<DocumentReference> createGroup(GroupModel groupModel) async {
    try {
      return await group.add(groupModel.toMap());
    } catch (e) {
      print(e);
      handleException(e);
      throw e;
    }
  }

  Future<void> updateGroupDesc(
      String groupId, String title, String desc) async {
    try {
      await group.doc(groupId).update({
        "name": title,
        "description": desc,
      });
    } catch (e) {
      print(e);
      handleException(e);
      throw e;
    }
  }

  Future<void> deleteGroup(String groupId) async {
    try {
      await group.doc(groupId).delete();
    } catch (e) {
      print(e);
      handleException(e);
      throw e;
    }
  }

  Future<void> updateGroupMember(String groupId, List<dynamic> members) async {
    try {
      await group.doc(groupId).update({"members": members});
    } catch (e) {
      print(e);
      handleException(e);
      throw e;
    }
  }

  Future<void> updateGroup(String groupId, Map<String, dynamic> data) async {
    try {
      await group.doc(groupId).update(data);
    } catch (e) {
      print(e);
      handleException(e);
      throw e;
    }
  }

  Stream<QuerySnapshot> streamGroup() {
    try {
      return group.snapshots();
    } catch (e) {
      print(e);
      handleException(e);
      throw e;
    }
  }

  Stream<DocumentSnapshot> getGroupStream(String id) {
    try {
      return group.doc(id).snapshots();
    } catch (e) {
      print(e);
      handleException(e);
      throw e;
    }
  }

  Future<DocumentSnapshot> getGroup(String id) async {
    try {
      return await group.doc(id).get();
    } catch (e) {
      print(e);
      handleException(e);
      throw e;
    }
  }

  Future<GroupModel> getGroupModel(String id) async {
    try {
      DocumentSnapshot doc = await group.doc(id).get();
      return GroupModel.fromMap(doc.data(), doc.id);
    } catch (e) {
      print(e);
      handleException(e);
      throw e;
    }
  }
}
