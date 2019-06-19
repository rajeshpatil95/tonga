import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tonga/entity/class.dart';

class ClassRepo {
  static const String path = 'classes';

  final Firestore firestore;

  const ClassRepo(this.firestore);

  Stream<List<Class>> fetchAllClassesOfTeacher(
      String teacherId, String schoolId) {
    return firestore
        .collection(path)
        .where('school_id', isEqualTo: schoolId)
        .where('teacher_id', isEqualTo: teacherId)
        .snapshots()
        .map((snapshot) {
      return snapshot.documents.map((doc) {
        return Class(
          documentId: doc.documentID,
          schoolId: doc['school_id'],
          standard: doc['standard'],
          subject: doc['subject'],
          teacherId: doc['teacher_id'],
        );
      }).toList();
    });
  }

  Future<DocumentReference> addNewClassData(
      String schoolId, String standard, String subject, String teacherId) {
    return Firestore.instance.collection(path).add({
      'school_id': schoolId,
      'standard': standard,
      'subject': subject,
      'teacher_id': teacherId
    });
  }

  Future<void> updateClassData(String classDocId, String schoolId,
      String standard, String subject, String teacherId) async {
    DocumentReference documentRef =
        firestore.collection(path).document(classDocId);
    documentRef.updateData({
      'school_id': schoolId,
      'standard': standard,
      'subject': subject,
      'teacher_id': teacherId
    });
  }

  Future<List<String>> getAllSubjectsOfSchool() async {
    List<String> listOfAllSubjects = [];
    QuerySnapshot _doc =
        await Firestore.instance.collection(path).getDocuments();
    _doc.documents.forEach((f) {
      listOfAllSubjects.add(f.data['subject']);
    });
    return listOfAllSubjects;
  }
}
