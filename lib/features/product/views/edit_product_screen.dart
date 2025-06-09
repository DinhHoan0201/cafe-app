// c:\Users\Admin\myapp\lib\features\product\views\edit_product_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/features/admin/view/cloudinary_upload_screen.dart';
import 'package:provider/provider.dart';
import 'package:myapp/features/product/controller/product_controller.dart';
import 'package:myapp/features/product/model/product_model.dart';
// Import các file cần thiết khác như CloudinaryUploadScreen nếu cần

class EditProductScreen extends StatefulWidget {
  final String productId; // Hoặc final Product product;

  const EditProductScreen({super.key, required this.productId});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  // Khai báo các TextEditingController tương tự như AddProductScreen
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
    // Lấy ProductController
    final productController = Provider.of<ProductController>(
      context,
      listen: false,
    );
    // Tìm sản phẩm cần sửa từ danh sách đã fetch (hoặc fetch chi tiết nếu cần)
    // Đây là cách đơn giản nếu danh sách sản phẩm đã có trong controller
    _editingProduct = productController.products.firstWhere(
      (p) => p.id == widget.productId,
      orElse: () {
        // Xử lý trường hợp không tìm thấy sản phẩm, có thể pop màn hình hoặc hiển thị lỗi
        // Hoặc bạn có thể tạo một hàm trong controller để fetch chi tiết sản phẩm theo ID
        print("Không tìm thấy sản phẩm với ID: ${widget.productId}");
        // Navigator.pop(context); // Ví dụ: quay lại nếu không tìm thấy
        return Product(
          id: '',
          name: '',
          price: 0,
          description: '',
          imageUrl: '',
          timestamp: Timestamp.now(),
          status: true,
          sale: 0,
          type: '',
        ); // Dummy product
      },
    );

    // Điền thông tin sản phẩm vào các controller
    if (_editingProduct != null && _editingProduct!.id.isNotEmpty) {
      // Kiểm tra _editingProduct không phải là dummy
      _productNameController.text = _editingProduct!.name;
      _productImageURLController.text = _editingProduct!.imageUrl;
      _productPriceController.text = _editingProduct!.price.toString();
      _productDescriptionController.text = _editingProduct!.description;
      _productTypeController.text = _editingProduct!.type;
      _productStatus = _editingProduct!.status;
    } else if (_editingProduct != null && _editingProduct!.id.isEmpty) {
      // Nếu là dummy product (không tìm thấy), có thể hiển thị thông báo và không cho sửa
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể tải thông tin sản phẩm để sửa.')),
        );
      });
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

    // TODO: Gọi hàm updateProduct trong ProductController
    // bool success = await productController.updateExistingProduct(
    //   productId: widget.productId,
    //   productName: _productNameController.text.trim(),
    //   productImageURL: _productImageURLController.text.trim(),
    //   productPrice: double.tryParse(_productPriceController.text.trim()) ?? 0,
    //   productDescription: _productDescriptionController.text.trim(),
    //   type: _productTypeController.text.trim(),
    //   status: _productStatus,
    // );
    bool success = false; // Placeholder
    print("Cần implement productController.updateExistingProduct");

    if (success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sản phẩm "${_productNameController.text}" đã được cập nhật!',
          ),
        ),
      );
      Navigator.pop(context); // Quay lại màn hình danh sách
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
    // UI tương tự như AddProductScreen, nhưng nút bấm sẽ là "Cập nhật sản phẩm"
    // và tiêu đề AppBar là "Sửa sản phẩm"
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sửa Sản Phẩm: ${_editingProduct?.name ?? widget.productId}',
        ),
      ),
      body:
          _editingProduct == null || _editingProduct!.id.isEmpty
              ? Center(child: Text('Không thể tải thông tin sản phẩm.'))
              : Padding(
                padding: const EdgeInsets.all(28),
                child: Consumer<ProductController>(
                  // Để lấy trạng thái isLoading từ controller
                  builder: (context, controller, child) {
                    return Form(
                      key: _formKey,
                      child: ListView(
                        children: <Widget>[
                          // Các TextFormField tương tự AddProductScreen
                          // Ví dụ:
                          ElevatedButton(
                            onPressed: _gotoaddImagepage,
                            child: Text('Thay Đổi Ảnh Sản Phẩm (Cloudinary)'),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _productImageURLController,
                            decoration: const InputDecoration(
                              labelText: 'Image URL',
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
                            controller: _productTypeController,
                            decoration: const InputDecoration(
                              labelText: 'Loại Sản Phẩm',
                              border: OutlineInputBorder(),
                            ),
                            validator:
                                (value) =>
                                    (value == null || value.isEmpty)
                                        ? 'Vui lòng nhập loại sản phẩm'
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
                              if (value == null || value.isEmpty)
                                return 'Vui lòng nhập giá';
                              if (double.tryParse(value) == null)
                                return 'Giá không hợp lệ';
                              if (double.parse(value) <= 0)
                                return 'Giá phải lớn hơn 0';
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
                          const SizedBox(height: 12),
                          SwitchListTile(
                            title: const Text(
                              'Trạng thái sản phẩm (Active/Inactive)',
                            ),
                            value: _productStatus,
                            onChanged: (bool value) {
                              setState(() {
                                _productStatus = value;
                              });
                            },
                            activeColor: Theme.of(context).primaryColor,
                            secondary: Icon(
                              _productStatus
                                  ? Icons.check_circle
                                  : Icons.remove_circle_outline,
                            ),
                            subtitle: Text(
                              _productStatus ? 'Available' : 'Unavailable',
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed:
                                controller.isLoading ? null : _submitUpdateData,
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
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
