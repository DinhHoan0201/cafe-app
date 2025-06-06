import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/product_model.dart';
import 'package:myapp/widgets/product/product_image_widget.dart'; // Import hàm build ảnh

class SpecialForYouSection extends StatelessWidget {
  final CollectionReference<Map<String, dynamic>> productsCollection;

  const SpecialForYouSection({super.key, required this.productsCollection});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Special for you",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 10),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream:
              productsCollection
                  .orderBy('sale', descending: true) // Giả sử sắp xếp theo sale
                  .limit(2) // Lấy 2 sản phẩm
                  .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.orangeAccent,
                  ),
                ),
              );
            }
            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'Không tìm thấy sản phẩm đặc biệt nào.',
                  style: TextStyle(color: Colors.white54),
                ),
              );
            }

            final specialProductDocs = snapshot.data!.docs;

            // Sử dụng Column để hiển thị các sản phẩm theo chiều dọc, mỗi sản phẩm là một khối
            return Column(
              children:
                  specialProductDocs.map((doc) {
                    final specialProduct = Product.fromFirestore(doc);
                    final Widget bannerImage = buildProductImageWidget(
                      specialProduct.imageUrl,
                    );

                    // Mỗi sản phẩm là một Container (khối) riêng biệt được tạo kiểu
                    return Container(
                      margin: const EdgeInsets.only(
                        bottom: 12.0,
                      ), // Khoảng cách giữa các khối
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: SizedBox(
                              width: 84,
                              height: 84,
                              child: bannerImage,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  specialProduct.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "\$${specialProduct.price.toStringAsFixed(1)}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            );
          },
        ),
      ],
    );
  }
}
