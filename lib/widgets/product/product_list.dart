import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/product_model.dart';
import 'package:myapp/widgets/product/product_image_widget.dart'; // Import hàm build ảnh

class ProductList extends StatelessWidget {
  final Stream<QuerySnapshot<Map<String, dynamic>>> productStream;
  final String searchQuery;
  const ProductList({
    super.key,
    required this.productStream,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: productStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Không tìm thấy sản phẩm nào.',
                style: TextStyle(color: Colors.white54),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orangeAccent),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            if (searchQuery.isEmpty) {
              return const Center(
                child: Text(
                  'Không có sản phẩm nào.',
                  style: TextStyle(color: Colors.white54),
                ),
              );
            }
          }

          List<DocumentSnapshot<Map<String, dynamic>>> productDocs =
              snapshot.data?.docs ?? [];
          List<DocumentSnapshot<Map<String, dynamic>>> displayDocs =
              productDocs;

          if (searchQuery.isNotEmpty) {
            final lowerCaseQuery = searchQuery.toLowerCase();
            displayDocs =
                productDocs.where((docSnapshot) {
                  final product = Product.fromFirestore(docSnapshot);
                  final nameMatches = product.name.toLowerCase().contains(
                    lowerCaseQuery,
                  );

                  final typeMatches = product.type.toLowerCase().contains(
                    lowerCaseQuery,
                  );
                  return nameMatches || typeMatches;
                }).toList();
          }

          if (displayDocs.isEmpty) {
            return const Center(
              child: Text(
                'Không tìm thấy sản phẩm nào.',
                style: TextStyle(color: Colors.white54),
              ),
            );
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: displayDocs.length,
            itemBuilder: (context, index) {
              final productData = displayDocs[index];
              final product = Product.fromFirestore(productData);
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
