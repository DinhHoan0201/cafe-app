import 'package:flutter/material.dart';
import 'package:myapp/features/product/views/add_products_screen.dart';
import 'package:provider/provider.dart';
import 'package:myapp/features/product/model/product_model.dart';
import 'package:myapp/features/product/controller/product_controller.dart';
import 'package:myapp/features/product/views/edit_product_screen.dart';
import 'package:myapp/shared/widgets/search_bar_widget.dart';
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

  void _navigateToAddProductScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddProductScreen()),
    );
  }

  //
  void _navigateToEditProductScreen(BuildContext context, String productId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductScreen(productId: productId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sử dụng Consumer để lắng nghe thay đổi từ ProductController và rebuild UI
    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách sản phẩm')),
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
          Container(
              //const SearchBarWidget(),
          );
          // Hiển thị danh sách sản phẩm
          return RefreshIndicator(
            onRefresh: () => controller.fetchProducts(),
            child: ListView.builder(
              itemCount: controller.products.length,
              itemBuilder: (context, index) {
                final Product product = controller.products[index];
                return Dismissible(
                  key: Key(product.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    controller.deleteExistingProduct(product.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${product.name} đã được xóa')),
                    );
                  },
                  background: Container(
                    color: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: AlignmentDirectional.centerEnd,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading:
                            product.imageUrl.isNotEmpty
                                ? Image.network(
                                  product.imageUrl,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          const Icon(
                                            Icons.broken_image,
                                            size: 50,
                                          ),
                                )
                                : const Icon(Icons.image, size: 50),
                        title: Text(product.name),
                        subtitle: Text(product.type),

                        trailing: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            _navigateToEditProductScreen(context, product.id);
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: () {
            _navigateToAddProductScreen(context);
          },
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('THÊM SẢN PHẨM MỚI'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15),
            textStyle: const TextStyle(fontSize: 16),
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
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
