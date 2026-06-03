import 'package:flutter/material.dart';

// Used with top_snackbar_flutter:
//   showTopSnackBar(Overlay.of(context), CustomSnackBarMessage(message: '...'));
class CustomSnackBarMessage extends StatelessWidget {
  final String message;

  const CustomSnackBarMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width - 40,
      ),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}
