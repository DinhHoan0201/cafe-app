import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/features/product/data/product_service.dart';
import 'package:myapp/features/product/model/product_model.dart';

class ProductController with ChangeNotifier {
  final ProductService _productService = ProductService();

  List<Product> _products = [];
  List<Product> get products => _products;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Constructor để tự động fetch khi controller được tạo (tùy chọn)
  // ProductController() {
  //   fetchProducts();
  // }

  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _productService.getProducts();
    } catch (e) {
      _errorMessage = "Lỗi tải danh sách sản phẩm: $e";
      _products = [];
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addProduct({
    required String id,
    required String productName,
    required String productImageURL,
    required double productPrice,
    required String productDescription,
    required String type,
    required bool status,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final docRef = FirebaseFirestore.instance.collection('products').doc();
      await _productService.addProduct(
        id: docRef.id,
        productName: productName,
        productImageURL: productImageURL,
        productPrice: productPrice,
        productDescription: productDescription,
        type: type,
        status: status,
      );
      await fetchProducts();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "Lỗi khi thêm sản phẩm: $e";
      print(_errorMessage);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateExistingProduct({
    required String productId,
    required String productName,
    required String productImageURL,
    required double productPrice,
    required String productDescription,
    required String type,
    required bool status,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _productService.updateProduct(
        productId: productId,
        productName: productName,
        productImageURL: productImageURL,
        productPrice: productPrice,
        productDescription: productDescription,
        type: type,
        status: status,
      );

      await fetchProducts();
      return true;
    } catch (e) {
      _errorMessage = "Lỗi cập nhật sản phẩm: $e";
      print(_errorMessage);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  ///
  Future<bool> deleteExistingProduct(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _productService.deleteProduct(productId: id);
      await fetchProducts();
      return true;
    } catch (e) {
      _errorMessage = "Lỗi cập nhật sản phẩm: $e";
      print(_errorMessage);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
