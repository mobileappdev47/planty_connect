import 'package:planty_connect/model/user_model.dart';

class AppState {
  static final AppState _singleton = AppState._internal();

  factory AppState() {
    return _singleton;
  }

  AppState._internal();

  UserModel currentUser;
  String adminUid;

  String currentActiveRoom;
}

AppState appState = AppState();
