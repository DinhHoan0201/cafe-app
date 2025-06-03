import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'signup_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/constants/firestore_paths.dart';
import 'package:myapp/services/firestore_service.dart';
import 'home_screen.dart';
import 'signup_page.dart';

class Loginpage extends StatefulWidget {
  // Changed to StatefulWidget
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  final FirestoreService _firestoreService = FirestoreService();
  void _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both username and password.'),
        ),
      );
      return;
    }

    try {
      DocumentSnapshot userDoc = await _firestoreService
          .getDocumentFromSubCollection(
            topLevelCollection: FirestorePaths.topLevelCfdb,
            parentDocId: FirestorePaths.defaultParentInCfdb,
            subCollection: FirestorePaths.usersSubCollection,
            docIdInSubCollection: '01',
          );

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;

        final storedUsername = userData['email'];
        final storedPassword = userData['password'];

        if (username == storedUsername && password == storedPassword) {
          print('Login successful');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid username or password.')),
          );
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not found.')));
      }
    } catch (e) {
      print('Error during login: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed. Please try again.')),
      );
    }
  }

  void _navigateToSignUp() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignupPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Access theme data for consistent styling
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final Size screenSize = MediaQuery.of(context).size; // Get screen size

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Background Image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  "assets/images/Login_picture.jpg",
                ), // Ensure path is correct
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Overlay Content - Consider SingleChildScrollView if keyboard covers fields
          Positioned(
            // Adjust positioning based on screen size or use Align/Column
            bottom:
                screenSize.height * 0.1, // Position relative to screen height
            left: 0,
            right: 0,
            child: Container(
              // Adjust height dynamically or use intrinsic height widgets
              padding: const EdgeInsets.all(
                20.0,
              ), // Use padding instead of fixed height
              margin: const EdgeInsets.symmetric(
                horizontal: 20.0,
              ), // Add horizontal margin
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5), // Slightly darker overlay
                borderRadius: BorderRadius.circular(15), // Rounded corners
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Take minimum space needed
                children: [
                  const SizedBox(height: 20),
                  Text(
                    "Welcome Back",
                    style: textTheme.headlineMedium?.copyWith(
                      // Use theme text style
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30), // Increased spacing
                  TextField(
                    controller: _usernameController, // Use controller
                    style: const TextStyle(
                      color: Colors.black,
                    ), // Text color inside field
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(
                        0.9,
                      ), // Slightly transparent white
                      hintText: "Username or Email", // Use hintText
                      hintStyle: TextStyle(
                        // Style for hint text
                        color: Colors.grey[600],
                      ),
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: Colors.grey[700],
                      ), // Add icon
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          12,
                        ), // Adjusted radius
                        borderSide: BorderSide.none, // Remove border line
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 15,
                      ), // Adjust padding
                    ),
                    keyboardType:
                        TextInputType.emailAddress, // Suggest email keyboard
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _passwordController, // Use controller
                    obscureText:
                        !_isPasswordVisible, // Use state for visibility
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      hintText: "Password",
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: Colors.grey[700],
                      ),
                      suffixIcon: IconButton(
                        // Add visibility toggle
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey[700],
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25), // Increased spacing
                  ElevatedButton(
                    onPressed: _login, // Call login method
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          colorScheme.primary, // Use theme primary color
                      foregroundColor:
                          colorScheme.onPrimary, // Use theme onPrimary color
                      minimumSize: const Size(
                        double.infinity,
                        50,
                      ), // Make button stretch and taller
                      shape: RoundedRectangleBorder(
                        // Rounded corners for button
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: textTheme.labelLarge, // Use theme text style
                    ),
                    child: const Text("Login"),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ", // Corrected grammar
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ), // Use theme style
                      ),
                      GestureDetector(
                        onTap: _navigateToSignUp, // Call navigation method
                        child: Text(
                          "Sign Up", // Changed text
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary, // Use theme color
                            fontWeight: FontWeight.bold, // Make it bold
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ), // Add some bottom padding inside the container
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
