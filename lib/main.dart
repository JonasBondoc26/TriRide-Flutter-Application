import 'package:flutter/material.dart';
import 'screens/login.dart';
import 'screens/main_screen.dart';
import 'services/auth_service.dart';

void main() {
  // Initialize demo account
  AuthService.register(
    email: 'demo@triride.com',
    password: 'demo123',
    name: 'Demo User',
    phone: '+63 912 345 6789',
  ).then((_) {
    // Logout after creating demo account so user can login
    AuthService.logout();
  });
  
  runApp(const TriRideApp());
}

class TriRideApp extends StatelessWidget {
  const TriRideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TriRide',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.cyan, 
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3D56), 
          secondary: const Color(0xFF36A79F),  
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: AuthService.isLoggedIn ? const MainScreen() : const LoginScreen(),
    );
  }
}