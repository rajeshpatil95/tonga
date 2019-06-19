import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

class BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseUser user;

  Future<FirebaseUser> signIn(String email, String password) async {
    print('In SignIn method');
    user = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    return user;
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Future<FirebaseUser> getUser() async {
    return await _firebaseAuth.currentUser();
  }

  Future changePassword(FirebaseUser currentUser, String newPassword) async {
    print('Updating Password............................................');
    print('User in Update Password function:  ${currentUser.toString()}');
    currentUser.updatePassword(newPassword);
  }
}
