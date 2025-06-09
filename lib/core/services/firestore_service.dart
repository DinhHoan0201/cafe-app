import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Future<DocumentSnapshot> getDocumentFromSubCollection({
    required String topLevelCollection,
    required String parentDocId,
    required String subCollection,
    required String docIdInSubCollection,
  }) {
    return _db
        .collection(topLevelCollection)
        .doc(parentDocId)
        .collection(subCollection)
        .doc(docIdInSubCollection)
        .get();
  }

  // Future<QuerySnapshot> getCollection({required String collectionPath}) {
  //   return _db.collection(collectionPath).get();
  // }

  // Thêm các phương thức khác để thêm, cập nhật, xóa dữ liệu...
}
