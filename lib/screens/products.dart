import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/product_model.dart';
import 'package:myapp/widgets/common/app_header.dart';
import 'package:myapp/widgets/product/product_image_widget.dart';
import 'dart:developer' as developer; // Import để ghi log
import 'package:myapp/widgets/common/search_bar_widget.dart'; // Import search bar widget
import 'package:myapp/widgets/product/category_list.dart'; // Import category list widget
import 'package:myapp/widgets/product/product_list.dart'; // Import product list widget
import 'package:myapp/widgets/product/special_for_you_section.dart'; // Import special section widget
import 'package:myapp/constants/firestore_paths.dart';

class Products extends StatefulWidget {
  const Products({super.key});
  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late CollectionReference<Map<String, dynamic>> _productsCollection;
  String? _selectedCategoryName;
  String _searchQuery = '';
  @override
  void initState() {
    super.initState();
    _productsCollection = _firestore
        .collection(FirestorePaths.topLevelCfdb)
        .doc(FirestorePaths.defaultParentInCfdb)
        .collection(FirestorePaths.productsSubCollection)
        .withConverter<Map<String, dynamic>>(
          fromFirestore: (snapshot, _) => snapshot.data()!,
          toFirestore: (data, _) => data,
        );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _getProductListStream() {
    Query<Map<String, dynamic>> query = _productsCollection;
    if (_selectedCategoryName != null) {
      query = query.where('name', isEqualTo: _selectedCategoryName);
    }
    return query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
                Text(
                  "Find the best\ncoffee for you",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                SearchBarWidget(
                  onSearchChanged: (query) {
                    setState(() {
                      _searchQuery = query;
                    });
                  },
                ),
                const SizedBox(height: 20),
                //
                CategoryList(
                  productsCollection: _productsCollection,
                  selectedCategoryName: _selectedCategoryName,
                  onCategorySelected: (categoryName) {
                    setState(() {
                      _selectedCategoryName = categoryName;
                    });
                  },
                ),
                //
                const SizedBox(height: 20),
                ProductList(
                  productStream: _getProductListStream(),
                  searchQuery: _searchQuery,
                ),
                const SizedBox(height: 10),

                SpecialForYouSection(productsCollection: _productsCollection),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black.withOpacity(0.7),
        selectedItemColor: Colors.orange,
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: Colors.white,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ''),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: '',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
        ],
      ),
    );
  }
}
