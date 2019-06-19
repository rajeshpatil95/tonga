import 'dart:convert';
import 'package:built_value/standard_json_plugin.dart';
import 'package:data/data.dart';
import 'package:data/models/class_session.dart';
import 'package:flutter/material.dart';
import 'package:tonga/entity/class.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tonga/entity/teacher.dart';
import 'package:tonga/entity/student.dart';
import 'package:tonga/repos/student_repo.dart';
import 'package:tonga/screens/edit_add_class_screen.dart';
import 'package:tonga/screens/progress_score_screen.dart';
import 'package:tonga/state/app_state_container.dart';
import 'package:tonga/state/nearby_container_state.dart';
import 'package:random_string/random_string.dart';

class StartClassScreen extends StatefulWidget {
  final Icon icon;
  final Class classData;

  StartClassScreen({Key key, this.icon, this.classData}) : super(key: key);

  @override
  StartClassScreenState createState() {
    return new StartClassScreenState();
  }
}

class StartClassScreenState extends State<StartClassScreen> {
  bool pressAttention = false;
  Teacher loggedInTeacher;
  Map<String, String> advertisingMap = new Map<String, String>();
  List<StudentEntity> allStudentsOfClass;
  bool isStartClassEnabled = false;

  @override
  void initState() {
    super.initState();
    advertisingMap['advertisingName'] = 'NULL';
  }

  void _showDialog(String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("$title"),
          content: new Text("Alert Dialog body"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget classDetails(context, icon, subject, standard) {
    return new Center(
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Expanded(
            flex: 2,
            child: new Column(
              children: <Widget>[
                new Expanded(
                  flex: 1,
                  child: Ink(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Theme.of(context).accentColor, width: 4.0),
                      shape: BoxShape.circle,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(1000.0),
                      onTap: () {},
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Icon(
                          Icons.priority_high,
                          size: 50.0,
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                    ),
                  ),
                ),
                new Expanded(
                  flex: 1,
                  child: Text(
                    '${subject}',
                    style: new TextStyle(
                        color: Theme.of(context).accentColor,
                        fontSize: 40.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                new Text(
                  "${standard} standard",
                  style: new TextStyle(
                      color: Theme.of(context).accentColor,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget listOfStudents(context) {
    Card makeGridCell(IconData icon, String name, String standard) {
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
                color: Theme.of(context).primaryColor,
              ),
            ),
            Center(
                child: new Text(
              name,
              style: new TextStyle(
                  color: Theme.of(context).accentColor,
                  fontSize: 15.0,
                  fontWeight: FontWeight.normal),
            )),
            Center(
                child: new Text(
              standard,
              style: new TextStyle(
                  color: Theme.of(context).accentColor,
                  fontSize: 15.0,
                  fontWeight: FontWeight.normal),
            )),
          ],
        ),
      );
    }

    return new StreamBuilder(
      stream: StudentRepo(Firestore()).fetchOnlyStudentsOfClass(
          loggedInTeacher.schoolId, widget.classData.documentId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
            ),
          );
        } else {
          allStudentsOfClass = snapshot.data;
          if (snapshot.data.length == 0) {
            isStartClassEnabled = false;
          } else {
            WidgetsBinding.instance.addPostFrameCallback((s) {
              if (!isStartClassEnabled)
                setState(() {
                  isStartClassEnabled = true;
                });
            });
          }

          return GridView.builder(
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
            itemCount: snapshot.data.length,
            padding: EdgeInsets.all(2.0),
            itemBuilder: (BuildContext context, int index) {
              return new GestureDetector(
                  onLongPress: () {},
                  child: Container(
                      padding: EdgeInsets.all(2.0),
                      child: makeGridCell(
                          Icons.work,
                          snapshot.data[index].studentName,
                          snapshot.data[index].standard)));
            },
          );
        }
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loggedInTeacher = AppStateContainer.of(context).state.loggedInTeacher;
    final connections = NearByStateContainer.of(context).connections;
  }

  void sendClassStundents(dynamic s) async {
    await NearByStateContainer.of(context).getConnections();
    var connections = NearByStateContainer.of(context).connections;
    var classSessionId = NearByStateContainer.of(context).classSessionId;

    if (connections != null &&
        NearByStateContainer.of(context).mode == Status.classSession) {
      final standardSerializers =
          (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
      ClassStudents classStudents = ClassStudents((c) {
        for (var index = 0; index < allStudentsOfClass.length; index++) {
          c
            ..classId = widget.classData.documentId
            ..sessionId = classSessionId
            ..students.add(
              Student((d) => d
                ..id = allStudentsOfClass[index].documentId
                ..name = allStudentsOfClass[index].studentName
                ..grade = allStudentsOfClass[index].standard
                ..photo = ' '),
            );
        }
      });

      final classStudentsJson = standardSerializers.serialize(classStudents);

      final classStudentsJsonString = jsonEncode(classStudentsJson);

      NearByStateContainer.of(context).sendMessageTo(
          s['onEndpointConnected']['endPointId'], classStudentsJsonString);
    }
  }

  void _onAdvertiseClick(advertisingMap) async {
    String advertiserId = randomNumeric(4);
    NearByStateContainer.of(context).updateClassSessionId(advertiserId);

    Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => ProgressScoreScreen(
              classData: widget.classData,
              loggedInTeacher: loggedInTeacher,
              listOfStudents: allStudentsOfClass,
            )));

    final standardSerializers =
        (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();

    ClassSession classSession = ClassSession((c) {
      c
        ..classId = widget.classData.documentId
        ..name = widget.classData.subject
        ..teacherName = loggedInTeacher.teacherName
        ..sessionId = advertiserId
        ..teacherPhoto = ' ';
    });

    final classSessionJson = standardSerializers.serialize(classSession);

    final classSessionJsonString = jsonEncode(classSessionJson);

    setState(() {
      NearByStateContainer.of(context).updateMode(Status.classSession);
      advertisingMap['advertisingName'] = classSessionJsonString;
    });

    NearByStateContainer.of(context).startAdvertising(advertisingMap);
    await NearByStateContainer.of(context).onEndPointNotification((f) {
      sendClassStundents(f);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text('Start Class'),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.edit),
            color: Colors.white,
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute<Null>(
                  builder: (BuildContext context) => EditAddNewClassScreen(
                        title: 'Edit',
                        classData: widget.classData,
                        inEditingMode: true,
                      )));
            },
          ),
        ],
      ),
      resizeToAvoidBottomPadding: false,
      body: new Center(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new Expanded(
              flex: 10,
              child: new Column(
                children: <Widget>[
                  new Expanded(
                    flex: 4,
                    child: classDetails(context, widget.icon,
                        widget.classData.subject, widget.classData.standard),
                  ),
                  new Divider(
                    height: 5.0,
                  ),
                  new Expanded(
                    flex: 8,
                    child: listOfStudents(context),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: RaisedButton(
        onPressed: !isStartClassEnabled
            ? null
            : () {
                if (pressAttention == false) {
                  _onAdvertiseClick(advertisingMap);
                } else {
                  NearByStateContainer.of(context).stopAdvertising();
                  _showDialog('Class Ended..!!');
                }
                setState(() => pressAttention = !pressAttention);
              },
        disabledColor: Colors.grey.withOpacity(0.6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: pressAttention ? new Text('End') : new Text('Start'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
