import 'dart:io'; // Import for File
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart'; // Import for image picking
import 'package:firebase_storage/firebase_storage.dart'
    as firebase_storage; // Import for Firebase Storage
import 'package:myapp/constants/firestore_paths.dart'; // Your Firestore paths
import 'package:myapp/services/product_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});
  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final _productIdController = TextEditingController();
  final _productImageURLController = TextEditingController();
  final _productNameController = TextEditingController();
  final _productPriceController = TextEditingController();
  final _productDescriptionController = TextEditingController(); // Optional

  //File? _selectedImage; // To store the selected image file
  bool _isUploading = false; // To track upload state

  //final ImagePicker _picker = ImagePicker();
  final ProductService _productService = ProductService();
  @override
  void dispose() {
    _productIdController.dispose();
    _productImageURLController.dispose();
    _productNameController.dispose();
    _productPriceController.dispose();
    _productDescriptionController.dispose();
    super.dispose();
  }

  // Future<void> _pickImage() async {
  //   final XFile? pickedFile = await _picker.pickImage(
  //     source: ImageSource.gallery,
  //   );

  //   if (pickedFile != null) {
  //     setState(() {
  //       _selectedImage = File(pickedFile.path);
  //     });
  //   } else {
  //     // User canceled the picker
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Không có ảnh nào được chọn.')),
  //       );
  //     }
  //   }
  // }

  Future<void> _submitProductData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isUploading = true;
    });

    try {
      String productId = _productIdController.text.trim();
      String productImageURL = _productImageURLController.text.trim();
      String productName = _productNameController.text.trim();
      String imageReferenceToStore;
      String dynamicFallbackIdentifier =
          "${productName.toLowerCase().replaceAll(' ', '')}$productId";

      // if (_selectedImage == null) {
      //   if (mounted) {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(
      //         content: Text(
      //           'Không có ảnh được chọn. Sử dụng định danh thay thế: $dynamicFallbackIdentifier',
      //         ),
      //       ),
      //     );
      //   }
      //   imageReferenceToStore = dynamicFallbackIdentifier;
      // } else {
      //   String? uploadedRelativePath = await _productService.uploadProductImage(
      //     _selectedImage!,
      //     productId,
      //   );

      //   if (uploadedRelativePath != null) {
      //     imageReferenceToStore = uploadedRelativePath;
      //   } else {
      //     imageReferenceToStore = dynamicFallbackIdentifier;
      //     if (mounted) {
      //       ScaffoldMessenger.of(context).showSnackBar(
      //         SnackBar(
      //           content: Text(
      //             'Lỗi tải ảnh lên. Sử dụng định danh thay thế: $dynamicFallbackIdentifier',
      //           ),
      //         ),
      //       );
      //     }
      //   }
      // }

      await _productService.addProduct(
        productId: productId,
        productName: productName,
        productImageURL: productImageURL,
        productPrice: double.tryParse(_productPriceController.text.trim()) ?? 0,
        productDescription: _productDescriptionController.text.trim(),
        //imageUrl: imageReferenceToStore,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sản phẩm "$productName" (ID: $productId) đã được thêm thành công!',
          ),
        ),
      );
      // Xóa form sau khi thành công
      _formKey.currentState!.reset();
      setState(() {
        _productIdController.clear();
        _productImageURLController.clear();
        _productNameController.clear();
        _productPriceController.clear();
        //_selectedImage = null; // Clear the selected image
        _productDescriptionController.clear();
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
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: ListView(
            // Sử dụng ListView để tránh overflow khi bàn phím hiện
            children: <Widget>[
              const SizedBox(height: 16),
              TextFormField(
                controller: _productIdController,
                decoration: const InputDecoration(
                  labelText: 'ID Sản Phẩm (ví dụ: 01, 02)',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        (value == null || value.isEmpty)
                            ? 'Vui lòng nhập ID sản phẩm'
                            : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _productImageURLController,
                decoration: const InputDecoration(
                  labelText: 'Image URL (tùy chọn)',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        (value == null || value.isEmpty)
                            ? 'Vui lòng nhập Image URL'
                            : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _productNameController,
                decoration: const InputDecoration(
                  labelText: 'Tên Sản Phẩm',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        (value == null || value.isEmpty)
                            ? 'Vui lòng nhập tên sản phẩm'
                            : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _productPriceController,
                decoration: const InputDecoration(
                  labelText: 'Giá Sản Phẩm',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập giá';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Giá không hợp lệ';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Giá phải lớn hơn 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _productDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Mô Tả (tùy chọn)',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                textAlignVertical: TextAlignVertical.top,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed:
                    _isUploading
                        ? null
                        : _submitProductData, // Disable button when uploading
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
                  // Thêm màu cho nút nếu muốn
                  // backgroundColor: Theme.of(context).primaryColor,
                  // foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
