import 'package:flutter/material.dart';
import 'package:myapp/features/product/model/product_model.dart';

class CategoryList extends StatelessWidget {
  final List<Product> allProducts;
  final String? selectedCategoryName;
  final ValueChanged<String?> onCategorySelected;

  const CategoryList({
    super.key,
    required this.allProducts,
    required this.selectedCategoryName,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Builder(
        builder: (context) {
          if (allProducts.isEmpty) {
            return const Center(
              child: Text(
                'Không có danh mục',
                style: TextStyle(color: Colors.white54),
              ),
            );
          }

          List<String> displayCategories = ["Tất cả"];
          final productNamesAsCategories =
              allProducts.map((product) => product.name).toSet().toList()
                ..sort();
          displayCategories.addAll(productNamesAsCategories);

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: displayCategories.length,
            itemBuilder: (context, index) {
              final categoryName = displayCategories[index];
              final isSelected =
                  (selectedCategoryName == null && categoryName == "Tất cả") ||
                  selectedCategoryName == categoryName;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: TextButton(
                  onPressed: () {
                    onCategorySelected(
                      categoryName == "Tất cả" ? null : categoryName,
                    );
                  },
                  child: Text(
                    categoryName,
                    style: TextStyle(
                      color: isSelected ? Colors.orangeAccent : Colors.white,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
