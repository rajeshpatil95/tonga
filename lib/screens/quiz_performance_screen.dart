import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data/models/performance.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:tonga/entity/student.dart';
import 'package:tonga/entity/teacher.dart';
import 'package:tonga/repos/student_repo.dart';
import 'package:tonga/state/nearby_container_state.dart';

class QuizPerformanceScreen extends StatefulWidget {
  final Teacher loggedInTeacher;
  final String classId;
  final List<double> score;
  final List<dynamic> studentJoinedQuiz;
  QuizPerformanceScreen({
    this.loggedInTeacher,
    this.classId,
    this.studentJoinedQuiz,
    this.score,
  });
  @override
  _QuizPerformanceScreenState createState() => _QuizPerformanceScreenState();
}

class _QuizPerformanceScreenState extends State<QuizPerformanceScreen> {
  List<StudentEntity> _contestant = [];

  int totalQuestion;
  List<Performance> quizPerformanceList = [];
  String studentId;
  int score;

  @override
  void initState() {
    super.initState();
    studentJoined();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    totalQuestion = NearByStateContainer.of(context).numberOfQuestions;
    quizPerformanceList = NearByStateContainer.of(context).quizPerformances;
    quizPerformanceList.map((f) {
      studentId = f.studentId;
      score = f.score;
      // correct = f.correct;
      // gameName = f.gameId;
    }).toList();
  }

  // @override
  // void didUpdateWidget(QuizPerformanceScreen oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   if (oldWidget.studentJoinedQuiz != widget.studentJoinedQuiz) {}
  // }

  studentJoined() {
    Stream<List<StudentEntity>> s = StudentRepo(Firestore())
        .fetchOnlyStudentsOfClass(
            widget.loggedInTeacher.schoolId, widget.classId);
    for (int i = 0; i < widget.studentJoinedQuiz.length; i++) {
      s.map((v) {
        v.forEach((f) {
          if (f.documentId == widget.studentJoinedQuiz[i]) {
            _contestant.add(f);
          }
        });
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Quiz"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.adjust),
              color: Colors.white,
              onPressed: () {
                print("call inside Button");
                NearByStateContainer.of(context).startQuiz(context);
              }),
        ],
      ),
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/quiz_background image.jpg'),
                  fit: BoxFit.fill),
            ),
          ),
          StreamBuilder(
            stream: StudentRepo(Firestore()).fetchOnlyStudentsOfClass(
                widget.loggedInTeacher.schoolId, widget.classId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor),
                  ),
                );
              } else {
                return ListView.builder(
                  itemCount: widget.studentJoinedQuiz.length,
                  itemBuilder: (_, index) {
                    return _contestant.isNotEmpty
                        ? ListTile(
                            leading: Column(
                              children: <Widget>[
                                Stack(children: <Widget>[
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        _contestant[index].imageUrl),
                                    maxRadius: 30.0,
                                  ),
                                  new Positioned(
                                    child: Text(
                                      "1",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ]),
                                Text(
                                  _contestant[index].studentName,
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                            title: Padding(
                              padding: EdgeInsets.all(15.0),
                              child: LinearPercentIndicator(
                                width: MediaQuery.of(context).size.width - 150,
                                animation: true,
                                lineHeight: 20.0,
                                animationDuration: 2000,
                                percent:
                                    _contestant[index].documentId == studentId
                                        ? score * 0.1
                                        : 0.0,
                                animateFromLastPercent: true,
                                linearStrokeCap: LinearStrokeCap.roundAll,
                                progressColor: Colors.green,
                              ),
                            ),
                          )
                        : Container();
                  },
                );
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text("End Quiz"),
        onPressed: () => NearByStateContainer.of(context).stopQuiz(),
      ),
    );
  }
}
