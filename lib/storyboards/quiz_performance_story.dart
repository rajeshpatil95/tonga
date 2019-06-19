import 'package:flutter/material.dart';
import 'package:storyboard/storyboard.dart';
import 'package:tonga/screens/quiz_performance_screen.dart';

class QuizPerformanceStory extends FullScreenStory {
  @override
  List<Widget> get storyContent => [
        Scaffold(
          body: SafeArea(
            child: QuizPerformanceScreen(
              studentJoinedQuiz: [
                '-L_kAc7oWImWyfJPURh9',
                '-L_LWtBsjJdkTLRtXYf_',
                '-L_l4ca17ipy3QNu2_8H',
              ],
              score: [0.8, 0.4, 0.7],
            ),
          ),
        ),
      ];
}
