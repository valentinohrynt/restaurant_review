import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_review/data/api/api_service.dart';
import 'package:restaurant_review/providers/detail/customer_review_list_provider.dart';
import 'package:restaurant_review/providers/detail/favorite_list_provider.dart';
import 'package:restaurant_review/providers/detail/restaurant_detail_provider.dart';
import 'package:restaurant_review/providers/home/restaurant_list_provider.dart';
import 'package:restaurant_review/providers/main/index_nav_provider.dart';
import 'package:restaurant_review/providers/settings/notification/notification_provider.dart';
import 'package:restaurant_review/providers/settings/theme_provider.dart';
import 'package:restaurant_review/providers/home/search_provider.dart';
import 'package:restaurant_review/screens/detail/detail_screen.dart';
import 'package:restaurant_review/screens/main/main_screen.dart';
import 'package:restaurant_review/static/navigation_route.dart';
import 'package:restaurant_review/style/theme/restaurant_theme.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => IndexNavProvider()),
      ChangeNotifierProvider(create: (context) => FavoriteListProvider()),
      Provider(create: (context) => ApiService()),
      ChangeNotifierProvider(
        create: (context) => RestaurantListProvider(context.read<ApiService>()),
      ),
      ChangeNotifierProvider(
        create: (context) =>
            RestaurantDetailProvider(context.read<ApiService>()),
      ),
      ChangeNotifierProvider(
        create: (context) =>
            CustomerReviewListProvider(context.read<ApiService>()),
      ),
      ChangeNotifierProvider(create: (context) => NotificationProvider()),
      ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ChangeNotifierProvider(create: (context) => SearchProvider()),
    ],
    child: const MainApp(),
  ));
  FlutterNativeSplash.remove();
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return Consumer<NotificationProvider>(
          builder: (context, notificationProvider, child) {
        return MaterialApp(
          title: 'Restaurant Review',
          theme: RestaurantTheme.lightTheme,
          darkTheme: RestaurantTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          initialRoute: NavigationRoute.mainRoute.name,
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/':
                return PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const MainScreen(),
                  transitionsBuilder: (_, animation, __, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                );

              case '/detail':
                final restaurantId = settings.arguments as String;
                return PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      DetailScreen(restaurantId: restaurantId),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOutCubic;

                    var tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));

                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 500),
                  reverseTransitionDuration: const Duration(milliseconds: 500),
                );
            }
            return null;
          },
        );
      });
    });
  }
}
