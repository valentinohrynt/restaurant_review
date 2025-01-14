import 'package:flutter/material.dart';

enum RestaurantColors {
  teal("Teal", Colors.teal);

  const RestaurantColors(this.name, this.color);

  final String name;
  final Color color;
}
