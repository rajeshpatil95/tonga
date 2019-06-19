import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tonga/entity/teacher.dart';
import 'package:tonga/repos/teacher_repo.dart';
import 'package:tonga/screens/teacher_detail_screen.dart';

class TeacherScreen extends StatelessWidget {
  final Teacher loggedInTeacher;
  TeacherScreen({Key key, this.loggedInTeacher}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool update = false;

    return Container(
      child: new StreamBuilder(
        stream: TeacherRepo(Firestore())
            .fetchAllTeachersOfSchool(loggedInTeacher.schoolId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
              ),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (_, index) {
                if (snapshot.data[index].teacherName !=
                    loggedInTeacher.teacherName) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          NetworkImage(snapshot.data[index].imageUrl),
                      maxRadius: 30.0,
                    ),
                    title: Text(
                      snapshot.data[index].teacherName,
                      style: Theme.of(context).textTheme.title,
                    ),
                    subtitle: Text(
                      "ID :${snapshot.data[index].teacherId}",
                      style: Theme.of(context).textTheme.body1,
                    ),
                    onTap: () {
                      update = true;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return TeacherDetailScreen(
                              teacher: Teacher(
                                documentId: snapshot.data[index].documentId,
                                imageUrl: snapshot.data[index].imageUrl,
                                teacherName: snapshot.data[index].teacherName,
                                teacherId: snapshot.data[index].teacherId,
                                schoolId: loggedInTeacher.schoolId,
                                isAdmin: snapshot.data[index].isAdmin,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}
