import 'package:flutter/material.dart';
import 'package:myapp/screens/loginpage.dart';
import 'package:myapp/screens/products.dart';
import 'screens/welcomepage.dart';
import 'screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/admin/add_products.dart';
import 'screens/admin/cloudinary_upload_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const MyApp());
  } catch (e) {
    print('Failed to initialize Firebase: $e');
    runApp(const FirebaseErrorApp());
  }
}

// --- Main App Widget ---

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Demo',
      debugShowCheckedModeBanner: false,
      //home: const Products(),
      //home: const Loginpage(),
      //home: const AddProductScreen(),
      //home: CloudinaryUploadScreen(),
      home: Welcomepage(),
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
