import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:myapp/core/constants/firestore_paths.dart';
import 'package:myapp/features/product/model/product_model.dart'; // Import Product model

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_storage.FirebaseStorage _storage =
      firebase_storage.FirebaseStorage.instance;

  Future<void> addProduct({
    required String productId,
    required String productName,
    required String productImageURL,
    required double productPrice,
    required String productDescription,
    required String type,
    required bool status,
    //required String imageUrl, // Đây sẽ là đường dẫn từ Storage hoặc fallback
  }) async {
    try {
      await _firestore
          .collection(FirestorePaths.topLevelCfdb)
          .doc(FirestorePaths.defaultParentInCfdb)
          .collection(FirestorePaths.productsSubCollection)
          .doc(productId)
          .set({
            'name': productName,
            'price': productPrice,
            'description': productDescription,
            'imageUrl': productImageURL,
            'productId': productId,
            'timestamp': FieldValue.serverTimestamp(),
            'status': status,
            //'sale': 0.0,
            'type': type,
          });
    } catch (e) {
      print('Error adding product to Firestore: $e');
      rethrow; // Ném lại lỗi để UI có thể xử lý
    }
  }

  Future<List<Product>> getProducts() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await _firestore
              .collection(FirestorePaths.topLevelCfdb)
              .doc(FirestorePaths.defaultParentInCfdb)
              .collection(FirestorePaths.productsSubCollection)
              .orderBy('timestamp', descending: true)
              .get();

      List<Product> products =
          querySnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
      return products;
    } catch (e) {
      print('Error fetching products from Firestore: $e');
      rethrow;
    }
  }

  Future<void> updateProduct({
    required String productId,
    required String productName,
    required String productImageURL,
    required double productPrice,
    required String productDescription,
    required String type,
    required bool status,
  }) async {
    try {
      await _firestore
          .collection(FirestorePaths.topLevelCfdb)
          .doc(FirestorePaths.defaultParentInCfdb)
          .collection(FirestorePaths.productsSubCollection)
          .doc(productId)
          .update({
            'name': productName,
            'price': productPrice,
            'description': productDescription,
            'imageUrl': productImageURL,
            'status': status,
            'type': type,
            'timestamp':
                FieldValue.serverTimestamp(), // Cập nhật timestamp khi sửa đổi
          });
    } catch (e) {
      print('Error updating product in Firestore: $e');
      rethrow; // Ném lại lỗi để UI có thể xử lý
    }
  }

  Future<void> deleteProduct({required String productId}) async {
    try {
      await _firestore
          .collection(FirestorePaths.topLevelCfdb)
          .doc(FirestorePaths.defaultParentInCfdb)
          .collection(FirestorePaths.productsSubCollection)
          .doc(productId)
          .delete();
    } catch (e) {
      print('Error delete product in Firestore: $e');
      rethrow;
    }
  }
}
