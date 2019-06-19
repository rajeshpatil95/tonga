import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tonga/components/multi_selector.dart';
import 'package:tonga/entity/class.dart';
import 'package:tonga/entity/teacher.dart';
import 'package:tonga/repos/class_repo.dart';
import 'package:tonga/repos/student_repo.dart';
import 'package:tonga/screens/home_screen.dart';
import 'package:tonga/state/app_state_container.dart';

class EditAddNewClassScreen extends StatefulWidget {
  final String title;
  final Class classData;
  final inEditingMode;

  EditAddNewClassScreen(
      {Key key, this.title, this.classData, this.inEditingMode});

  @override
  EditAddNewClassScreenState createState() {
    return new EditAddNewClassScreenState();
  }
}

class EditAddNewClassScreenState extends State<EditAddNewClassScreen> {
  final TextEditingController subjectController = new TextEditingController();
  final TextEditingController standardController = new TextEditingController();
  String subject, standard, classId;
  bool onTapFlag = false;
  List<Element> indexList = new List();
  List<String> listOfSelectedStudents = [];
  List<String> listOfAllStudents = [];
  List<String> listOfAllStudentsToBeDeleted = [];
  List<String> listOfAllStudentsToBeUpdated = [];
  int selectedCount = 0;
  Teacher loggedInTeacher;

  @override
  void initState() {
    super.initState();

    if (widget.inEditingMode) {
      subject = subjectController.text = widget.classData.subject;
      standard = standardController.text = widget.classData.standard;
    }

    subjectController.addListener(() {
      subject = subjectController.text;
      print(subject);
    });
    standardController.addListener(() {
      standard = standardController.text;
      print(standard);
    });

    StudentRepo(Firestore()).getStudentsCount().then((length) {
      for (var i = 0; i < length; i++) {
        listOfSelectedStudents.add('deafult');
      }
    });
  }

  @override
  void didChangeDependencies() {
    loggedInTeacher = AppStateContainer.of(context).state.loggedInTeacher;
    var doc = StudentRepo(Firestore())
        .fetchAllStudentsOfSchool(loggedInTeacher.schoolId);
    doc.forEach((f) {
      f.forEach((t) {
        listOfAllStudents.add(t.documentId);
      });
    });
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    subjectController.dispose();
    standardController.dispose();
    super.dispose();
  }

  void editAddNewClass() {
    print(
        "Query result: ${subject}, ${standard}, ${loggedInTeacher.schoolId}, ${loggedInTeacher.documentId}, ${listOfAllStudents}, ${listOfSelectedStudents}");

    if (widget.inEditingMode) {
      ClassRepo(Firestore()).updateClassData(
          widget.classData.documentId,
          loggedInTeacher.schoolId,
          standard,
          subject,
          loggedInTeacher.documentId);

      for (var studentId in listOfAllStudents) {
        if (listOfSelectedStudents.contains(studentId)) {
          listOfAllStudentsToBeUpdated.add(studentId);
        } else {
          listOfAllStudentsToBeDeleted.add(studentId);
        }
      }

      if (listOfAllStudentsToBeDeleted != null) {
        for (var studentId in listOfAllStudentsToBeDeleted) {
          StudentRepo(Firestore())
              .updateStudentsToClass(studentId, widget.classData.documentId);
        }
      } else {
        print("listOfAllStudentsToBeDeleted list Empty..!!");
      }

      if (listOfAllStudentsToBeUpdated != null) {
        for (var studentId in listOfAllStudentsToBeUpdated) {
          StudentRepo(Firestore())
              .addStudentsToClass(studentId, widget.classData.documentId);
        }
      } else {
        print("listOfAllStudentsToBeUpdated list Empty..!!");
      }
      _showDialog('Class Edited..!!');
    } else {
      if (standard != null && subject != null) {
        ClassRepo(Firestore())
            .addNewClassData(loggedInTeacher.schoolId, standard, subject,
                loggedInTeacher.documentId)
            .then((d) {
          classId = d.documentID;
          print("DocumentId: ${d.documentID}");

          for (var studentId in listOfSelectedStudents) {
            if (studentId == 'deafult') {
              print('Dont Add..!!');
            } else {
              StudentRepo(Firestore()).addStudentsToClass(studentId, classId);
            }
          }
        });
        _showDialog('$subject Class Added..!!');
      } else {
        _showDialog('Please fill the details..!!');
        print("Subject Standard Fields Empty..!!");
      }
    }
  }

