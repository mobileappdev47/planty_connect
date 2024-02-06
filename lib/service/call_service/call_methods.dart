import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:planty_connect/model/call_model.dart';
import 'package:planty_connect/utils/app_state.dart';
import 'package:planty_connect/utils/debug.dart';
import 'package:planty_connect/utils/strings.dart';

CallMethods callMethods = CallMethods();

class CallMethods {
  final CollectionReference callCollection =
  FirebaseFirestore.instance.collection(CALL_COLLECTION);

  Stream<DocumentSnapshot> callStream({String uid}) =>
      callCollection.doc(uid).snapshots();

  Future<bool> makeCall({Call call}) async{
    try{
      call.hasDialled = true;
      Map<String, dynamic> hasDialledMap = call.toMap();

      call.hasDialled = false;
      Map<String, dynamic> hasNotDialledMap = call.toMap();

      await callCollection.doc(call.callerId).set(hasDialledMap);

      for(int i=0; i<call.currentUser.length; i++){
        if(call.currentUser[i] != call.callerId){
          await callCollection.doc(call.currentUser[i]).set(hasNotDialledMap);
        }
      }
      return true;
    }catch(e){
      Debug.print("Error1 = $e");
      return false;
    }
  }

  Future<bool> endCall({Call call}) async {
    try {
      Call updateCall;

      await callCollection.doc(appState.currentUser.uid).get().then((documentSnap) async {
        updateCall = Call.fromMap(documentSnap.data());

        updateCall.currentUser.remove(appState.currentUser.uid);

        await callCollection.doc(appState.currentUser.uid).delete();

        if(updateCall.currentUser.length == 1){
          await callCollection.doc(updateCall.currentUser.first).delete();
        }else{
          updateCall.currentUser.forEach((userId) async {
            await callCollection.doc(userId).set(updateCall.toMap());
          });
        }
      });

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
/*  Stream<DocumentSnapshot> searchGroup({String text})=> FirebaseFirestore.instance.collection("groups").where('name',isEqualTo:"" ).snapshots();*/
}
