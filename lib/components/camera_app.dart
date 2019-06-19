import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class CameraApp {
  File _imageFile;
  void _getImage(BuildContext context, ImageSource source, Function f) {
    ImagePicker.pickImage(source: source, maxHeight: 128, maxWidth: 128)
        .then((File image) async {
      _imageFile = image;
      if (_imageFile != null) {
        final pref = await SharedPreferences.getInstance();
        pref.setString('myImage', image.path);
        f(_imageFile);
      }
    });
  }

  openImagePicker(BuildContext context, Function func) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.all(new Radius.circular(22.0)),
            ),
            content: Container(
              height: MediaQuery.of(context).size.height * 0.170,
              child: Center(
                child: Row(
                  children: <Widget>[
                    FlatButton(
                      textColor: Theme.of(context).primaryColor,
                      child: Image.asset(
                        'assets/Camera.png',
                        height: MediaQuery.of(context).size.height * 0.1,
                        width: MediaQuery.of(context).size.width * 0.20,
                      ),
                      onPressed: () {
                        _getImage(context, ImageSource.camera, func);
                        Navigator.of(context).pop();
                      },
                    ),
                    FlatButton(
                      child: Image.asset(
                        'assets/Gallery.png',
                        height: MediaQuery.of(context).size.height * 0.1,
                        width: MediaQuery.of(context).size.width * 0.20,
                      ),
                      onPressed: () {
                        _getImage(context, ImageSource.gallery, func);
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}