  void onTap() {
    setState(() {
      if (indexList.isEmpty) {
        onTapFlag = false;
      } else {
        onTapFlag = true;
      }
    });
  }

  onElementSelected(int index, AsyncSnapshot snapshot) {
    setState(() {
      if (indexList[index].isSelected) {
        listOfSelectedStudents[index] = 'default';
        selectedCount--;
      } else {
        selectedCount++;
        listOfSelectedStudents[index] =
            snapshot.data[index].documentId.toString();
      }

      indexList[index].isSelected = !indexList[index].isSelected;
    });
  }

  void _showDialog(String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(title),
          content: new Text("Alert Dialog body"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute<Null>(
                    builder: (BuildContext context) => HomeScreen()));
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildInputs(context) {
    return new Column(
      children: <Widget>[
        new Expanded(
          flex: 4,
          child: new Column(
            children: <Widget>[
              new Expanded(
                flex: 2,
                child: new TextFormField(
                    key: Key('Subject'),
                    decoration:
                        new InputDecoration(labelText: "Enter Your Subject"),
                    keyboardType: TextInputType.text,
                    maxLines: 1,
                    autocorrect: false,
                    enabled: true,
                    controller: subjectController,
                    onSaved: (value) {
                      setState(() {
                        subject = subjectController.text;
                      });
                    }),
              ),
              new Expanded(
                flex: 2,
                child: new TextFormField(
                    key: Key('Standard'),
                    decoration:
                        new InputDecoration(labelText: "Enter Standard"),
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    maxLines: 1,
                    autocorrect: false,
                    enabled: true,
                    controller: standardController,
                    onSaved: (value) {
                      setState(() {
                        standard = standardController.text;
                      });
                    }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildListOfStudents(context) {
    return new StreamBuilder(
      stream: StudentRepo(Firestore())
          .fetchAllStudentsOfSchool(loggedInTeacher.schoolId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
            ),
          );
        } else {
          for (var i = 0; i < snapshot.data.length; i++) {
            indexList.add(Element(isSelected: false));
          }
          return GridView.builder(
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
            itemCount: snapshot.data.length,
            padding: EdgeInsets.all(2.0),
            itemBuilder: (BuildContext context, int index) {
              return new MultiSelector(
                isSelected: indexList[index].isSelected,
                index: index,
                onTapEnabled: onTapFlag,
                callback: () {
                  onElementSelected(index, snapshot);
                  if (indexList.contains(index)) {
                    indexList.remove(index);
                  } else {
                    indexList.add(Element());
                  }
                  onTap();
                },
                icon: Icons.work,
                title: snapshot.data[index].studentName.toString(),
                text: snapshot.data[index].standard.toString(),
              );
            },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text('${widget.title} Class '),
        actions: <Widget>[],
      ),
      resizeToAvoidBottomPadding: false,
      body: new Center(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new Expanded(
              flex: 12,
              child: new Column(
                children: <Widget>[
                  new Expanded(
                    flex: 4,
                    child: buildInputs(context),
                  ),
                  new Divider(
                    height: 5.0,
                  ),
                  new Expanded(
                    flex: 8,
                    child: buildListOfStudents(context),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: RaisedButton(
        onPressed: () {
          editAddNewClass();
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: widget.inEditingMode ? new Text('Edit') : new Text('Add'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class Element {
  Element({this.isSelected});
  bool isSelected;
}
