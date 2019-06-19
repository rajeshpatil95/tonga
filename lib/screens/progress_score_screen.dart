import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data/models/performance.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:tonga/entity/class.dart';
import 'package:tonga/entity/student.dart';
import 'package:tonga/entity/teacher.dart';
import 'package:tonga/repos/student_repo.dart';
import 'package:tonga/screens/quiz_performance_screen.dart';
import 'package:tonga/state/nearby_container_state.dart';

class ProgressScoreScreen extends StatefulWidget {
  final Class classData;
  final Teacher loggedInTeacher;
  final List<dynamic> listOfStudents;

  ProgressScoreScreen({
    this.classData,
    this.loggedInTeacher,
    this.listOfStudents,
  });

  @override
  ProgressScoreScreenState createState() {
    return new ProgressScoreScreenState();
  }
}

class ProgressScoreScreenState extends State<ProgressScoreScreen> {
  List<StudentEntity> _contestant = [];
  List<dynamic> _documentId = [];
  bool correct;
  List<Performance> performanceList = [];
  String gameName;
  List<dynamic> online = [];
  String studentId;
  @override
  void initState() {
    super.initState();
    studentJoined();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    online = NearByStateContainer.of(context).listOfConnectedStudents;
    performanceList = NearByStateContainer.of(context).performanceList;
    performanceList.map((f) {
      studentId = f.studentId;
      correct = f.correct;
      gameName = f.gameId;
    }).toList();
  }

  studentJoined() {
    Stream<List<StudentEntity>> s = StudentRepo(Firestore())
        .fetchOnlyStudentsOfClass(
            widget.loggedInTeacher.schoolId, widget.classData.documentId);

    for (int i = 0; i < widget.listOfStudents.length; i++) {
      s.map((v) {
        v.forEach((f) {
          _contestant.add(f);
          _documentId.add(f.documentId);
        });
      }).toList();
    }
  }

  Widget _body(BuildContext context) {
    return Container(
      child: new StreamBuilder(
        stream: StudentRepo(Firestore()).fetchOnlyStudentsOfClass(
            widget.loggedInTeacher.schoolId, widget.classData.documentId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor),
              ),
            );
          } else {
            return ListView.builder(
                itemCount: widget.listOfStudents.length,
                itemBuilder: (_, index) {
                  return _contestant.isNotEmpty
                      ? ListTile(
                          leading: Column(
                            children: <Widget>[
                              Stack(children: <Widget>[
                                Container(
                                  width: 70.0,
                                  height: 70.0,
                                  decoration: new BoxDecoration(
                                    image: new DecorationImage(
                                      image: new NetworkImage(
                                          _contestant[index].imageUrl),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: new BorderRadius.all(
                                        new Radius.circular(40.0)),
                                    border: new Border.all(
                                      color: online.contains(_documentId[index])
                                          ? Colors.green
                                          : Colors.red,
                                      width: 4.0,
                                    ),
                                  ),
                                )
                              ]),
                              Text(
                                _contestant[index].studentName,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .body1
                                        .color),
                              ),
                              Icon(
                                Icons.star,
                                color: Colors.yellow,
                              ),
                            ],
                          ),
                          title: studentId == (_documentId[index])
                              ? Text(
                                  gameName,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .body1
                                          .color),
                                )
                              : Text(''),
                          subtitle: LinearPercentIndicator(
                              width: MediaQuery.of(context).size.width - 140,
                              animation: true,
                              lineHeight: 10.0,
                              animationDuration: 2000,
                              animateFromLastPercent: true,
                              percent: ((studentId == (_documentId[index])) &&
                                      (correct == true))
                                  ? 0.5
                                  : 0.0,
                              linearStrokeCap: LinearStrokeCap.roundAll,
                              backgroundColor: Colors.white54,
                              progressColor: Colors.white),
                          contentPadding: EdgeInsets.all(20),
                        )
                      : Container();
                });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/Background_potriat.png'),
              fit: BoxFit.fill),
        ),
      ),
      Padding(
        padding: EdgeInsets.all(20),
      ),
      Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Progress Bar'),
          actions: <Widget>[
            new IconButton(
                icon: new Icon(Icons.alarm),
                color: Colors.white,
                onPressed: () {
                  NearByStateContainer.of(context).startQuizSession(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return QuizPerformanceScreen(
                          loggedInTeacher: widget.loggedInTeacher,
                          classId: widget.classData.documentId,
                          studentJoinedQuiz: NearByStateContainer.of(context)
                              .studentsJoinedQuiz,
                        );
                      },
                    ),
                  );
                }),
          ],
        ),
        body: _body(context),
      )
    ]);
  }
}
