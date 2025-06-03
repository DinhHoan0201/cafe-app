import 'dart:io'; // Import for File
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart'; // Import for image picking
import 'package:firebase_storage/firebase_storage.dart'
    as firebase_storage; // Import for Firebase Storage
import 'package:myapp/constants/firestore_paths.dart'; // Your Firestore paths

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});
  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final _productIdController = TextEditingController();
  final _productNameController = TextEditingController();
  final _productPriceController = TextEditingController();
  final _productDescriptionController = TextEditingController(); // Optional

  File? _selectedImage; // To store the selected image file
  bool _isUploading = false; // To track upload state

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _productIdController.dispose();
    _productNameController.dispose();
    _productPriceController.dispose();
    _productDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    } else {
      // User canceled the picker
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không có ảnh nào được chọn.')),
        );
      }
    }
  }

  Future<String?> _uploadImageToStorage(
    File imageFile,
    String productId,
  ) async {
    try {
      // Lấy phần mở rộng của tệp gốc (ví dụ: "jpg", "png")
      String extension = imageFile.path.split('.').last; // Lấy đuôi file gốc
      String fileName =
          'products/$productId/$productId.$extension'; // Tạo tên file mới có dạng products/ID/ID.đuôi_file

      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child(fileName);

      firebase_storage.UploadTask uploadTask = ref.putFile(imageFile);
      await uploadTask;
      return fileName;
    } catch (e) {
      print('Error uploading image to Firebase Storage: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tải ảnh lên máy chủ: $e')));
      }
      return null; // Trả về null nếu có lỗi
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
      String productId = _productIdController.text.trim();
      String productName =
          _productNameController.text.trim(); // Lấy tên sản phẩm

      String imageReferenceToStore;
      String dynamicFallbackIdentifier =
          "${productName.toLowerCase().replaceAll(' ', '')}$productId";

      // 1. Xử lý ảnh
      if (_selectedImage == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Không có ảnh được chọn. Sử dụng định danh thay thế: $dynamicFallbackIdentifier',
              ),
            ),
          );
        }
        imageReferenceToStore = dynamicFallbackIdentifier;
      } else {
        // Đã chọn ảnh, tiến hành tải lên
        // _uploadImageToStorage bây giờ trả về đường dẫn tương đối
        String? uploadedRelativePath = await _uploadImageToStorage(
          _selectedImage!,
          productId,
        );

        if (uploadedRelativePath != null) {
          imageReferenceToStore =
              uploadedRelativePath; // Lưu đường dẫn thật nếu tải lên thành công
        } else {
          // Tải ảnh thất bại, _uploadImageToStorage đã hiển thị SnackBar lỗi.
          // Sử dụng định danh tùy chỉnh làm fallback.
          imageReferenceToStore = dynamicFallbackIdentifier;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Lỗi tải ảnh lên. Sử dụng định danh thay thế: $dynamicFallbackIdentifier',
                ),
              ),
            );
          }
        }
      }

      await FirebaseFirestore.instance
          .collection(FirestorePaths.topLevelCfdb)
          .doc(FirestorePaths.defaultParentInCfdb)
          .collection(FirestorePaths.productsSubCollection)
          .doc(
            productId,
          ) // Sử dụng ID sản phẩm người dùng nhập (ví dụ: "01", "02")
          .set({
            'name': _productNameController.text.trim(),
            'price':
                double.tryParse(_productPriceController.text.trim()) ?? 0.0,
            'description': _productDescriptionController.text.trim(),
            'imageUrl':
                imageReferenceToStore, // Lưu đường dẫn thật hoặc định danh tùy chỉnh
            'productId': productId, // Lưu lại ID để dễ truy vấn nếu cần
            'timestamp': FieldValue.serverTimestamp(),
          });

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
        _productNameController.clear();
        _productPriceController.clear();
        _selectedImage = null; // Clear the selected image
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
              GestureDetector(
                onTap: _pickImage, // Gọi hàm chọn ảnh khi nhấn vào
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child:
                      _selectedImage != null
                          ? Image.file(_selectedImage!, fit: BoxFit.cover)
                          : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt,
                                size: 50,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Chạm để chọn ảnh',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ],
                          ),
                ),
              ),
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
