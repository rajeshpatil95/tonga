import 'package:flutter/material.dart';
import 'package:tonga/state/app_state.dart';
import 'package:tonga/entity/teacher.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppStateContainer extends StatefulWidget {
  final AppState state;
  final Widget child;

  AppStateContainer({this.state, this.child});

  static AppStateContainerState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_InheritedAppStateContainer)
            as _InheritedAppStateContainer)
        ?.data;
  }

  @override
  AppStateContainerState createState() => new AppStateContainerState();
}

class AppStateContainerState extends State<AppStateContainer> {
  AppState state;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  initialize() async {
    if (widget.state != null) {
      state = widget.state;
    } else {
      state = new AppState();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _log(String message) {
    print("TeacherApp:" + message);
  }

  setLoggedInUserAndTeacher(FirebaseUser user, Teacher loggedInTeacher) async {
    setState(() {
      state =
          new AppState(loggedInUser: user, loggedInTeacher: loggedInTeacher);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new _InheritedAppStateContainer(
      data: this,
      child: widget.child,
    );
  }
}

class _InheritedAppStateContainer extends InheritedWidget {
  final AppStateContainerState data;

  _InheritedAppStateContainer(
      {Key key, @required this.data, @required Widget child})
      : super(key: key, child: child);

  bool updateShouldNotify(_InheritedAppStateContainer old) => true;
}
