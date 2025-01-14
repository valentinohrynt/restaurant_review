import 'package:flutter/material.dart';
import 'package:restaurant_review/style/colors/restaurant_colors.dart';
import 'package:restaurant_review/style/typography/restaurant_text_styles.dart';

class RestaurantTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorSchemeSeed: RestaurantColors.teal.color,
      brightness: Brightness.light,
      textTheme: _textTheme.apply(
        bodyColor: Colors.black,
        displayColor: Colors.black,
      ),
      useMaterial3: true,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      colorSchemeSeed: RestaurantColors.teal.color,
      brightness: Brightness.dark,
      textTheme: _textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      useMaterial3: true,
    );
  }

  static TextTheme get _textTheme {
    return TextTheme(
      displayLarge: RestaurantTextStyles.displayLarge,
      displayMedium: RestaurantTextStyles.displayMedium,
      displaySmall: RestaurantTextStyles.displaySmall,
      headlineLarge: RestaurantTextStyles.headlineLarge,
      headlineMedium: RestaurantTextStyles.headlineMedium,
      headlineSmall: RestaurantTextStyles.headlineSmall,
      titleLarge: RestaurantTextStyles.titleLarge,
      titleMedium: RestaurantTextStyles.titleMedium,
      titleSmall: RestaurantTextStyles.titleSmall,
      bodyLarge: RestaurantTextStyles.bodyLargeBold,
      bodyMedium: RestaurantTextStyles.bodyLargeMedium,
      bodySmall: RestaurantTextStyles.bodyLargeRegular,
      labelLarge: RestaurantTextStyles.labelLarge,
      labelMedium: RestaurantTextStyles.labelMedium,
      labelSmall: RestaurantTextStyles.labelSmall,
    );
  }
}
