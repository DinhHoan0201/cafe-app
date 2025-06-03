import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:flutter/rendering.dart'; // Unused import

class Welcomepage extends StatelessWidget {
  // Add const constructor for StatelessWidget
  const Welcomepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          // Add const
          image: DecorationImage(
            image: AssetImage(
              "assets/images/background.jpg",
            ), // Ensure this path is also correct and declared
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SvgPicture.asset(
            "assets/icons/An.svg", // Double-check this path!
            width: 100,
            height: 100,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
