import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String description;
  final String imageUrl;
  final Timestamp timestamp;
  final bool status;
  final double sale;
  final String type;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.timestamp,
    required this.status,
    required this.sale,
    required this.type,
  });

  factory Product.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Product(
      id: data['productId'] ?? doc.id,
      name: data['name'] ?? 'Unnamed Product',
      price: (data['price'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      status: data['status'] ?? true,
      imageUrl: data['imageUrl'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      sale: (data['sale'] ?? 0).toDouble(),
      type: data['type'] ?? '',
    );
  }
}
