import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tonga/entity/student.dart';
import 'package:tonga/entity/teacher.dart';
import 'package:tonga/repos/student_repo.dart';
import 'package:tonga/screens/student_detail_screen.dart';

class StudentScreen extends StatelessWidget {
  final Teacher loggedInTeacher;
  StudentScreen({
    Key key,
    this.loggedInTeacher,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool update = false;

    return Container(
      child: new StreamBuilder(
        stream: StudentRepo(Firestore())
            .fetchAllStudentsOfSchool(loggedInTeacher.schoolId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor),
              ),
            );
          } 
          else {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (_, index) {
             
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                        NetworkImage(snapshot.data[index].imageUrl),
                    maxRadius: 30.0,
                  ),
                  title: Text(
                    snapshot.data[index].studentName,
                    style: Theme.of(context).textTheme.title,
                  ),
                  subtitle: Text(
                    "${snapshot.data[index].gender}",
                    style: Theme.of(context).textTheme.body1,
                  ),
                  trailing: Text("Standard :${snapshot.data[index].standard}"),
                  onTap: () {
                    update = true;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return StudentDetailScreen(
                            student: StudentEntity(
                                classes: snapshot.data[index].classes,
                                documentId: snapshot.data[index].documentId,
                                gender: snapshot.data[index].gender,
                                imageUrl: snapshot.data[index].imageUrl,
                                schoolId: loggedInTeacher.schoolId,
                                standard: snapshot.data[index].standard,
                                studentName: snapshot.data[index].studentName),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
