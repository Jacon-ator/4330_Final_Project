import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {

  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
}