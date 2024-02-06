import 'package:firebase_auth/firebase_auth.dart';
import 'package:planty_connect/model/user_model.dart';
import 'package:planty_connect/utils/app.dart';
import 'package:planty_connect/utils/app_state.dart';
import 'package:planty_connect/utils/exception.dart';

FirebaseAuth firebaseAuth = FirebaseAuth.instance;

class AuthService {
  Future<void> signUp(UserModel userModel) async {
    try {
      UserCredential userCredential =
          await firebaseAuth.createUserWithEmailAndPassword(
        email: userModel.email,
        password: userModel.password,
      );
      userModel.uid = userCredential.user.uid;
      await firebaseAuth.currentUser.updateDisplayName(userModel.name);
      await firebaseAuth.currentUser.updatePhotoURL(userModel.profilePicture);
      await userService.createUser(userModel);
    } catch (e) {
      handleException(e);
      throw e;
    }
  }

  Future<void> signIn(UserModel userModel) async {
    try {
      UserCredential userCredential =
          await firebaseAuth.signInWithEmailAndPassword(
        email: userModel.email,
        password: userModel.password,
      );
      await userService.getUser(userCredential.user.uid).then((value){
        appState.currentUser = UserModel.fromMap(value.data());
      });
    } catch (e) {
      handleException(e);
      throw e;
    }
  }

  Future<void> logout() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      handleException(e);
      throw e;
    }
  }

  bool isUserLoggedIn() {
    return firebaseAuth.currentUser != null;
  }

  Future<void> forgotPassword(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      handleException(e);
      throw e;
    }
  }
}
