import 'package:flutter/material.dart';
import 'package:myapp/features/product/model/product_model.dart';
import 'package:myapp/features/product/widgets/product_image_widget.dart'; // Import hàm build ảnh

class SpecialForYouSection extends StatelessWidget {
  final List<Product> allProducts; // Thay đổi: Nhận List<Product>

  const SpecialForYouSection({
    super.key,
    required this.allProducts,
  }); // Thay đổi

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
        Builder(
          // Sử dụng Builder hoặc kiểm tra allProducts.isEmpty trực tiếp
          builder: (context) {
            if (allProducts.isEmpty) {
              return const Center(
                child: Text(
                  'Không có sản phẩm đặc biệt nào.', // Hoặc 'Đang tải...'
                  style: TextStyle(color: Colors.white54),
                ),
              );
            }

            // Lọc và sắp xếp sản phẩm đặc biệt từ allProducts
            // Ví dụ: lấy sản phẩm có 'sale' > 0 (hoặc một trường 'isSpecial' boolean),
            // sắp xếp giảm dần theo 'sale' (hoặc một trường ưu tiên), lấy 2 sản phẩm đầu.
            // Bạn có thể thay đổi logic này tùy theo cách bạn định nghĩa "special".
            List<Product> specialProducts =
                allProducts
                    .where(
                      (p) => p.sale > 0,
                    ) // Giả sử sản phẩm đặc biệt là sản phẩm có sale
                    .toList();
            specialProducts.sort(
              (a, b) => b.sale.compareTo(a.sale),
            ); // Sắp xếp theo sale giảm dần
            specialProducts =
                specialProducts.take(2).toList(); // Lấy 2 sản phẩm

            if (specialProducts.isEmpty) {
              return const Center(
                child: Text(
                  'Không tìm thấy sản phẩm đặc biệt nào.',
                  style: TextStyle(color: Colors.white54),
                ),
              );
            }

            // Sử dụng Column để hiển thị các sản phẩm theo chiều dọc, mỗi sản phẩm là một khối
            return Column(
              children:
                  specialProducts.map((specialProduct) {
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
