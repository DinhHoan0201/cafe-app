import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/features/admin/view/cloudinary_upload_screen.dart';
import 'package:myapp/features/product/widgets/product_form_widget.dart';
import 'package:provider/provider.dart';
import 'package:myapp/features/product/controller/product_controller.dart';
import 'package:myapp/features/product/model/product_model.dart';

class EditProductScreen extends StatefulWidget {
  final String productId;

  const EditProductScreen({super.key, required this.productId});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _productImageURLController = TextEditingController();
  final _productPriceController = TextEditingController();
  final _productDescriptionController = TextEditingController();
  final _productTypeController = TextEditingController();
  bool _productStatus = true;

  Product? _editingProduct; // Để lưu trữ sản phẩm đang sửa

  @override
  void initState() {
    super.initState();
    final productController = Provider.of<ProductController>(
      context,
      listen: false,
    );
    _editingProduct = productController.products.firstWhere(
      (p) => p.id == widget.productId,
    );

    // Điền thông tin sản phẩm vào các controller
    if (_editingProduct != null && _editingProduct!.id.isNotEmpty) {
      _productNameController.text = _editingProduct!.name;
      _productImageURLController.text = _editingProduct!.imageUrl;
      _productPriceController.text = _editingProduct!.price.toString();
      _productDescriptionController.text = _editingProduct!.description;
      _productTypeController.text = _editingProduct!.type;
      _productStatus = _editingProduct!.status;
    } else if (_editingProduct != null && _editingProduct!.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải thông tin sản phẩm để sửa.')),
      );
    }
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _productImageURLController.dispose();
    _productPriceController.dispose();
    _productDescriptionController.dispose();
    _productTypeController.dispose();
    super.dispose();
  }

  Future<void> _gotoaddImagepage() async {
    // Tương tự AddProductScreen
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

  Future<void> _submitUpdateData() async {
    if (!_formKey.currentState!.validate() ||
        _editingProduct == null ||
        _editingProduct!.id.isEmpty) {
      if (_editingProduct == null || _editingProduct!.id.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể cập nhật, thiếu thông tin sản phẩm.'),
          ),
        );
      }
      return;
    }

    final productController = Provider.of<ProductController>(
      context,
      listen: false,
    );

    bool success = await productController.updateExistingProduct(
      productId: widget.productId,
      productName: _productNameController.text.trim(),
      productImageURL: _productImageURLController.text.trim(),
      productPrice: double.tryParse(_productPriceController.text.trim()) ?? 0,
      productDescription: _productDescriptionController.text.trim(),
      type: _productTypeController.text.trim(),
      status: _productStatus,
    );

    if (success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sản phẩm "${_productNameController.text}" đã được cập nhật!',
          ),
        ),
      );
      Navigator.pop(context);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            productController.errorMessage ?? 'Lỗi khi cập nhật sản phẩm.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sửa Sản Phẩm: ${_editingProduct?.name ?? widget.productId}',
        ),
      ),
      body:
          _editingProduct == null || _editingProduct!.id.isEmpty
              ? Center(child: Text('Không thể tải thông tin sản phẩm.'))
              : Column(
                children: [
                  Expanded(
                    child: Consumer<ProductController>(
                      builder: (context, controller, child) {
                        return ProductFormWidget(
                          formKey: _formKey,
                          productNameController: _productNameController,
                          productImageURLController: _productImageURLController,
                          productPriceController: _productPriceController,
                          productDescriptionController:
                              _productDescriptionController,
                          productTypeController: _productTypeController,
                          // Không truyền productIdController cho Edit mode
                          productStatus: _productStatus,
                          onProductStatusChanged: (value) {
                            setState(() {
                              _productStatus = value;
                            });
                          },
                          onUploadImagePressed: _gotoaddImagepage,
                          isEditMode: true,
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Consumer<ProductController>(
                          // Consumer để lấy isLoading cho nút cập nhật
                          builder: (context, controller, child) {
                            return ElevatedButton.icon(
                              onPressed:
                                  controller.isLoading
                                      ? null
                                      : _submitUpdateData,
                              icon:
                                  controller.isLoading
                                      ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                      : const Icon(Icons.save_as),
                              label: const Text('CẬP NHẬT SẢN PHẨM'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                textStyle: const TextStyle(fontSize: 16),
                                minimumSize: const Size(
                                  double.infinity,
                                  50,
                                ), // Làm nút rộng tối đa
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
