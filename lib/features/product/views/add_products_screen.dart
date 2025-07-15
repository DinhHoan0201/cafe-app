import 'package:flutter/material.dart';
import 'package:myapp/features/product/data/product_service.dart';
import 'package:myapp/features/admin/view/cloudinary_upload_screen.dart';
import 'package:myapp/features/product/widgets/product_form_widget.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});
  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final _productImageURLController = TextEditingController();
  final _productNameController = TextEditingController();
  final _productPriceController = TextEditingController();
  final _productDescriptionController = TextEditingController();
  final _productTypeController = TextEditingController();

  bool _isUploading = false;
  bool _productStatus = true;

  final ProductService _productService = ProductService();
  @override
  void dispose() {
    _productImageURLController.dispose();
    _productNameController.dispose();
    _productPriceController.dispose();
    _productDescriptionController.dispose();
    _productTypeController.dispose();
    super.dispose();
  }

  Future<void> _gotoaddImagepage() async {
    final String? uploadedImageUrl = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => CloudinaryUploadScreen()),
    );

    if (uploadedImageUrl != null && uploadedImageUrl.isNotEmpty) {
      setState(() {
        _productImageURLController.text = uploadedImageUrl;
      });
    }
  }

  Future<void> _submitProductData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isUploading = true;
    });

    try {
      String productImageURL = _productImageURLController.text.trim();
      String productName = _productNameController.text.trim();
      String productType = _productTypeController.text.trim();
      await _productService.addProduct(
        id: '', // ID sẽ được tự động tạo bởi Firestore
        productName: productName,
        productImageURL: productImageURL,
        productPrice: double.tryParse(_productPriceController.text.trim()) ?? 0,
        productDescription: _productDescriptionController.text.trim(),
        status: _productStatus,
        type: _productTypeController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sản phẩm "$productName"  đã được thêm thành công!'),
        ),
      );
      // Xóa form sau khi thành công
      _formKey.currentState!.reset();
      setState(() {
        _productImageURLController.clear();
        _productNameController.clear();
        _productPriceController.clear();
        _productDescriptionController.clear();
        _productStatus = true;
        _productTypeController.clear();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi thêm sản phẩm vào Firestore: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm Sản Phẩm Mới')),
      body: Column(
        children: [
          Expanded(
            child: ProductFormWidget(
              formKey: _formKey,
              productNameController: _productNameController,
              productImageURLController: _productImageURLController,
              productPriceController: _productPriceController,
              productDescriptionController: _productDescriptionController,
              productTypeController: _productTypeController,
              productStatus: _productStatus,
              onProductStatusChanged: (value) {
                setState(() {
                  _productStatus = value;
                });
              },
              onUploadImagePressed: _gotoaddImagepage,
              isEditMode: false,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _isUploading ? null : _submitProductData,
              icon:
                  _isUploading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : const Icon(Icons.save),
              label: const Text('LƯU SẢN PHẨM'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                textStyle: const TextStyle(fontSize: 16),
                minimumSize: const Size(
                  double.infinity,
                  50,
                ), // Làm nút rộng tối đa
              ),
            ),
          ),
        ],
      ),
    );
  }
}
