import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_review/provider/main/index_nav_provider.dart';
import 'package:restaurant_review/screen/favorite/favorite_screen.dart';
import 'package:restaurant_review/screen/home/home_screen.dart';
import 'package:restaurant_review/screen/settings/settings_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<IndexNavProvider>(
        builder: (context, value, child) {
          return switch (value.currentIndex) {
            0 => const HomeScreen(),
            1 => const FavoriteScreen(),
            _ => const SettingsScreen(),
          };
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: context.watch<IndexNavProvider>().currentIndex,
        onTap: (index) {
          context.read<IndexNavProvider>().currentIndex = index;
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
            tooltip: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.favorite,
              color: Colors.red,
            ),
            label: "Favorite",
            tooltip: "Favorite",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
            tooltip: "Settings",
          ),
        ],
      ),
    );
  }
}
