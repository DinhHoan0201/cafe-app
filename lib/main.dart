import 'package:flutter/material.dart';
import 'package:myapp/screens/loginpage.dart';
import 'package:myapp/screens/products.dart';
// Import your actual starting screen
import 'screens/welcomepage.dart';
// Đảm bảo import đúng file
// import 'screens/signup_page.dart';
import 'screens/home_screen.dart';
import 'screens/products.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'firebase_options.dart'; // Import the *correctly generated* options
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
      home: const Products(),
      //home: const Loginpage(),
      //home: const AddProductScreen(),
      //home: CloudinaryUploadScreen(),
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
