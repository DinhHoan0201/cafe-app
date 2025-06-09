import 'package:flutter/material.dart';

class ProductFormWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController productNameController;
  final TextEditingController productImageURLController;
  final TextEditingController productPriceController;
  final TextEditingController productDescriptionController;
  final TextEditingController productTypeController;
  final TextEditingController?
  productIdController; // Chỉ dùng cho AddProductScreen
  final bool productStatus;
  final ValueChanged<bool> onProductStatusChanged;
  final VoidCallback onUploadImagePressed;
  final bool isEditMode;

  const ProductFormWidget({
    super.key,
    required this.formKey,
    required this.productNameController,
    required this.productImageURLController,
    required this.productPriceController,
    required this.productDescriptionController,
    required this.productTypeController,
    this.productIdController,
    required this.productStatus,
    required this.onProductStatusChanged,
    required this.onUploadImagePressed,
    this.isEditMode = false,
  });
  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(28), // Giữ padding gốc
        children: <Widget>[
          ElevatedButton(
            onPressed: onUploadImagePressed,
            child: Text(
              isEditMode
                  ? 'Thay Đổi Ảnh Sản Phẩm (Cloudinary)'
                  : 'Upload Ảnh Sản Phẩm (Cloudinary)',
            ),
          ),
          const SizedBox(height: 16),
          if (productIdController != null && !isEditMode) ...[
            TextFormField(
              controller: productIdController,
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
          ],
          TextFormField(
            controller: productImageURLController,
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
            controller: productNameController,
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
            controller: productTypeController,
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
            controller: productPriceController,
            decoration: const InputDecoration(
              labelText: 'Giá Sản Phẩm',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Vui lòng nhập giá';
              if (double.tryParse(value) == null) return 'Giá không hợp lệ';
              if (double.parse(value) <= 0) return 'Giá phải lớn hơn 0';
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: productDescriptionController,
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
            title: const Text('Trạng thái sản phẩm (Active/Inactive)'),
            value: productStatus,
            onChanged: onProductStatusChanged,
            activeColor: Theme.of(context).primaryColor,
            secondary: Icon(
              productStatus ? Icons.check_circle : Icons.remove_circle_outline,
            ),
            subtitle: Text(productStatus ? 'Available' : 'Unavailable'),
          ),
        ],
      ),
    );
  }
}
