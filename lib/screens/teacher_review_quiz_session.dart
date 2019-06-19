import 'package:flutter/material.dart';

class TeacherReviewQuizSession extends StatefulWidget {
  @override
  TeacherReviewQuizSessionState createState() {
    return TeacherReviewQuizSessionState();
  }
}

class TeacherReviewQuizSessionState extends State<TeacherReviewQuizSession> {
  @override
  void initState() {
    super.initState();
  }

  Widget questionsListWidget() {
    return Row(
      children: <Widget>[
        new Expanded(
          flex: 10,
          child: new Row(
            children: <Widget>[
              new Expanded(
                flex: 2,
                child: new Container(
                  height: 50.0,
                  color: Colors.black,
                  child: new Container(
                      margin: EdgeInsets.all(15.0),
                      child: new Text("Players",
                          style: new TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold))),
                ),
              ),
              new Expanded(
                flex: 8,
                child: new Container(
                    height: 50.0,
                    color: Colors.black,
                    child: new ListView.builder(
                        itemCount: 8,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return horizontalQuestionList(index);
                        })),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget studentsListWidget() {
    return new ListView.builder(
      itemCount: 20,
      itemBuilder: (BuildContext context, int index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              children: <Widget>[
                new Expanded(
                  flex: 10,
                  child: new Row(
                    children: <Widget>[
                      new Expanded(
                          flex: 2,
                          child: new Column(
                            children: <Widget>[
                              new Container(
                                height: 50.0,
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(''),
                                ),
                              ),
                              new Container(
                                child: new Text(
                                  "Rajesh Patil",
                                  style: new TextStyle(
                                      color: Colors.black,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 10.0),
                                child: new Row(
                                  children: <Widget>[
                                    new Icon(
                                      Icons.star,
                                      color: Colors.yellow,
                                    ),
                                    new Container(
                                      child: new Text("12",
                                          style: new TextStyle(
                                              color: Colors.black,
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.bold)),
                                    )
                                  ],
                                ),
                              )
                            ],
                          )),
                      new Divider(
                        height: 5.0,
                      ),
                      new Expanded(
                        flex: 8,
                        child: new Container(
                          height: 50.0,
                          child: new ListView.builder(
                              itemCount: 8,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return horizontalStudentList(index, true);
                              }),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
            new Divider(
              height: 5.0,
              color: Colors.black,
            )
          ],
        );
      },
    );
  }

  Widget horizontalQuestionList(int index) {
    return new Container(
      margin: EdgeInsets.all(5.0),
      height: 30.0,
      width: 30.0,
      child: new Center(
        child: new Text(
          "$index",
          style: new TextStyle(
              fontSize: 20.0, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget horizontalStudentList(int index, bool flag) {
    return new Container(
      margin: EdgeInsets.all(5.0),
      height: 30.0,
      width: 30.0,
      decoration: new BoxDecoration(
        color: Colors.green,
        border: new Border.all(color: Colors.green, width: 2.0),
        shape: BoxShape.rectangle,
        borderRadius: new BorderRadius.circular(10.0),
      ),
      child: new Center(
        child: new Icon(
          Icons.check,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'Overview',
          style: Theme.of(context).textTheme.headline,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 10,
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: questionsListWidget(),
                ),
                Expanded(
                  flex: 9,
                  child: studentsListWidget(),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
