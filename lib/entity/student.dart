class StudentEntity {
  final String documentId;
  final List<dynamic> classes;
  final String gender;
  final String imageUrl;
  final String schoolId;
  final String standard;
  final String studentName;
  final String userProfile;

  StudentEntity(
      {this.documentId,
      this.classes,
      this.gender,
      this.imageUrl,
      this.schoolId,
      this.standard,
      this.studentName,
      this.userProfile});
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentEntity &&
          runtimeType == other.runtimeType &&
          documentId == other.documentId &&
          classes == other.classes &&
          gender == other.gender &&
          imageUrl == other.imageUrl &&
          schoolId == other.schoolId &&
          standard == other.standard &&
          userProfile == other.userProfile &&
          studentName == other.studentName;

  @override
  int get hashCode =>
      documentId.hashCode ^
      classes.hashCode ^
      gender.hashCode ^
      imageUrl.hashCode ^
      schoolId.hashCode ^
      standard.hashCode ^
      studentName.hashCode ^
      userProfile.hashCode;
  @override
  String toString() {
    return 'StudentEntity Entity{documentId: $documentId, classes: $classes, gender: $gender, imageUrl: $imageUrl, schoolId: $schoolId, standard: $standard, studentName: $studentName, userProfile: $userProfile}';
  }
}
