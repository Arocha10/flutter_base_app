import 'package:flutter/material.dart';

const colorSeed = Color(0xff424CB8);
const scaffoldBackgroundColor = Color.fromRGBO(248, 247, 247, 1);

class AppTheme {
  ThemeData getTheme() => ThemeData(
    useMaterial3: true,
    colorSchemeSeed: colorSeed,
    scaffoldBackgroundColor: scaffoldBackgroundColor,
    appBarTheme: const AppBarTheme(
      color: scaffoldBackgroundColor,
    ),
  );
}
