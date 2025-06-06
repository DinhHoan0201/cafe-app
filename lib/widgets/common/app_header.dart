import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Icon(Icons.grid_view_rounded, color: Colors.white),
        CircleAvatar(
          backgroundImage: AssetImage(
            'assets/profile.jpg',
          ), // Đảm bảo ảnh này tồn tại
        ),
      ],
    );
  }
}
