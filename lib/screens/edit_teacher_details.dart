import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tonga/entity/teacher.dart';
import 'package:tonga/repos/teacher_repo.dart';
import 'package:tonga/screens/home_screen.dart';

class EditTeacherDetails extends StatefulWidget {
  final bool update;
  final Teacher teacher;

  EditTeacherDetails({
    this.update = true,
    this.teacher,
  });
  @override
  EditTeacherDetailsState createState() {
    return EditTeacherDetailsState();
  }
}

class EditTeacherDetailsState extends State<EditTeacherDetails> {
  final _formKey = GlobalKey<FormState>();
  TeacherRepo _teacherRepo = TeacherRepo(Firestore());

  String _teacherId;
  String _teacherName;
  File _image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text("Add Teacher Details"),
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
                                        NetworkImage(widget.teacher.imageUrl),
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
                              widget.update ? widget.teacher.teacherName : null,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Teacher Name',
                          ),
                          onSaved: (input) {
                            _teacherName = input;
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter teacher name';
                            }
                          },
                        ),
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
                              widget.update ? widget.teacher.teacherId : null,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Teacher Id',
                          ),
                          onSaved: (input) {
                            _teacherId = input;
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter teacher Id';
                            }
                          },
                        ),
                      ),
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
                                ? updateTeacherDetail()
                                : addTeacherDetail();

                            Navigator.of(context).pop();
                            Navigator.of(context).push(MaterialPageRoute<Null>(
                                builder: (BuildContext context) => HomeScreen(
                                      initialIndex: 1,
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

  addTeacherDetail() {
    _teacherRepo.uploadTeacherImage(_image, _teacherName + '.jpg').then(
      (imageUrl) {
        _teacherRepo.addNewTeacherData(
          Teacher(
            imageUrl: imageUrl,
            teacherName: _teacherName,
            teacherId: _teacherId,
            schoolId: widget.teacher.schoolId,
            isAdmin: false,
          ),
        );
      },
    );
  }

  updateTeacherDetail() {
    _teacherRepo.uploadTeacherImage(_image, _teacherName + '.jpg').then(
      (imageUrl) {
        _teacherRepo.updateTeacherData(
          Teacher(
            documentId: widget.teacher.documentId,
            imageUrl: imageUrl,
            isAdmin: widget.teacher.isAdmin,
            schoolId: widget.teacher.schoolId,
            teacherName: _teacherName,
            teacherId: _teacherId,
          ),
        );
      },
    );
    _teacherRepo.updateTeacherData(
      Teacher(
        documentId: widget.teacher.documentId,
        imageUrl: widget.teacher.imageUrl,
        isAdmin: widget.teacher.isAdmin,
        schoolId: widget.teacher.schoolId,
        teacherName: _teacherName,
        teacherId: _teacherId,
      ),
    );
  }
}
