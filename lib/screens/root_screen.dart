import 'package:flutter/material.dart';

import 'package:tonga/services/auth.dart';
import 'package:tonga/screens/login_screen.dart';
import 'package:tonga/state/app_state_container.dart';
import 'package:tonga/screens/home_screen.dart';
import 'package:tonga/repos/teacher_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RootPage extends StatefulWidget {
  RootPage({this.auth});

  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => new _RootPageState();
}

enum AuthStatus { NOT_DETERMINED, NOT_LOGGED_IN, LOGGED_IN }

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  FirebaseUser loggedInUser;
  AppStateContainerState app;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    app = AppStateContainer.of(context);
  }

  @override
  void initState() {
    print(
        'Root Page Init State............................................................');
    super.initState();
    widget.auth.getUser().then((user) {
      setState(() {
        if (user != null) {
          loggedInUser = user;
        }
        authStatus =
            user?.uid == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
      });
    });
  }

  void _onLoggedIn() {
    print(
        'In _onLoggedIn() Function.....................................................');
    widget.auth.getUser().then((user) {
      setState(() {
        loggedInUser = user;
      });
    });
    setState(() {
      print(
          'Changing AuthStatus to LOGGED_IN............................................');
      authStatus = AuthStatus.LOGGED_IN;
    });
    print('Logged in User is: ${loggedInUser.email.toString()}');
  }

  void _onSignedOut() {
    setState(() {
      authStatus = AuthStatus.NOT_LOGGED_IN;
      loggedInUser = null;
    });
  }

  Widget _buildWaitingScreen() {
    print(
        'Building Waiting Screen.....................................................');
    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/Background_potriat.png'),
                fit: BoxFit.fill),
          ),
        ),
        Center(child: CircularProgressIndicator()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    print(
        'Building.............................................................................');
    switch (authStatus) {
      case AuthStatus.NOT_DETERMINED:
        print(
            'AuthState: NOT DETERMINED........................................................');
        return _buildWaitingScreen();
        break;
      case AuthStatus.NOT_LOGGED_IN:
        print(
            'AuthState: NOT LOGGED IN........................................................');
        return new LoginScreen(auth: widget.auth, onSignedIn: _onLoggedIn);
        break;
      case AuthStatus.LOGGED_IN:
        print(
            'AuthState LOGGED IN..............................................................');
        if (loggedInUser != null) {
          TeacherRepo(Firestore())
              .getLoggedInTeacherEntity(loggedInUser.email)
              .then((loggedInTeacher) {
            app.setLoggedInUserAndTeacher(loggedInUser, loggedInTeacher);
            print(
                'Navigating to HomeScreen.....................................................');
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => HomeScreen(
                      auth: BaseAuth(),
                    )));
          });
        } else
          return _buildWaitingScreen();
        break;
      default:
        print(
            'Default Case.....................................................................');
        return _buildWaitingScreen();
    }
    return _buildWaitingScreen();
  }
}
