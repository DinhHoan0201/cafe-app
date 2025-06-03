import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:myapp/constants/firestore_paths.dart'; // Assuming this file exists and has correct paths

// Define a Product model (you can move this to a separate file, e.g., models/product_model.dart)

class Products extends StatefulWidget {
  const Products({super.key});

  @override
  State<Products> createState() => _ProductsState();
}

class Product {
  final String id;
  final String name;
  final double price;
  final String description;
  final String imageUrl; // Can be a relative path or an identifier
  final Timestamp timestamp;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.timestamp,
  });

  factory Product.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Product(
      id: data['productId'] ?? doc.id,
      name: data['name'] ?? 'Unnamed Product',
      price: (data['price'] ?? 0.0).toDouble(),
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }
}

class _ProductsState extends State<Products> {
  final _formKey = GlobalKey<FormState>();
  // Define your Firestore instance and collection reference
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late CollectionReference _productsCollection;

  @override
  void initState() {
    super.initState();
    // Initialize your products collection reference
    // Assuming FirestorePaths are defined correctly
    _productsCollection = _firestore
        .collection(FirestorePaths.topLevelCfdb)
        .doc(FirestorePaths.defaultParentInCfdb)
        .collection(FirestorePaths.productsSubCollection);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.grid_view_rounded, color: Colors.white),
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/profile.jpg'),
                  ),
                ],
              ),
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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Colors.white54),
                    hintText: 'Find your coffee..',
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    "Cappuccino",
                    style: TextStyle(color: Colors.orangeAccent),
                  ),
                  SizedBox(width: 16),
                  Text("Espresso", style: TextStyle(color: Colors.white)),
                  SizedBox(width: 16),
                  Text("Latte", style: TextStyle(color: Colors.white)),
                  SizedBox(width: 16),
                  Text("Mocha", style: TextStyle(color: Colors.white)),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                height: 250,
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream:
                      _productsCollection
                              .orderBy('timestamp', descending: true)
                              .snapshots()
                          as Stream<QuerySnapshot<Map<String, dynamic>>>?,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Lỗi: ${snapshot.error}',
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Colors.orangeAccent,
                        ),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          'Không tìm thấy sản phẩm nào.',
                          style: TextStyle(color: Colors.white54),
                        ),
                      );
                    }

                    final productDocs = snapshot.data!.docs;

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: productDocs.length,
                      itemBuilder: (context, index) {
                        final productData = productDocs[index];
                        final product = Product.fromFirestore(
                          productData,
                        ); // Chuyển đổi dữ liệu Firestore thành đối tượng Product

                        Widget productImageWidget;
                        final String imageUrlValue = product.imageUrl;

                        if (imageUrlValue.isNotEmpty) {
                          // Define placeholder widget once to avoid repetition
                          Widget placeholder = Image.asset(
                            'assets/images/coffee_placeholder.png', // Ensure this path is correct and asset is in pubspec.yaml
                            height: 120,
                            width: 160,
                            fit: BoxFit.cover,
                          );

                          if (imageUrlValue.startsWith('http://') ||
                              imageUrlValue.startsWith('https://')) {
                            // Đây là một URL trực tuyến
                            productImageWidget = Image.network(
                              imageUrlValue,
                              height: 120,
                              width: 160,
                              fit: BoxFit.cover,
                              loadingBuilder: (
                                BuildContext context,
                                Widget child,
                                ImageChunkEvent? loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.orangeAccent,
                                    ),
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                // Lỗi khi tải ảnh từ network, hiển thị ảnh placeholder
                                print('Error loading network image: $error');
                                return placeholder;
                              },
                            );
                          } else if (imageUrlValue.startsWith('products/')) {
                            // Đây là đường dẫn Firebase Storage
                            productImageWidget = FutureBuilder<String>(
                              future:
                                  firebase_storage.FirebaseStorage.instance
                                      .ref(imageUrlValue)
                                      .getDownloadURL(),
                              builder: (context, urlSnapshot) {
                                if (urlSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Container(
                                    height: 120,
                                    width: 160,
                                    color: Colors.grey[850],
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.orangeAccent,
                                            ),
                                      ),
                                    ),
                                  );
                                }
                                if (urlSnapshot.hasError ||
                                    !urlSnapshot.hasData ||
                                    urlSnapshot.data!.isEmpty) {
                                  print(
                                    'Error getting download URL from Firebase Storage: ${urlSnapshot.error}',
                                  );
                                  return placeholder;
                                }
                                return Image.network(
                                  urlSnapshot.data!,
                                  height: 120,
                                  width: 160,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (
                                    BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress,
                                  ) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.orangeAccent,
                                            ),
                                        value:
                                            loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    print(
                                      'Error loading network image from Firebase Storage URL: $error',
                                    );
                                    return placeholder;
                                  },
                                );
                              },
                            );
                          } else {
                            productImageWidget = placeholder;
                          }
                        } else {
                          // imageUrl trống
                          productImageWidget = Image.asset(
                            'assets/images/coffee_placeholder.png', // Ensure this path is correct
                            height: 120,
                            width: 160,
                            fit: BoxFit.cover,
                          );
                        }

                        return Container(
                          width: 160,
                          margin: EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                                child:
                                    productImageWidget, // Sử dụng widget ảnh đã xác định
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name, // Hiển thị tên sản phẩm
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      product.description.isNotEmpty
                                          ? product.description
                                          : "Không có mô tả", // Hiển thị mô tả
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                      ),
                                      maxLines: 2, // Cho phép 2 dòng mô tả
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "\$${product.price.toStringAsFixed(2)}", // Hiển thị giá
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        CircleAvatar(
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
              ),
              const SizedBox(height: 20),
              Text(
                "Special for you",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 80,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      "assets/cappuccino1.png",
                      height: 60,
                      width: 60,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "5 Coffee Beans For You Must Try !",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.white,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}
