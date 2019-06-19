import 'package:flutter/material.dart';
import 'package:tonga/screens/root_screen.dart';
import 'package:tonga/state/app_state_container.dart';
import 'package:tonga/services/auth.dart';
import 'package:tonga/state/nearby_container_state.dart';

void main() async {
  runApp(AppStateContainer(child: NearByStateContainer(child: MyApp())));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      AppStateContainer.of(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFFE18025),
        accentColor: Colors.black,
        fontFamily: 'Montserrat',
        textTheme: TextTheme(
          headline: TextStyle(
              fontSize: 30.0, fontWeight: FontWeight.bold, color: Colors.white),
          title: TextStyle(
              fontSize: 20.0, fontStyle: FontStyle.normal, color: Colors.black),
          body1: TextStyle(
              fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      routes: <String, WidgetBuilder>{},
      home: RootPage(auth: new BaseAuth()),
    );
  }
}
