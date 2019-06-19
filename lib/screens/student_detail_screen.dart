import 'package:flutter/material.dart';
import 'package:tonga/entity/student.dart';
import 'package:tonga/screens/edit_student_details.dart';

class StudentDetailScreen extends StatelessWidget {
  final StudentEntity student;

  StudentDetailScreen({
    this.student,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Students's Detail"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.edit),
              color: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return EditStudentDetails(
                        update: true,
                        student: student,
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
                fit: BoxFit.fill,
              ),
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
                    backgroundImage: NetworkImage(student.imageUrl),
                    maxRadius: 50.0,
                  ),
                  const SizedBox(
                    height: 24.0,
                  ),
                  Text(
                    student.studentName,
                    style: Theme.of(context).textTheme.title,
                  ),
                  const SizedBox(
                    height: 24.0,
                  ),
                  Text(
                    "Standard :${student.standard}",
                    style: Theme.of(context).textTheme.body1,
                  ),
                ],
              ),
            ],
          ),
        ]));
  }
}
