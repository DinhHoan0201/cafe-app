import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/features/product/controller/product_controller.dart';
import 'package:myapp/features/product/model/product_model.dart';
import 'package:myapp/shared/widgets/app_header.dart';
import 'package:myapp/shared/widgets/search_bar_widget.dart';
import 'package:myapp/features/product/widgets/category_list_widget.dart';
import 'package:myapp/features/product/widgets/product_list_widget.dart';
import 'package:myapp/features/product/widgets/special_for_you_widget.dart';

class Products extends StatefulWidget {
  const Products({super.key});
  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  String? _selectedCategoryName;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductController>(context, listen: false).fetchProducts();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductController>(
      builder: (context, controller, child) {
        final List<Product> allProducts = controller.products;
        return RefreshIndicator(
          onRefresh: () => controller.fetchProducts(),
          child: Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      const AppHeader(),
                      const SizedBox(height: 20),

                      const SizedBox(height: 20),
                      SearchBarWidget(
                        onSearchChanged: (query) {
                          setState(() {
                            _searchQuery = query;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      CategoryList(
                        allProducts: allProducts,
                        selectedCategoryName: _selectedCategoryName,
                        onCategorySelected: (categoryName) {
                          setState(() {
                            _selectedCategoryName = categoryName;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      if (controller.isLoading && allProducts.isEmpty)
                        const Center(
                          child: CircularProgressIndicator(
                            color: Colors.orangeAccent,
                          ),
                        )
                      else if (controller.errorMessage != null &&
                          allProducts.isEmpty)
                        Center(
                          child: Text(
                            'Lỗi: ${controller.errorMessage}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        )
                      else if (allProducts.isEmpty && !controller.isLoading)
                        const Center(
                          child: Text(
                            'Không có sản phẩm nào.',
                            style: TextStyle(color: Colors.white54),
                          ),
                        )
                      else
                        ProductList(
                          products: allProducts,
                          selectedCategoryName: _selectedCategoryName,
                          searchQuery: _searchQuery,
                        ),
                      const SizedBox(height: 10),
                      SpecialForYouSection(allProducts: allProducts),
                    ],
                  ),
                ),
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: Colors.white,
              selectedItemColor: Colors.brown,
              type: BottomNavigationBarType.fixed,
              unselectedItemColor: Colors.grey,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_filled),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_bag_outlined),
                  label: '',
                ),
                BottomNavigationBarItem(icon: Icon(Icons.coffee), label: ''),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite_border),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.location_on_outlined),
                  label: '',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
