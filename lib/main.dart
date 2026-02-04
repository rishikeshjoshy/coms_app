import 'package:coms_app/screens/admin_home.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maiee Silks',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
      useMaterial3: true,
      // Maiee Color Palette
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF800020),
          primary: const Color(0xFF800020),
          secondary: const Color(0xFFD4AF37),
          surface: Colors.grey[50],
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),
      home : const AdminHomeScreen(),
    );
  }
}
