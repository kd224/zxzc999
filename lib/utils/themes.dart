import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const bodyText1 = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w400,
  letterSpacing: 0.15,
);

const bodyText2 = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w400,
  letterSpacing: 0.15,
);

final lightTheme = ThemeData(
  fontFamily: 'OpenSans',
  //brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.white,
  backgroundColor: Colors.grey[100],
  canvasColor: Colors.white,
  colorScheme: const ColorScheme.light().copyWith(
    primary: const Color(0xFF09C08E),
    secondary: const Color(0xFF09C08E),
    brightness: Brightness.light,
  ),
  shadowColor: Colors.grey[200],
  appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.white,
      titleTextStyle: TextStyle(
        color: Colors.grey[800],
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
      iconTheme: IconThemeData(color: Colors.grey[800], size: 28),
      actionsIconTheme: IconThemeData(color: Colors.grey[500], size: 28),
      toolbarTextStyle: const TextStyle(
        fontFamily: 'OpenSans',
      )),
  textTheme: TextTheme(
    bodyText1: bodyText1.copyWith(color: Colors.grey[800]),
    bodyText2: bodyText2.copyWith(color: Colors.grey[800]),
  ),
  //dividerTheme: DividerThemeData(color: Colors.grey[800]),
);

final darkTheme = ThemeData();

final blackTheme = ThemeData(
  fontFamily: 'OpenSans',
  scaffoldBackgroundColor: Colors.black,
  backgroundColor: Colors.grey[900],
  canvasColor: const Color(0xFF111111),
  colorScheme: const ColorScheme.light().copyWith(
    primary: const Color(0xFF09C08E),
    secondary: const Color(0xFF09C08E),
    brightness: Brightness.dark,
  ),
  appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.black,
      titleTextStyle: TextStyle(
        color: Colors.grey[400],
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
      iconTheme: IconThemeData(color: Colors.grey[400], size: 28),
      actionsIconTheme: IconThemeData(color: Colors.grey[400], size: 28),
      toolbarTextStyle: const TextStyle(
        fontFamily: 'OpenSans',
      )),
  textTheme: TextTheme(
    bodyText1: bodyText1.copyWith(color: Colors.grey[300]),
    bodyText2: bodyText2,
  ),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: Color(0xFF323232),
    contentTextStyle: TextStyle(
      color: Colors.white,
    ),
  ),
  dividerTheme: DividerThemeData(color: Colors.grey[800]),
  iconTheme: IconThemeData(color: Colors.grey[400]),
);
