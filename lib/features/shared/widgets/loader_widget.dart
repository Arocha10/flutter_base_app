import 'package:flutter/material.dart';

// GIF-based loader. Place your loading GIF at assets/loaders/loading.gif
// or swap for a SpinKit / CircularProgressIndicator.
class CustomLoader extends StatelessWidget {
  final double size;

  const CustomLoader({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Image.asset(
        'assets/loaders/loading.gif',
        scale: size,
      ),
    );
  }
}
