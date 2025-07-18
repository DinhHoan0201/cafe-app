import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:myapp/constants/firestore_paths.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_storage.FirebaseStorage _storage =
      firebase_storage.FirebaseStorage.instance;

  Future<String?> uploadProductImage(File imageFile, String productId) async {
    try {
      String extension = imageFile.path.split('.').last;
      String fileName = 'products/$productId/$productId.$extension';
      firebase_storage.Reference ref = _storage.ref().child(fileName);
      firebase_storage.UploadTask uploadTask = ref.putFile(imageFile);
      await uploadTask;
      return fileName;
    } catch (e) {
      print('Error uploading image to Firebase Storage: $e');
      return null;
    }
  }

  Future<void> addProduct({
    required String productId,
    required String productName,
    required double productPrice,
    required String productDescription,
    required String imageUrl,
  }) async {
    await _firestore
        .collection(FirestorePaths.topLevelCfdb)
        .doc(FirestorePaths.defaultParentInCfdb)
        .collection(FirestorePaths.productsSubCollection)
        .doc(productId)
        .set({
          'name': productName,
          'price': productPrice,
          'description': productDescription,
          'imageUrl': imageUrl,
          'productId': productId,
          'timestamp': FieldValue.serverTimestamp(),
        });
  }
}
