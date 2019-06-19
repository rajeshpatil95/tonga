import 'package:cloud_firestore/cloud_firestore.dart';

class SchoolRepo {
  static const String path = 'schools';

  final Firestore firestore;

  const SchoolRepo(this.firestore);
}
