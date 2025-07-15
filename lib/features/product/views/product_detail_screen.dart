import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/features/product/model/product_model.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: Center(child: Text(product.name)),
    );
  }
}
