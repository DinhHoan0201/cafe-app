import 'package:flutter/material.dart';
import 'package:myapp/features/product/model/product_model.dart';
import 'package:myapp/features/product/widgets/product_list_widget.dart';
import 'package:provider/provider.dart'; // Thêm Provider
import 'package:myapp/features/auth/view/login_screen.dart';
import 'package:myapp/features/product/views/products_screen.dart';
import 'features/home/welcomepage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:myapp/features/product/views/add_products_screen.dart'; // Giữ lại nếu cần ở đâu đó
import 'features/admin/view/cloudinary_upload_screen.dart';
import 'package:myapp/features/product/views/product_list_screen.dart'; // Import màn hình list
import 'package:myapp/features/product/controller/product_controller.dart'; // Import controller
import 'package:myapp/features/product/views/edit_product_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(
      MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => ProductController())],
        child: const MyApp(),
      ),
    );
  } catch (e) {
    print('Failed to initialize Firebase: $e');
    runApp(const FirebaseErrorApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Demo',
      debugShowCheckedModeBanner: false,
      home: const Products(),
      //home: const Loginpage(),
      //home: const AddProductScreen(),
      //home: CloudinaryUploadScreen(),
      //home: const Welcomepage(),
      //home: const ProductListScreen(),
      // Đặt ProductListScreen làm màn hình chính
    );
  }
}

class FirebaseErrorApp extends StatelessWidget {
  const FirebaseErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Error initializing Firebase. Check logs.')),
      ),
    );
  }
}
