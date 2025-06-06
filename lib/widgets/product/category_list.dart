import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/product_model.dart';

class CategoryList extends StatelessWidget {
  final CollectionReference<Map<String, dynamic>> productsCollection;
  final String? selectedCategoryName;
  final ValueChanged<String?> onCategorySelected;

  const CategoryList({
    super.key,
    required this.productsCollection,
    required this.selectedCategoryName,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream:
            productsCollection
                .orderBy("name", descending: false) // Sắp xếp A-Z
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Không có danh mục',
                style: TextStyle(color: Colors.white54),
              ),
            );
          }

          List<String> displayCategories = ["Tất cả"];
          final productNamesAsCategories =
              snapshot.data!.docs
                  .map((doc) => Product.fromFirestore(doc).name)
                  .toSet()
                  .toList();
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
