import 'package:flutter/material.dart';
import 'screens/invitation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Parse guest name from URL query parameters (Flutter Web)
    // For mobile, defaults to a standard greeting
    String guestName = _getGuestName();

    return MaterialApp(
      title: 'Waleema Invitation – Falahul Ali & Fathima Ihshana',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Outfit',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7B9EC1),
          brightness: Brightness.light,
        ),
      ),
      home: Invitation(guestName: guestName),
    );
  }

  String _getGuestName() {
    // Flutter Web: read from URL query string ?name=Ahmad
    try {
      final uri = Uri.base;
      final name = uri.queryParameters['name'];
      if (name != null && name.trim().isNotEmpty) {
        return name.trim();
      }
    } catch (_) {}
    return '';
  }
}
