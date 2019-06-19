import 'package:flutter/material.dart';
import 'package:tonga/screens/root_screen.dart';
import 'package:tonga/state/app_state_container.dart';
import 'camera_app.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tonga/repos/teacher_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tonga/services/auth.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tonga/entity/teacher.dart';

class DrawerApp extends StatefulWidget {
  final Teacher loggedInTeacher;
  final FirebaseUser loggedInUser;
  final BaseAuth baseAuth;

  DrawerApp({
    this.loggedInTeacher,
    this.loggedInUser,
    this.baseAuth,
  });
  @override
  DrawerAppState createState() {
    return new DrawerAppState();
  }
}

class DrawerAppState extends State<DrawerApp> {
  final formkey = new GlobalKey<FormState>();
  final formkeyName = new GlobalKey<FormState>();
  TeacherRepo _teacherRepo = TeacherRepo(Firestore());
  TextEditingController textcontroller = new TextEditingController();
  String imagePath;
  Teacher loggedInData;
  String textAdd;
  String password;
  String newEmail;
  String errorMessage;
  bool textToggle = false;

  bool isUpdated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loggedInData = AppStateContainer.of(context).state.loggedInTeacher;
  }

  @override
  void initState() {
    super.initState();
    errorMessage = "";
    loadImageFromLocal();
    textAdd = widget.loggedInTeacher.teacherName;
  }

  loadImageFromLocal() async {
    String k;
    final getPref = await SharedPreferences.getInstance();
    if (getPref != null) {
      k = getPref.getString('myImage');
      setState(() {
        print('Setting Path from Local');
        imagePath = k;
      });
    }
  }

  void setImage(File image) async {
    print('myImage in setImage $image');
    setState(() {
      print('Setting Image Path');
      imagePath = image.path;
    });
    _uploadImageInNewtork(image);
  }

  _uploadImageInNewtork(File image) async {
    _teacherRepo.uploadTeacherImage(image, imagePath).then((newURL) {
      Firestore.instance
          .collection('teachers')
          .document(widget.loggedInTeacher.documentId)
          .updateData({'image_url': newURL});
    });
  }

  Widget titleText(BuildContext context) {
    return Container(
      child: Form(
        key: formkeyName,
        child: Row(children: <Widget>[
          _editNameTextField(),
          IconButton(
            icon: Icon(
              Icons.check_circle,
              size: 40,
            ),
            onPressed: () {
              submitName();
            },
          ),
        ]),
      ),
    );
  }

  Widget _editNameTextField() {
    return Container(
      width: MediaQuery.of(context).size.width -
          MediaQuery.of(context).size.width * 0.4,
      child: TextFormField(
        textAlign: TextAlign.center,
        initialValue: widget.loggedInTeacher.teacherName,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter name';
          }
        },
        onSaved: (value) {
          textAdd = value.trim();
        },
      ),
    );
  }

  Widget _fromAssetImage(BuildContext context) {
    print('from asset');
    return InkWell(
      child: Container(
        child: CircleAvatar(
          maxRadius: 70,
          backgroundImage: FileImage(File(imagePath)),
        ),
      ),
    );
  }

  ImageProvider _buildBackgroundImage(
    String imageText,
  ) {
    print('from network $imageText');
    return NetworkImage(imageText);
  }

  Widget _submitButton() {
    return FractionallySizedBox(
      widthFactor: 0.35,
      child: RaisedButton(
        color: Colors.green[500],
        onPressed: () {
          _validateAndSubmit();
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Text('Save'),
      ),
    );
  }

  Widget _teacherPassword(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: TextFormField(
        obscureText: true,
        decoration: InputDecoration(
          hintText: 'Enter atleast 6 Characters',
        ),
        onSaved: (value) {
          password = value.trim();
        },
        validator: (value) {
          if (value.isEmpty || value.length < 6) {
            return 'invalid Password';
          }
        },
      ),
    );
  }

  Widget _teacherEmail(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: TextFormField(
        decoration: InputDecoration(hintText: 'Update the Teacher Id '),
        onSaved: (value) {
          newEmail = value.trim();
        },
        validator: (value) {
          if (value.isEmpty) {
            return 'Email cannot be empty';
          }
        },
      ),
    );
  }

  Widget showBody() {
    return Form(
      key: formkey,
      child: ListBody(
        children: <Widget>[
          _teacherEmail(context),
          _teacherPassword(context),
          Padding(
            padding: EdgeInsets.all(20),
          ),
          _submitButton(),
          _showErrorMessage()
        ],
      ),
    );
  }

  void _validateAndSubmit() async {
    if (formkey.currentState.validate()) {
      formkey.currentState.save();

      await BaseAuth().changePassword(widget.loggedInUser, password);
      _teacherRepo
          .updateTeacherData(loggedInData = Teacher(
        documentId: loggedInData.documentId,
        imageUrl: loggedInData.imageUrl,
        isAdmin: loggedInData.isAdmin,
        schoolId: loggedInData.schoolId,
        teacherName: loggedInData.teacherName,
        teacherId: newEmail,
      ))
          .then((_) {
        setState(() {
          errorMessage = "Data Updated";
          isUpdated = true;
        });
      });
    } else {
      setState(() {
        isUpdated = false;
      });
    }
  }

  Widget _logout() {
    return IconButton(
      icon: Icon(Icons.power_settings_new),
      onPressed: () => widget.baseAuth.signOut().then((_) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => RootPage(auth: new BaseAuth())));
          }),
    );
  }

  void setName() {
    setState(() {
      if (textToggle == false) {
        textToggle = true;
      } else {
        textToggle = false;
      }
    });
  }

  Widget _toggleName(BuildContext context) {
    return Container(
      child: textAdd == null
          ? Text(
              widget.loggedInTeacher.teacherName,
              style:
                  TextStyle(fontSize: 20, color: Theme.of(context).accentColor),
            )
          : Text(
              textAdd,
              style:
                  TextStyle(fontSize: 20, color: Theme.of(context).accentColor),
            ),
    );
  }

  void submitName() async {
    if (formkeyName.currentState.validate()) {
      formkeyName.currentState.save();
    }
    _teacherRepo
        .updateTeacherData(loggedInData = Teacher(
      documentId: loggedInData.documentId,
      imageUrl: loggedInData.imageUrl,
      isAdmin: loggedInData.isAdmin,
      schoolId: loggedInData.schoolId,
      teacherName: textAdd,
      teacherId: loggedInData.teacherId,
    ))
        .then((_) {
      setName();
    });
    AppStateContainer.of(context)
        .setLoggedInUserAndTeacher(widget.loggedInUser, loggedInData);
  }

  Widget _showErrorMessage() {
    if (errorMessage.length > 0 || errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 15),
        child: Center(
          child: Text(
            errorMessage,
            style: TextStyle(
              fontSize: 16.0,
              color: Theme.of(context).accentColor,
              height: 1.0,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      );
    } else {
      return Container(height: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Drawer(
            child: ListView(
      children: <Widget>[
        Column(
          children: <Widget>[
            Align(
              alignment: FractionalOffset.topRight,
              child: _logout(),
            ),
            DrawerHeader(
                child: InkWell(
              child: imagePath == null
                  ? Container(
                      child: CircleAvatar(
                        maxRadius: 70,
                        backgroundImage: _buildBackgroundImage(
                            widget.loggedInTeacher.imageUrl),
                      ),
                    )
                  : _fromAssetImage(context),
              onTap: () {
                CameraApp().openImagePicker(context, setImage);
              },
            )),
            InkWell(
              child: Container(
                  child: Center(
                child: textToggle == false
                    ? _toggleName(context)
                    : titleText(context),
              )),
              onTap: () {
                setName();
              },
            ),
            Divider(
              color: Colors.deepOrange,
            ),
            showBody()
          ],
        ),
      ],
    )));
  }
}
