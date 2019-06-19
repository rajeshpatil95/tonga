import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tonga/entity/teacher.dart';
import 'package:tonga/repos/class_repo.dart';
import 'package:tonga/screens/start_class_screen.dart';
import 'package:tonga/state/app_state_container.dart';

class ClassScreen extends StatelessWidget {
  final String title;
  ClassScreen({Key key, this.title}) : super(key: key);

  Card makeGridCell(String standard, String subject, IconData icon) {
    return new Card(
      elevation: 1.0,
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        verticalDirection: VerticalDirection.down,
        children: <Widget>[
          new Center(
            child: new Icon(
              icon,
              color: Colors.blue,
            ),
          ),
          Center(
              child: new Text(
            subject,
            style: TextStyle(color: Colors.black),
          )),
          Center(
            child: new Text(
              standard,
              style: TextStyle(color: Colors.black),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Teacher loggedInTeacher =
        AppStateContainer.of(context).state.loggedInTeacher;
    return Container(
      child: new StreamBuilder(
        stream: ClassRepo(Firestore()).fetchAllClassesOfTeacher(
            loggedInTeacher.documentId, loggedInTeacher.schoolId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor),
              ),
            );
          } else {
            return GridView.builder(
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              itemCount: snapshot.data.length,
              padding: EdgeInsets.all(2.0),
              itemBuilder: (BuildContext context, int index) {
                return new GestureDetector(
                    onTap: () {
                      print(snapshot.data[index].subject);
                      Navigator.of(context).push(MaterialPageRoute<Null>(
                          builder: (BuildContext context) => StartClassScreen(
                                icon: Icon(Icons.home),
                                classData: snapshot.data[index],
                              )));
                    },
                    child: Container(
                        padding: EdgeInsets.all(2.0),
                        child: makeGridCell(snapshot.data[index].standard,
                            snapshot.data[index].subject, Icons.work)));
              },
            );
          }
        },
      ),
    );
  }
}
