import 'package:flutter/material.dart';
import 'package:storyboard/storyboard.dart';
import 'package:tonga/storyboards/components/drop_down_story.dart';
import 'package:tonga/storyboards/progress_score_story.dart';
import 'package:tonga/storyboards/quiz_performance_story.dart';
import 'package:tonga/storyboards/screens/teacher_review_quiz_session.dart';

void main() {
  runApp(StoryboardApp(
      [DropDownStory(), ProgressScoreScreenStory(), QuizPerformanceStory(), TeacherReviewQuizSessionStory()]));
}
