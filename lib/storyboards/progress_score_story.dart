import 'package:flutter/material.dart';
import 'package:storyboard/storyboard.dart';
import 'package:tonga/screens/progress_score_screen.dart';

class ProgressScoreScreenStory extends FullScreenStory {
  @override
  List<Widget> get storyContent => [
        Scaffold(
          body: SafeArea(
            child: ProgressScoreScreen(
              listOfStudents: ['-L_C93nKQvqNRIt3vrvb','-L_gLmXkBj3qasO02Z_3','-L_kAc7oWImWyfJPURh9'],
            ),
          ),
        ),
      ];
}
