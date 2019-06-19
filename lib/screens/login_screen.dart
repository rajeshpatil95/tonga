import 'package:flutter/material.dart';

import 'package:tonga/services/auth.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({this.auth, this.onSignedIn});

  final BaseAuth auth;
  final VoidCallback onSignedIn;

  @override
  State<StatefulWidget> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _isLoading;
  String _errorMessage;
  String _email;
  String _password;

  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/Background_potriat.png'),
                fit: BoxFit.fill),
          ),
        ),
        _showBody(context),
        _showCircularProgress()
      ],
    ));
  }

  Widget _showBody(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: (MediaQuery.of(context).size.height * 0.35),
          left: (MediaQuery.of(context).size.width * 0.05),
          right: (MediaQuery.of(context).size.width * 0.05)
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.only(right: 0),
          children: <Widget>[
            _userNameField(),
            _passwordField(),
            _submitButton(),
            _showErrorMessage()
          ],
        ),
      ),
    );
  }

  Widget _showCircularProgress() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Container(height: 0.0, width: 0.0);
  }

  Widget _showErrorMessage() {
    if (_errorMessage.length > 0 || _errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 15),
        child: Text(
          _errorMessage,
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.white,
            height: 1.0,
            fontWeight: FontWeight.w300,
          ),
        ),
      );
    } else {
      return Container(height: 0.0);
    }
  }

  Widget _userNameField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5), color: Colors.white30),
        child: TextFormField(
          validator: (value) {
            if (value.isEmpty) {
              return 'Name cannot be empty';
            }
          },
          onSaved: (value) {
            _email = value.trim();
          },
          decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your Email here',
              border: InputBorder.none,
              errorStyle: TextStyle(
                color: Colors.white,
                fontSize: 14
              ),
              icon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.email,
                  color: Colors.black,
                ),
              )),
        ),
      ),
    );
  }

  Widget _passwordField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5), color: Colors.white30),
        child: TextFormField(
          decoration: InputDecoration(
              labelText: 'Password',
              border: InputBorder.none,
              hintText: 'Enter your Password here',
              errorStyle: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              icon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.lock,
                  color: Colors.black,
                ),
              )),
          obscureText: true,
          maxLines: 1,
          onSaved: (value) {
            _password = value.trim();
          },
          validator: (value) {
            if (value.isEmpty) {
              return 'Password cannot be empty';
            }
          },
        ),
      ),
    );
  }

  Widget _submitButton() {
    return FractionallySizedBox(
      widthFactor: 0.35,
      child: RaisedButton(
        onPressed: () {
          _validateAndSubmit();
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Text('Submit'),
      ),
    );
  }

  void _validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      //Authenticate the user
      try {
        await widget.auth.signIn(_email, _password).then((user) {
          print(
              'Calling CallBack Function onSignedIn()...............................................................');
          widget.onSignedIn();
        });
      } catch (e) {
        print('Error: $e');
        setState(() {
          _isLoading = false;
          _errorMessage = e.message.toString();
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
