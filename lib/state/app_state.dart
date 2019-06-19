import 'package:tonga/entity/teacher.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppState {
  FirebaseUser loggedInUser;
  Teacher loggedInTeacher;

  AppState({this.loggedInUser, this.loggedInTeacher});

  @override
  int get hashCode => loggedInUser.hashCode ^ loggedInTeacher.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppState &&
          runtimeType == other.runtimeType &&
          loggedInUser == other.loggedInUser &&
          loggedInTeacher == other.loggedInTeacher;

  @override
  String toString() {
    return 'AppState{loggedInUser: $loggedInUser}, loggedInTeacher: ${loggedInTeacher}}';
  }
}
