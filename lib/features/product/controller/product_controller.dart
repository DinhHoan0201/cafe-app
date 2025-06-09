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
    notifyListeners(); // Thông báo UI rằng quá trình tải bắt đầu

    try {
      _products = await _productService.getProducts();
    } catch (e) {
      _errorMessage = "Lỗi tải danh sách sản phẩm: $e";
      _products = []; // Đảm bảo products là list rỗng khi có lỗi
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners(); // Thông báo UI rằng quá trình tải đã kết thúc (thành công hoặc thất bại)
    }
  }

  Future<bool> addProduct({
    required String productId,
    required String productName,
    required String productImageURL,
    required double productPrice,
    required String productDescription,
    required String type,
    required bool status,
  }) async {
    // Giữ nguyên logic của hàm addProduct
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _productService.addProduct(
        productId: productId,
        productName: productName,
        productImageURL: productImageURL,
        productPrice: productPrice,
        productDescription: productDescription,
        type: type,
        status: status,
      );
      // Sau khi thêm thành công, có thể fetch lại danh sách sản phẩm
      // await fetchProducts(); // Bỏ comment nếu muốn tự động cập nhật list sau khi thêm
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

  // Thêm các hàm updateProduct, deleteProduct ở đây và gọi service tương ứng
  // Ví dụ:
  // Future<void> updateExistingProduct(Product productToUpdate) async {
  //   _isLoading = true;
  //   _errorMessage = null;
  //   notifyListeners();
  //   try {
  //     await _productService.updateProduct(
  //       productId: productToUpdate.id,
  //       productName: productToUpdate.name,
  //       // ... các trường khác
  //     );
  //     await fetchProducts(); // Tải lại danh sách sau khi cập nhật
  //   } catch (e) {
  //     _errorMessage = "Lỗi cập nhật sản phẩm: $e";
  //     print(_errorMessage);
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }
}
