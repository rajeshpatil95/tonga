import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tonga/components/dropdown.dart';
import 'package:tonga/entity/student.dart';
import 'package:tonga/entity/teacher.dart';
import 'package:tonga/repos/student_repo.dart';
import 'package:tonga/screens/home_screen.dart';

class EditStudentDetails extends StatefulWidget {
  final bool update;
  final StudentEntity student;
  final Teacher loggedInTeacher;

  EditStudentDetails({
    this.update = true,
    this.student,
    this.loggedInTeacher,
  });
  @override
  EditStudentDetailsState createState() {
    return EditStudentDetailsState();
  }
}

class EditStudentDetailsState extends State<EditStudentDetails> {
  final _formKey = GlobalKey<FormState>();
  StudentRepo _studentRepo = StudentRepo(Firestore());
  String _studentName;
  String _standard;
  String _gender;
  File _image;
  List<String> _standardList = ['1', '2', '3', '4', '5', '6'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text("Add Student's Detail"),
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/Background_potriat.png'),
                  fit: BoxFit.fill),
            ),
          ),
          Form(
            key: _formKey,
            child: Center(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                width: MediaQuery.of(context).size.height * 0.4,
                child: ListView(
                  physics: NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    Center(
                      child: widget.update
                          ? _image == null
                              ? Stack(children: <Widget>[
                                  CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(widget.student.imageUrl),
                                    maxRadius: 50.0,
                                  ),
                                  new Positioned(
                                    top: -10.0,
                                    left: 65.0,
                                    child: new IconButton(
                                      iconSize: 30.0,
                                      color: Colors.white,
                                      icon: new Icon(Icons.edit),
                                      onPressed: () {
                                        openCamera();
                                      },
                                    ),
                                  ),
                                ])
                              : CircleAvatar(
                                  backgroundImage: ExactAssetImage(_image.path),
                                  maxRadius: 50.0,
                                )
                          : _image == null
                              ? CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: IconButton(
                                    color: const Color(0xFFE18025),
                                    icon: Icon(Icons.add_a_photo),
                                    iconSize: 50.0,
                                    onPressed: () {
                                      openCamera();
                                    },
                                  ),
                                  maxRadius: 50.0,
                                )
                              : CircleAvatar(
                                  backgroundImage: ExactAssetImage(_image.path),
                                  maxRadius: 50.0,
                                ),
                    ),
                    const SizedBox(
                      height: 24.0,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.black54,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextFormField(
                          style: TextStyle(color: Colors.white),
                          initialValue:
                              widget.update ? widget.student.studentName : null,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Student Name',
                          ),
                          onSaved: (input) {
                            _studentName = input;
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter student name';
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 24.0,
                    ),
                    Dropdown(
                      menuItems: _standardList,
                      hintText: 'select standard',
                      value: widget.update ? widget.student.standard : null,
                      selectedItem: (String value) {
                        _standard = value;
                      },
                    ),
                    const SizedBox(
                      height: 24.0,
                    ),
                    Dropdown(
                      menuItems: <String>['male', 'female'],
                      hintText: 'select gender',
                      value: widget.update ? widget.student.gender : null,
                      selectedItem: (String value) {
                        _gender = value;
                      },
                    ),
                    const SizedBox(
                      height: 24.0,
                    ),
                    Center(
                      child: RaisedButton(
                        color: const Color(0xFFE18025),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        child: Text(
                          'Submit',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();
                            widget.update
                                ? updateStudentDetails()
                                : addStudentDetails();

                            Navigator.of(context).pop();
                            Navigator.of(context).push(MaterialPageRoute<Null>(
                                builder: (BuildContext context) => HomeScreen(
                                      initialIndex: 2,
                                    )));
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  openCamera() async {
    _image = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 128.0, maxWidth: 128.0);
    userImage(_image);
  }

  userImage(File _image) async {
    setState(() {
      this._image = _image;
    });
  }

  addStudentDetails() {
    _studentRepo.uploadStudentImage(_image, _studentName + '.jpg').then(
      (imageUrl) {
        _studentRepo.addNewStudentData(
          StudentEntity(
            imageUrl: imageUrl,
            studentName: _studentName,
            standard: _standard,
            gender: _gender,
            schoolId: widget.loggedInTeacher.schoolId,
            userProfile: null,
          ),
        );
      },
    );
  }

  updateStudentDetails() {
    _standard ??= widget.student.standard;
    _gender ??= widget.student.gender;
    _studentRepo.uploadStudentImage(_image, _studentName + '.jpg').then(
      (imageUrl) {
        _studentRepo
            .updateStudentData(
          StudentEntity(
            documentId: widget.student.documentId,
            imageUrl: imageUrl,
            studentName: _studentName,
            standard: _standard,
            gender: _gender,
            schoolId: widget.student.schoolId,
          ),
        )
            .catchError((e) {
          print(e);
        });
      },
    );
    _studentRepo.updateStudentData(
      StudentEntity(
        documentId: widget.student.documentId,
        imageUrl: widget.student.imageUrl,
        studentName: _studentName,
        standard: _standard,
        gender: _gender,
        schoolId: widget.student.schoolId,
      ),
    );
  }
}
