import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tonga/entity/teacher.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class TeacherRepo {
  final String path = 'teachers';
  final Firestore firestore;
  const TeacherRepo(this.firestore);

  Future<Teacher> getLoggedInTeacherEntity(String email) async {
    print('Getting the Logged in Teacher Entity........................');
    Teacher loggedInTeacher;
    firestore.settings(timestampsInSnapshotsEnabled: true);
    DocumentSnapshot documents = await _teacherQuery(email);
    loggedInTeacher = Teacher.fromJson(documents.data);
    return loggedInTeacher;
  }

  Future<DocumentSnapshot> _teacherQuery(String email) async {
    var teacherQuery =
        firestore.collection('teachers').where('teacher_id', isEqualTo: email);
    QuerySnapshot teacherQuerySnapshot = await teacherQuery.getDocuments();
    print('${teacherQuerySnapshot.documents.length}');
    DocumentSnapshot targetDocument;
    for (DocumentSnapshot documents in teacherQuerySnapshot.documents) {
      targetDocument = documents;
      documents.data.putIfAbsent('document_id', () => documents.documentID);
      print("Document ${documents.data} returned by teacherQuery");
    }
    return targetDocument;
  }

  Future<String> uploadTeacherImage(File image, String imageName) async {
    final StorageReference reference =
        FirebaseStorage.instance.ref().child('myImage.jpg');
    final StorageUploadTask imageFile = reference.putFile(image);
    var downUrl = await (await imageFile.onComplete).ref.getDownloadURL();
    print(":::::::;; downUrl $downUrl");
    return downUrl.toString();
  }

  Stream<List<Teacher>> fetchAllTeachersOfSchool(String schoolId) {
    return firestore
        .collection(path)
        .where('school_id', isEqualTo: schoolId)
        .snapshots()
        .map((snapshot) {
      return snapshot.documents.map((doc) {
        return Teacher(
          documentId: doc.documentID,
          imageUrl: doc['image_url'],
          isAdmin: doc['is_admin'],
          schoolId: doc['school_id'],
          teacherId: doc['teacher_id'],
          teacherName: doc['teacher_name'],
        );
      }).toList();
    });
  }

  addNewTeacherData(Teacher teacher) async {
    Firestore.instance.runTransaction((Transaction transaction) async {
      CollectionReference reference = Firestore.instance.collection(path);
      await reference.add({
        'isAdmin': teacher.isAdmin,
        'teacher_name': teacher.teacherName,
        'teacher_id': teacher.teacherId,
        'image_url': teacher.imageUrl,
        'school_id': teacher.schoolId,
      });
    });
  }

  Future<void> updateTeacherData(Teacher teacher) async {
    await firestore.collection(path).document(teacher.documentId).updateData({
      'teacher_name': teacher.teacherName,
      'teacher_id': teacher.teacherId,
      'image_url': teacher.imageUrl,
      'school_id': teacher.schoolId,
    }).catchError((e) {
      print(e);
    });
  }
}
