import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData themeData = ThemeData(
    useMaterial3: false,
    brightness: Brightness.light,
    fontFamily: "Open_Sans",
    appBarTheme: const AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: Colors.transparent,
    ),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: AppColors.red,
      accentColor: AppColors.blue,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.0),
          topRight: Radius.circular(12.0),
        ),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Color(0xff1D1B23)),
      displayMedium: TextStyle(color: Color(0xff1D1B23)),
      displaySmall: TextStyle(color: Color(0xff1D1B23)),
      headlineLarge: TextStyle(color: Color(0xff1D1B23)),
      headlineMedium: TextStyle(color: Color(0xff1D1B23)),
      headlineSmall: TextStyle(color: Color(0xff1D1B23)),
      labelLarge: TextStyle(color: Colors.grey),
      labelMedium: TextStyle(color: Colors.grey),
      labelSmall: TextStyle(color: Colors.grey),
    ),
  );

  static final light = themeData.copyWith();
  static final dark = themeData.copyWith();
}
