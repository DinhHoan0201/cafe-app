import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:myapp/models/product_model.dart';
import 'package:myapp/constants/firestore_paths.dart';

class Products extends StatefulWidget {
  const Products({super.key});

  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Khai báo tường minh kiểu dữ liệu cho collection reference để code rõ ràng và an toàn hơn
  late CollectionReference<Map<String, dynamic>> _productsCollection;

  @override
  void initState() {
    super.initState();
    // Khởi tạo collection reference, sử dụng withConverter để đảm bảo kiểu dữ liệu
    _productsCollection = _firestore
        .collection(FirestorePaths.topLevelCfdb)
        .doc(FirestorePaths.defaultParentInCfdb)
        .collection(FirestorePaths.productsSubCollection)
        .withConverter<Map<String, dynamic>>(
          // Đảm bảo kiểu dữ liệu đúng cho snapshots
          fromFirestore: (snapshot, _) => snapshot.data()!,
          toFirestore: (data, _) => data,
        );
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Hàm trợ giúp xây dựng widget hiển thị khi đang tải ảnh
  Widget _imageLoadingBuilder(
    BuildContext context,
    Widget child,
    ImageChunkEvent? loadingProgress,
  ) {
    if (loadingProgress == null) return child; // Ảnh đã tải xong
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
        value:
            loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null, // Hiển thị tiến trình nếu có
      ),
    );
  }

  // Hàm trợ giúp chính để xây dựng widget ảnh sản phẩm
  Widget _buildProductImageWidget(String imageUrl) {
    // Định nghĩa kích thước ảnh và widget placeholder một lần
    const double imageHeight = 120;
    const double imageWidth = 160;

    final Widget placeholder = Image.asset(
      'assets/images/coffee_placeholder.png', // Đảm bảo đường dẫn này đúng và ảnh có trong pubspec.yaml
      height: imageHeight,
      width: imageWidth,
      fit: BoxFit.cover,
    );

    if (imageUrl.isEmpty) {
      return placeholder; // Nếu không có URL, hiển thị placeholder
    }

    // Hàm xử lý lỗi chung cho Image.network
    Widget imageNetworkErrorBuilder(
      BuildContext context,
      Object error,
      StackTrace? stackTrace,
      String logUrl,
    ) {
      print('Lỗi tải ảnh từ $logUrl: $error');
      return placeholder; // Hiển thị placeholder khi có lỗi
    }

    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      // Trường hợp URL là một liên kết trực tiếp (ví dụ: từ Cloudinary)
      return Image.network(
        imageUrl,
        height: imageHeight,
        width: imageWidth,
        fit: BoxFit.cover,
        loadingBuilder: _imageLoadingBuilder,
        errorBuilder:
            (context, error, stackTrace) =>
                imageNetworkErrorBuilder(context, error, stackTrace, imageUrl),
      );
    } else if (imageUrl.startsWith('products/')) {
      // Trường hợp URL là đường dẫn tương đối trên Firebase Storage
      return FutureBuilder<String>(
        future:
            firebase_storage.FirebaseStorage.instance
                .ref(imageUrl)
                .getDownloadURL(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Đang lấy URL tải xuống
            return Container(
              height: imageHeight,
              width: imageWidth,
              color: Colors.grey[850], // Màu nền tạm thời khi tải
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.orangeAccent,
                  ),
                ),
              ),
            );
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            print('Lỗi lấy URL tải xuống cho $imageUrl: ${snapshot.error}');
            return placeholder; // Hiển thị placeholder nếu có lỗi
          }
          // Khi đã có URL, sử dụng Image.network để hiển thị
          return Image.network(
            snapshot.data!,
            height: imageHeight,
            width: imageWidth,
            fit: BoxFit.cover,
            loadingBuilder: _imageLoadingBuilder,
            errorBuilder:
                (context, error, stackTrace) => imageNetworkErrorBuilder(
                  context,
                  error,
                  stackTrace,
                  snapshot.data!,
                ),
          );
        },
      );
    }
    // Trường hợp định dạng URL không nhận dạng được, dùng placeholder
    print(
      'Định dạng URL ảnh không được nhận dạng: $imageUrl. Sử dụng placeholder.',
    );
    return placeholder;
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
                  // Kiểu stream giờ đây rõ ràng hơn nhờ CollectionReference đã được định kiểu
                  stream:
                      _productsCollection
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
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
                        // Gọi hàm trợ giúp để lấy widget ảnh
                        final Widget productImageWidget =
                            _buildProductImageWidget(product.imageUrl);

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
                                    productImageWidget, // Sử dụng widget ảnh đã được xây dựng
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
                                          ? "Available"
                                          : "Unavailable",
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
