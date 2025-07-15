import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Icon(Icons.menu, color: Colors.brown, size: 40),
        SvgPicture.asset(
          'assets/icons/Group1.svg',
          height: 40,
          width: 40,
          fit: BoxFit.fill,
        ),
        // const Image(
        //   image: AssetImage('assets/images/Group1.png'),
        //   width: 40,
        //   height: 40,
        // ),
        const Icon(Icons.person_outline, color: Colors.brown, size: 24),
        // CircleAvatar(
        //   backgroundImage: AssetImage(
        //     'assets/profile.jpg',
        //   ), // Đảm bảo ảnh này tồn tại
        // ),
      ],
    );
  }
}
