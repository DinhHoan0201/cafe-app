import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:myapp/features/product/model/product_model.dart';
import 'package:myapp/features/product/widgets/product_image_widget.dart';

class ProductList extends StatelessWidget {
  final List<Product> products;
  final String searchQuery;
  final String? selectedCategoryName;
  const ProductList({
    super.key,
    required this.products,
    required this.searchQuery,
    this.selectedCategoryName,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Builder(
        builder: (context) {
          if (products.isEmpty) {
            return const Center(
              child: Text(
                'Không có sản phẩm nào.',
                style: TextStyle(color: Colors.white54),
              ),
            );
          }

          List<Product> filteredProducts = List.from(products);

          // 1. Lọc theo category trước
          if (selectedCategoryName != null) {
            filteredProducts =
                filteredProducts
                    .where((product) => product.name == selectedCategoryName)
                    .toList();
          }

          // 2. Sau đó lọc theo searchQuery trên danh sách đã lọc theo category
          if (searchQuery.isNotEmpty) {
            final lowerCaseQuery = searchQuery.toLowerCase();
            filteredProducts =
                filteredProducts.where((product) {
                  final nameMatches = product.name.toLowerCase().contains(
                    lowerCaseQuery,
                  );
                  final typeMatches = product.type.toLowerCase().contains(
                    lowerCaseQuery,
                  );
                  return nameMatches || typeMatches;
                }).toList();
          }

          if (filteredProducts.isEmpty) {
            return const Center(
              child: Text(
                'Không tìm thấy sản phẩm nào khớp với lựa chọn.', // Cập nhật thông báo
                style: TextStyle(color: Colors.white54),
              ),
            );
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              final product = filteredProducts[index];
              final Widget productImageWidget = buildProductImageWidget(
                product.imageUrl,
              );

              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: productImageWidget,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            product.type,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            product.description.isNotEmpty
                                ? "Available"
                                : "Unavailable",
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "\$${product.price.toStringAsFixed(1)}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const CircleAvatar(
                                backgroundColor: Colors.orange,
                                child: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                radius: 14,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
