import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/cart_provider.dart';
import 'screens/cart_screen.dart';
import 'screens/favorite_provider.dart';
import 'screens/favorites_screen.dart';
import 'screens/OnboardingScreen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wassel',
      home: const SplashScreen(),
      routes: {
        '/cart': (context) => const CartScreen(),
        '/favorites': (context) => const FavoriteScreen(),
      },
    );
  }
}
