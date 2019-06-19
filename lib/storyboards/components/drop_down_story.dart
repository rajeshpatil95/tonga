import 'package:flutter/material.dart';
import 'package:storyboard/storyboard.dart';
import 'package:tonga/components/dropdown.dart';

class DropDownStory extends FullScreenStory {
  @override
  List<Widget> get storyContent => [
        Scaffold(
          body: SafeArea(
            child: Dropdown(
              menuItems: ['Kashmir', 'Shillong', 'Bihar', 'UP', 'MP'],
              hintText: 'Please Enter The Text',
              value: 'Kashmir',
              selectedItem: (){},
            ),
          ),
        ),
      ];
}
