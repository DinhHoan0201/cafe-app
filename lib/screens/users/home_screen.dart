import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Để có thể đăng xuất
import 'loginpage.dart'; // Để quay lại màn hình login sau khi đăng xuất
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const Loginpage()),
      (Route<dynamic> route) => false,
    );
  }

  Future<DocumentSnapshot> _fetchSpecificUserData(String userId) async {
    const String parentDocumentId = 'fcbeYHPwNXqGea9636Su';
    const String topLevelCollectionName = 'cfdb';
    const String subCollectionName = 'users';

    return FirebaseFirestore.instance
        .collection(topLevelCollectionName)
        .doc(parentDocumentId)
        .collection(subCollectionName)
        .doc(userId)
        .get();
  }

  // phân từng bậc
  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    const String specificUserIdToFetch = '01';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome! You are logged in as:'),
            if (user != null) ...[
              
              const SizedBox(height: 10),
              Text('Email: ${user.email}'),
            ],
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            Text(
              'Fetching data for user ID: $specificUserIdToFetch from "users" collection',
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            FutureBuilder<DocumentSnapshot>(
              future: _fetchSpecificUserData(specificUserIdToFetch),
              builder: (
                BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot,
              ) {
                if (snapshot.hasError) {
                  return Text("Something went wrong: ${snapshot.error}");
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasData && !snapshot.data!.exists) {
                  return Text(
                    "Document with ID '$specificUserIdToFetch' does not exist.",
                  );
                }

                if (snapshot.hasData && snapshot.data!.exists) {
                  Map<String, dynamic> data =
                      snapshot.data!.data() as Map<String, dynamic>;

                  return Column(
                    children: [
                      Text('Name: ${data['Name'] ?? 'N/A'}'),
                      Text('Email (from DB): ${data['email'] ?? 'N/A'}'),
                      // KHÔNG hiển thị: Text('Password: ${data['password']}'),
                    ],
                  );
                }
                return const Text("Loading data...");
              },
            ),
          ],
        ),
      ),
    );
  }
}
