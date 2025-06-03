import 'package:flutter/material.dart';
// Import your login page if you need to navigate back
import 'loginpage.dart';

class SignupPage extends StatefulWidget {
  // Changed class name
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState(); // Changed state class name
}

class _SignupPageState extends State<SignupPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController(); // Added email controller
  final _passwordController = TextEditingController();

  // final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  // TODO: Add state for confirm password visibility if needed
  // bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose(); // Dispose email controller
    _passwordController.dispose();
    // _confirmPasswordController.dispose(); // Dispose confirm password controller
    super.dispose();
  }

  void _signUp() {
    final username = _usernameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;
  }

  void _navigateToLogin() {
    print("Navigate to Login clicked!");
    // Example: Check if the current route can be popped, otherwise push login
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const Loginpage(),
        ), // Assuming you have Loginpage
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Adjust as needed, consider SingleChildScrollView
      body: Stack(
        children: [
          // Background Image (reuse or change)
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  "assets/images/Login_picture.jpg",
                ), // Or a different sign-up background
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Overlay Content
          Positioned(
            // Adjust position/height if more fields are added
            bottom:
                screenSize.height * 0.05, // Adjust position slightly if needed
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20.0),
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    "Create Account", // Changed Title
                    style: textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20), // Adjusted spacing
                  TextField(
                    // Username field
                    controller: _usernameController,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      hintText: "Username", // Changed hint
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: Colors.grey[700],
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
                  const SizedBox(height: 15),
                  TextField(
                    // Email field
                    controller: _emailController,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      hintText: "Email", // Added Email field
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: Colors.grey[700],
                      ), // Email Icon
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 15,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    // Password field
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
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
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey[700],
                        ),
                        onPressed:
                            () => setState(
                              () => _isPasswordVisible = !_isPasswordVisible,
                            ),
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
                  // TODO: Add Confirm Password Field here if needed
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: _signUp, // Call sign up method
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: textTheme.labelLarge,
                    ),
                    child: const Text("Sign Up"), // Changed button text
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ", // Changed prompt text
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      GestureDetector(
                        onTap:
                            _navigateToLogin, // Call navigation method to login
                        child: Text(
                          "Log In", // Changed action text
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
