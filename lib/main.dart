import 'package:ali_wed_invitation/screens/splash_screen.dart';
import 'package:flutter/material.dart';

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
      home: SplashScreen(guestName: guestName),
    );
  }

  String _getGuestName() {
    // Flutter Web: read from URL query string ?name=...
    try {
      final uri = Uri.base;
      final raw = uri.queryParameters['name'];
      if (raw != null && raw.trim().isNotEmpty) {
        return _decodeGuestSlug(raw.trim());
      }
    } catch (_) {}
    return '';
  }

  /// Converts short URL slugs into full display names.
  ///
  /// Supported formats:
  ///   Mr.John          → Mr. John
  ///   Mrs.John         → Mrs. John
  ///   Mr.Mrs.John      → Mr. & Mrs. John
  ///   Mr.Mrs.John      → Mr. & Mrs. John
  ///   John-family      → Mr. & Mrs. John & Family
  ///
  /// Falls back to the raw value for anything else (e.g. already-encoded names).
  String _decodeGuestSlug(String slug) {
    // Pattern: <Name>-family  →  Mr. & Mrs. <Name> & Family
    if (slug.toLowerCase().endsWith('-family')) {
      final baseName = slug.substring(0, slug.length - '-family'.length);
      return 'Mr. & Mrs. $baseName & Family';
    }

    // Pattern: <Name>-couple  →  Mr. & Mrs. <Name>
    if (slug.toLowerCase().endsWith('-couple')) {
      final baseName = slug.substring(0, slug.length - '-couple'.length);
      return 'Mr. & Mrs. $baseName';
    }

    // Pattern: Mr.Mrs.<Name>  →  Mr. & Mrs. <Name>
    if (slug.startsWith('Mr.Mrs.')) {
      final name = slug.substring('Mr.Mrs.'.length);
      return 'Mr. & Mrs. $name';
    }

    // Pattern: Mr.<Name>  →  Mr. <Name>
    if (slug.startsWith('Mr.')) {
      final name = slug.substring('Mr.'.length);
      return 'Mr. $name';
    }

    // Pattern: Mrs.<Name>  →  Mrs. <Name>
    if (slug.startsWith('Mrs.')) {
      final name = slug.substring('Mrs.'.length);
      return 'Mrs. $name';
    }

    // Pattern: <Name>  →  Mr. <Name>  (plain name, no prefix or suffix)
    return 'Mr. $slug';
  }
}
