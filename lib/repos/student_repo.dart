import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tonga/entity/student.dart';

class StudentRepo {
  static const String path = 'students';

  final Firestore firestore;

  const StudentRepo(this.firestore);

  Stream<List<StudentEntity>> fetchAllStudentsOfSchool(String schoolId) {
    return firestore
        .collection(path)
        .where('school_id', isEqualTo: schoolId)
        .snapshots()
        .map((snapshot) {
      return snapshot.documents.map((doc) {
        return StudentEntity(
          documentId: doc.documentID,
          classes: doc['classes'],
          gender: doc['gender'],
          imageUrl: doc['image_url'],
          standard: doc['standard'],
          studentName: doc['student_name'],
          schoolId: doc['school_id'],
        );
      }).toList();
    });
  }

  Stream<List<StudentEntity>> fetchOnlyStudentsOfClass(
      String schoolId, String classId) {
    return firestore
        .collection(path)
        .where('school_id', isEqualTo: schoolId)
        .where('classes', arrayContains: classId)
        .snapshots()
        .map((snapshot) {
      return snapshot.documents.map((doc) {
        return StudentEntity(
          documentId: doc.documentID,
          classes: doc['classes'],
          gender: doc['gender'],
          imageUrl: doc['image_url'],
          schoolId: doc['school_id'],
          standard: doc['standard'],
          studentName: doc['student_name'],
        );
      }).toList();
    });
  }

  Future<String> uploadStudentImage(File image, String imageName) async {
    final StorageReference reference =
        FirebaseStorage.instance.ref().child(imageName);
    final StorageUploadTask imageFile = reference.putFile(image);
    var downUrl = await (await imageFile.onComplete).ref.getDownloadURL();
    return downUrl.toString();
  }

  Future<void> addNewStudentData(StudentEntity student) async {
    Firestore.instance.runTransaction((Transaction transaction) async {
      CollectionReference reference = Firestore.instance.collection(path);
      await reference.add({
        'classes': [],
        'student_name': student.studentName,
        'standard': student.standard,
        'gender': student.gender,
        'image_url': student.imageUrl,
        'school_id': student.schoolId,
        'user_profile': student.userProfile
      });
    });
  }

  Future<void> updateStudentData(StudentEntity student) async {
    await Firestore.instance
        .collection(path)
        .document(student.documentId)
        .updateData({
      'classes': [],
      'student_name': student.studentName,
      'standard': student.standard,
      'gender': student.gender,
      'image_url': student.imageUrl,
      'school_id': student.schoolId,
    }).catchError((e) {
      print(e);
    });
  }

  Future<int> getStudentsCount() async {
    QuerySnapshot _doc =
        await Firestore.instance.collection(path).getDocuments();
    List<DocumentSnapshot> _docCount = _doc.documents;
    return _docCount.length;
  }

  Future<void> updateStudentsToClass(String studentId, String classId) async {
    List<String> tempList = [];
    Firestore.instance
        .collection(path)
        .document(studentId)
        .snapshots()
        .first
        .then((s) {
      tempList = s['classes'].cast<String>().toList();

      if (tempList.contains(classId)) {
        tempList.remove(classId);
        DocumentReference documentRef =
            firestore.collection(path).document(studentId);
        documentRef.updateData({"classes": tempList});
      } else {
        print("Dont Do Anything..!!");
      }
    });

    DocumentReference documentRef =
        firestore.collection(path).document(studentId);
    documentRef.updateData({"classes": tempList});
  }

  Future<void> addStudentsToClass(String studentId, String classId) async {
    List<String> list = [];
    Firestore.instance
        .collection(path)
        .document(studentId)
        .snapshots()
        .first
        .then((s) {
      list = s['classes'].cast<String>().toList();

      if (list.contains(classId)) {
        print("Dont Add..!!");
      } else {
        addToStudents(studentId, classId, s['classes']);
      }
    });
  }

  Future<void> addToStudents(
      String studentId, String classId, List<dynamic> classes) async {
    List<String> list = classes.cast<String>().toList();
    list.add(classId);
    DocumentReference documentRef =
        firestore.collection(path).document(studentId);
    documentRef.updateData({"classes": list});
  }

  //Future<void> getStudentUserProfile() {...}

  //Future<void> updateStudentUserProfile() {...}
}
