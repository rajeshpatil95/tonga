import 'package:flutter/material.dart';
import 'package:storyboard/storyboard.dart';
import 'package:tonga/screens/teacher_review_quiz_session.dart';


class TeacherReviewQuizSessionStory extends FullScreenStory {
  @override
  List<Widget> get storyContent => [
        Scaffold(
          body: SafeArea(
            child: TeacherReviewQuizSession(),
          ),
        ),
      ];
}
