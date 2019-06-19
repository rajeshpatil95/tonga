import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tonga/entity/teacher.dart';
import 'package:tonga/screens/edit_teacher_details.dart';

class TeacherDetailScreen extends StatelessWidget {
  final Teacher teacher;

  TeacherDetailScreen({
    this.teacher,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Teacher's Detail"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.edit),
              color: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return EditTeacherDetails(
                        update: true,
                        teacher: teacher,
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
        body: Stack(children: <Widget>[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/Background_potriat.png'),
                  fit: BoxFit.fill),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                children: <Widget>[
                  const SizedBox(
                    height: 60.0,
                  ),
                  CircleAvatar(
                    backgroundImage: NetworkImage(teacher.imageUrl),
                    maxRadius: 60.0,
                  ),
                  const SizedBox(
                    height: 24.0,
                  ),
                  Text(
                    teacher.teacherName,
                    style: Theme.of(context).textTheme.title,
                  ),
                  const SizedBox(
                    height: 24.0,
                  ),
                  Text(
                    teacher.teacherId,
                    style: Theme.of(context).textTheme.body1,
                  ),
                ],
              ),
            ],
          ),
        ]));
  }
}
