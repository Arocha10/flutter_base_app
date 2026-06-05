import 'package:flutter/material.dart';

class StyledText extends StatelessWidget {
  const StyledText(this.text, this.color, this.fontSize, {super.key});

  final String text;
  final Color? color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontFamily: 'AvenirRegular',
        letterSpacing: -0.6,
      ),
    );
  }
}
