class Teacher {
  final String documentId;
  final String imageUrl;
  final bool isAdmin;
  final String schoolId;
  final String teacherId;
  final String teacherName;

  Teacher(
      {this.documentId,
      this.imageUrl,
      this.isAdmin,
      this.schoolId,
      this.teacherId,
      this.teacherName});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Teacher &&
          runtimeType == other.runtimeType &&
          documentId == other.documentId &&
          imageUrl == other.imageUrl &&
          isAdmin == other.isAdmin &&
          schoolId == other.schoolId &&
          teacherId == other.teacherId &&
          teacherName == other.teacherName;
  @override
  int get hashCode =>
      teacherName.hashCode ^
      teacherId.hashCode ^
      schoolId.hashCode ^
      isAdmin.hashCode ^
      imageUrl.hashCode;
  @override
  String toString() {
    return 'Teacher{documentId: $documentId, imageUrl: $imageUrl}, isAdmin: $isAdmin, schoolId: $schoolId, teacherId: $teacherId, teacherName: $teacherName';
  }

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return new Teacher(
        documentId: json['document_id'],
        teacherName: json['teacher_name'] as String,
        teacherId: json['teacher_id'] as String,
        schoolId: json['school_id'] as String,
        isAdmin: json['is_admin'] as bool,
        imageUrl: json['image_url'] as String);
  }
}
