import 'package:flutter/material.dart';

class MultiSelector extends StatelessWidget {
  final int index;
  final bool onTapEnabled;
  final VoidCallback callback;
  final bool isSelected;
  final IconData icon;
  final title;
  final text;

  const MultiSelector(
      {Key key,
      this.index,
      this.onTapEnabled,
      this.callback,
      this.isSelected,
      this.icon,
      this.title,
      this.text})
      : super(key: key);

  Card makeGridCell(IconData icon, String title, String text) {
    return new Card(
      color: isSelected ? Colors.grey.withOpacity(0.4) : Colors.white,
      elevation: 1.0,
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        verticalDirection: VerticalDirection.down,
        children: <Widget>[
          new Center(
            child: new Icon(
              icon,
              color: isSelected ? Colors.blue.withOpacity(0.4) : Colors.blue,
            ),
          ),
          Center(
              child: new Text(
            title,
            style: new TextStyle(
                color: Colors.black,
                fontSize: 15.0,
                fontWeight: FontWeight.normal),
          )),
          Center(
              child: new Text(text,
                  style: new TextStyle(
                      color: Colors.black,
                      fontSize: 15.0,
                      fontWeight: FontWeight.normal))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: () {
        callback();
      },
      child: Container(
          padding: EdgeInsets.all(2.0), child: makeGridCell(icon, title, text)),
    );
  }
}
