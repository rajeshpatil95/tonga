class Class {
  final String documentId;
  final String schoolId;
  final String standard;
  final String subject;
  final String teacherId;

  Class(
      {this.documentId,
      this.schoolId,
      this.standard,
      this.subject,
      this.teacherId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Class &&
          runtimeType == other.runtimeType &&
          documentId == other.documentId &&
          schoolId == other.schoolId &&
          standard == other.standard &&
          subject == other.subject &&
          teacherId == other.teacherId;

  @override
  int get hashCode =>
      documentId.hashCode ^
      schoolId.hashCode ^
      standard.hashCode ^
      subject.hashCode ^
      teacherId.hashCode;

  @override
  String toString() {
    return 'Classes Entity{documentId: $documentId, schoolId: $schoolId, standard: $standard, subject: $subject, teacherId: $teacherId}';
  }
}
