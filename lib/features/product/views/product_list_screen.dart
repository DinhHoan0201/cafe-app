import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/features/product/model/product_model.dart';
import 'package:myapp/features/product/controller/product_controller.dart'; // Corrected import

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  @override
  void initState() {
    super.initState();
    final productController = Provider.of<ProductController>(
      context,
      listen: false,
    );
    productController.fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    // Sử dụng Consumer để lắng nghe thay đổi từ ProductController và rebuild UI
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách sản phẩm'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Gọi lại fetchProducts khi người dùng nhấn nút refresh
              Provider.of<ProductController>(
                context,
                listen: false,
              ).fetchProducts();
            },
          ),
        ],
      ),
      body: Consumer<ProductController>(
        builder: (context, controller, child) {
          if (controller.isLoading && controller.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage != null && controller.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Lỗi: ${controller.errorMessage}'),
                  ElevatedButton(
                    onPressed: () => controller.fetchProducts(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (controller.products.isEmpty) {
            return const Center(child: Text('Không có sản phẩm nào.'));
          }

          // Hiển thị danh sách sản phẩm
          return RefreshIndicator(
            onRefresh: () => controller.fetchProducts(), // Kéo để làm mới
            child: ListView.builder(
              itemCount: controller.products.length,
              itemBuilder: (context, index) {
                final Product product = controller.products[index];
                return Dismissible(
                  key: Key(product.id), // Key là bắt buộc cho Dismissible
                  direction:
                      DismissDirection
                          .endToStart, // Trượt từ phải sang trái để xóa
                  onDismissed: (direction) {
                    // TODO: Gọi controller.deleteProduct(product.id)
                    // Có thể hiển thị SnackBar để hoàn tác
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${product.name} đã được xóa (chưa thực thi)',
                        ),
                      ),
                    );
                    print('Dismissed (delete) product: ${product.id}');
                  },
                  background: Container(
                    color: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: AlignmentDirectional.centerEnd,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: ListTile(
                    leading:
                        product.imageUrl.isNotEmpty
                            ? Image.network(
                              product.imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image, size: 50),
                            )
                            : const Icon(Icons.image, size: 50),
                    title: Text(product.name),
                    subtitle: Text(
                      'Giá: ${product.price} - Loại: ${product.type}',
                    ),
                    // Bạn vẫn có thể thêm nút edit ở đây nếu muốn
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        print('Edit product: ${product.id}');
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Điều hướng đến màn hình thêm sản phẩm
      //     // Navigator.push(context, MaterialPageRoute(builder: (context) => AddProductScreen()));
      //   },
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}
