import 'package:flutter/material.dart';
import 'package:tonga/screens/edit_add_class_screen.dart';
import 'package:tonga/screens/class_screen.dart';
import 'package:tonga/screens/edit_student_details.dart';
import 'package:tonga/screens/edit_teacher_details.dart';
import 'package:tonga/screens/student_screen.dart';
import 'package:tonga/screens/teacher_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tonga/entity/teacher.dart';
import 'package:tonga/state/app_state_container.dart';
import 'package:tonga/components/drawer_app.dart';
import 'package:tonga/services/auth.dart';

class HomeScreen extends StatefulWidget {
  final BaseAuth auth;
  final int initialIndex;
  HomeScreen({Key key, this.initialIndex, this.auth});

  @override
  HomeScreenState createState() {
    return new HomeScreenState();
  }
}

class HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  FirebaseUser loggedInUser;
  Teacher loggedInTeacher;
  TabController _tabController;

  final formkey = new GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(
        vsync: this,
        initialIndex: widget.initialIndex == null ? 0 : widget.initialIndex,
        length: 3);
  }

  @override
  Widget build(BuildContext context) {
    loggedInUser = AppStateContainer.of(context).state.loggedInUser;
    loggedInTeacher = AppStateContainer.of(context).state.loggedInTeacher;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'Teacher App',
          style: Theme.of(context).textTheme.headline,
        ),
        actions: <Widget>[],
        centerTitle: true,
        bottom: new TabBar(
          unselectedLabelColor: Colors.grey,
          labelColor: Colors.white,
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: <Widget>[
            new Tab(text: "Class"),
            new Tab(text: "Teacher"),
            new Tab(text: "Student"),
          ],
        ),
      ),
      resizeToAvoidBottomPadding: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/Background_potriat.png'),
                  fit: BoxFit.fill),
            ),
          ),
          new TabBarView(
            controller: _tabController,
            children: <Widget>[
              new ClassScreen(
                title: 'Class Screen',
              ),
              new TeacherScreen(
                loggedInTeacher: loggedInTeacher,
              ),
              new StudentScreen(
                loggedInTeacher: loggedInTeacher,
              ),
            ],
          ),
        ],
      ),
      drawer: DrawerApp(
          loggedInTeacher: loggedInTeacher,
          loggedInUser: loggedInUser,
          baseAuth: widget.auth),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {
          if (_tabController.index == 0) {
            Navigator.of(context).push(MaterialPageRoute<Null>(
                builder: (BuildContext context) =>
                    EditAddNewClassScreen(title: 'Add', inEditingMode: false)));
          } else if (_tabController.index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditTeacherDetails(
                      update: false,
                      teacher: loggedInTeacher,
                    ),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditStudentDetails(
                      update: false,
                      loggedInTeacher: loggedInTeacher,
                    ),
              ),
            );
          }
        },
        tooltip: 'Increment',
        child: Icon(
          Icons.add,
          color: Colors.black,
        ),
      ),
    );
  }
}
