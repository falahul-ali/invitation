// ignore_for_file: deprecated_member_use

import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class Wedded extends StatefulWidget {
  const Wedded({super.key});

  @override
  State<Wedded> createState() => _WeddedState();
}

class _WeddedState extends State<Wedded>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _fadeController;
  late AnimationController _lanternController;
  late AnimationController _shimmerController;
  late AnimationController _petalController;

  final List<_Petal> _petals = [];

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Main entrance fade animations
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Lantern swaying animation
    _lanternController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // Shimmer gold border animation
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Floating petals animation
    _petalController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )
      ..addListener(_updatePetals)
      ..repeat();
    _initPetals();

    // Trigger entrance animation
    _fadeController.forward();

    // Auto-start music (with silent fallback if blocked by browser autoplay policy)
    _initAudio();
  }

  void _initAudio() async {
    try {
      // Elegant local wedding background nasheed
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setSource(AssetSource('audio/naseed.mp3'));
      await _audioPlayer.resume();
      setState(() {
        _isPlaying = true;
      });
    } catch (e) {
      debugPrint("Audio init error: $e");
    }
  }

  void _togglePlay() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.resume();
      }
      setState(() {
        _isPlaying = !_isPlaying;
      });
    } catch (e) {
      debugPrint("Audio play error: $e");
    }
  }

  void _initPetals() {
    final rng = math.Random();
    for (int i = 0; i < 22; i++) {
      _petals.add(_Petal(
        x: rng.nextDouble(),
        y: rng.nextDouble() * 2 - 1.0,
        size: rng.nextDouble() * 11 + 5,
        speed: rng.nextDouble() * 0.018 + 0.008,
        angle: rng.nextDouble() * math.pi * 2,
        wobble: rng.nextDouble() * 0.008 + 0.003,
      ));
    }
  }

  void _updatePetals() {
    final rng = math.Random();
    for (final p in _petals) {
      p.y += p.speed * 0.1;
      p.angle += 0.012;
      p.x += math.sin(p.angle * 3) * p.wobble;
      if (p.y > 1.2) {
        p.y = -0.2;
        p.x = rng.nextDouble();
      }
    }
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pause audio when the tab/page is hidden or the browser is closed.
    // Resume when the user comes back to the page.
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused) {
      if (_isPlaying) {
        _audioPlayer.pause();
        // Note: we intentionally don't flip _isPlaying here so that
        // returning to the page can resume automatically below.
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_isPlaying) {
        _audioPlayer.resume();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _fadeController.dispose();
    _lanternController.dispose();
    _shimmerController.dispose();
    _petalController.dispose();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  // Future<void> _launchMap() async {
  //   const String query = "Ilma Reception Hall Mawanella";
  //   final Uri googleMapsUrl = Uri.parse(
  //       "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}");
  //   if (await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication)) {
  //     // Opened successfully
  //   } else {
  //     throw 'Could not launch maps';
  //   }
  // }

  // Future<void> _launchWhatsApp() async {
  //   const String phone = "94772960134"; // Sri Lanka country code + number
  //   const String message =
  //       "بَارَكَ اللَّهُ لَكُمَا وَبَارَكَ عَلَيْكُمَا وَجَمَعَ بَيْنَكُمَا فِي خَيْرٍ\n\n"
  //       "\"May Allah bless both of you, shower His blessings upon you, and unite you in goodness.\"\n\n"
  //       "Congratulations on your Waleema, Falahul Ali & Fathima Ihshana! May your marriage be a source of joy, mercy, and endless barakah. Ameen. 🤍✨";
  //   final Uri whatsappUrl =
  //       Uri.parse("https://wa.me/$phone?text=${Uri.encodeComponent(message)}");
  //   if (await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication)) {
  //     // Opened successfully
  //   } else {
  //     throw 'Could not launch WhatsApp';
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 800;
    // Scale factor: 1.0 at 800px tall, shrinks on shorter screens, caps on tall ones
    final double s = (size.height / 500).clamp(0.55, 1.15);

    return GestureDetector(
        onTap: () {
          if (!_isPlaying) {
            _togglePlay();
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFFBFBFD),
          body: Stack(
            children: [
              // Background soft gradient
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFF3F6F9),
                        Color(0xFFFCFDFE),
                        Color(0xFFF9FBFD),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),

              // Custom Painted Elegant Crescent Moon and Stars in Background
              Positioned(
                top: 40,
                right: 40,
                child: FadeTransition(
                  opacity: Tween<double>(begin: 0, end: 0.15).animate(
                    CurvedAnimation(
                        parent: _fadeController,
                        curve: const Interval(0.2, 0.8, curve: Curves.easeOut)),
                  ),
                  child: const CustomPaint(
                    size: Size(120, 120),
                    painter: CrescentMoonPainter(),
                  ),
                ),
              ),

              // Elegant swaying lanterns
              // Positioned(
              //   top: 0,
              //   left: size.width * 0.15,
              //   child: AnimatedBuilder(
              //     animation: _lanternController,
              //     builder: (context, child) {
              //       return Transform.rotate(
              //         angle: math.sin(_lanternController.value * math.pi * 2) *
              //             0.05,
              //         origin: const Offset(0, 0),
              //         child: const CustomPaint(
              //           size: Size(60, 160),
              //           painter: LanternPainter(glowColor: Color(0xFFE5C060)),
              //         ),
              //       );
              //     },
              //   ),
              // ),
              // Positioned(
              //   top: 0,
              //   right: size.width * 0.15,
              //   child: AnimatedBuilder(
              //     animation: _lanternController,
              //     builder: (context, child) {
              //       return Transform.rotate(
              //         angle: math.cos(_lanternController.value * math.pi * 2) *
              //             0.04,
              //         origin: const Offset(0, 0),
              //         child: const CustomPaint(
              //           size: Size(50, 140),
              //           painter: LanternPainter(glowColor: Color(0xFFE5C060)),
              //         ),
              //       );
              //     },
              //   ),
              // ),

              // Beautiful Floral Background Illustrations (Watercolor look)
              // Top Left Floral frame
              // Positioned(
              //   top: -20,
              //   left: -20,
              //   child: IgnorePointer(
              //     child: Opacity(
              //       opacity: 0.9,
              //       child: Image.network(
              //         'https://images.unsplash.com/photo-1525310072745-f49212b5ac6d?auto=format&fit=crop&q=80&w=400',
              //         width: isMobile ? 180 : 320,
              //         height: isMobile ? 180 : 320,
              //         fit: BoxFit.cover,
              //         color: Colors.white.withOpacity(0.12),
              //         colorBlendMode: BlendMode.dstIn,
              //       ),
              //     ),
              //   ),
              // ),
              // // Bottom Right Floral frame
              // Positioned(
              //   bottom: -30,
              //   right: -30,
              //   child: IgnorePointer(
              //     child: Opacity(
              //       opacity: 0.9,
              //       child: Image.network(
              //         'https://images.unsplash.com/photo-1596436889106-be35e843f974?auto=format&fit=crop&q=80&w=400',
              //         width: isMobile ? 220 : 380,
              //         height: isMobile ? 220 : 380,
              //         fit: BoxFit.cover,
              //         color: Colors.white.withOpacity(0.12),
              //         colorBlendMode: BlendMode.dstIn,
              //       ),
              //     ),
              //   ),
              // ),

              // Floating petals over background
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _PetalsPainter(petals: _petals),
                  ),
                ),
              ),

              // Main Card Content
              Center(
                  child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: size.height),
                child: Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    width: isMobile ? size.width * 0.95 : size.width * 0.3,
                    // height: size.height,
                    child: SizedBox(
                      width: size.width,
                      child: AnimatedBuilder(
                        animation: _shimmerController,
                        builder: (context, child) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.92),
                              image: const DecorationImage(
                                image: AssetImage('assets/images/wedded.webp'),
                                fit: BoxFit.cover,
                                opacity: 0.8,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF2C4A6F).withOpacity(0.08),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                              border: Border.all(
                                width: 1.0,
                                color: Color.lerp(
                                  const Color(0xFFD4AF37),
                                  const Color(0xFFF9E7B9),
                                  _shimmerController.value,
                                )!,
                              ),
                            ),
                            child: child,
                          );
                        },
                        child: Stack(
                          children: [
                            // Black gradient overlay at the bottom — sits between the image and the text
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              height: 120,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(24),
                                    bottomRight: Radius.circular(24),
                                  ),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.85),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 20 * s,
                                  horizontal: 20,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // Date display
                                    _buildFadeIn(
                                      start: 0.66,
                                      end: 0.96,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                                color: Colors.white54,
                                                width: 1),
                                          ),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 1 * s),
                                        child: Text(
                                          "07-06-2026 ",
                                          style: TextStyle(
                                            fontFamily: 'Outfit',
                                            fontSize: 11 * s,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 1.0,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 8 * s),
                                    _buildFadeIn(
                                      start: 0.7,
                                      end: 0.98,
                                      child: Text(
                                        "Ilma Reception Hall, Mawanella",
                                        style: TextStyle(
                                          fontFamily: 'PlayfairDisplay',
                                          fontSize: 12 * s,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    // SizedBox(height: 12 * s),
                                  ],
                                ),
                              ),
                            ),
                          ], // Stack children
                        ),
                      ),
                    )
                    // ── DESKTOP: scrollable, constrained width ──
                    ),
              )),
              // Floating rotating gold music disc/note controller
              Positioned(
                top: 24,
                right: 24,
                child: FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _fadeController,
                      curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
                    ),
                  ),
                  child: AnimatedRotation(
                    turns: _isPlaying ? _shimmerController.value : 0,
                    duration: const Duration(milliseconds: 300),
                    child: FloatingActionButton.small(
                      onPressed: _togglePlay,
                      backgroundColor: Colors.white.withOpacity(0.9),
                      foregroundColor: const Color(0xFFD4AF37),
                      shape: const CircleBorder(
                        side: BorderSide(color: Color(0xFFD4AF37), width: 1.5),
                      ),
                      elevation: 4,
                      child: Icon(
                        _isPlaying ? Icons.music_note : Icons.music_off,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  // Animation builder helper
  Widget _buildFadeIn(
      {required double start, required double end, required Widget child}) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _fadeController,
          curve: Interval(start, end, curve: Curves.easeIn),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
            .animate(
          CurvedAnimation(
            parent: _fadeController,
            curve: Interval(start, end, curve: Curves.easeOutBack),
          ),
        ),
        child: child,
      ),
    );
  }
}

// Beautiful crescent moon and stars in background
class CrescentMoonPainter extends CustomPainter {
  const CrescentMoonPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width * 0.8, size.height * 0.2)
      ..arcToPoint(
        Offset(size.width * 0.2, size.height * 0.8),
        radius: Radius.circular(size.width * 0.5),
        clockwise: true,
      )
      ..arcToPoint(
        Offset(size.width * 0.8, size.height * 0.2),
        radius: Radius.circular(size.width * 0.42),
        clockwise: false,
      );

    canvas.drawPath(path, paint);

    // Draw small gold stars
    final starPaint = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.6)
      ..style = PaintingStyle.fill;

    _drawStar(
        canvas, Offset(size.width * 0.2, size.height * 0.35), 4, starPaint);
    _drawStar(
        canvas, Offset(size.width * 0.45, size.height * 0.25), 6, starPaint);
    _drawStar(
        canvas, Offset(size.width * 0.3, size.height * 0.65), 5, starPaint);
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      double angle = i * 4 * math.pi / 5 - math.pi / 2;
      double x = center.dx + size * math.cos(angle);
      double y = center.dy + size * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom Painter for Islamic Hanging Lanterns
// class LanternPainter extends CustomPainter {
//   final Color glowColor;
//   const LanternPainter({required this.glowColor});

//   @override
//   void paint(Canvas canvas, Size size) {
//     // Elegant hanging line
//     final linePaint = Paint()
//       ..color = const Color(0xFFD4AF37).withOpacity(0.6)
//       ..strokeWidth = 1.2
//       ..style = PaintingStyle.stroke;
//     canvas.drawLine(Offset(size.width / 2, 0),
//         Offset(size.width / 2, size.height * 0.35), linePaint);

//     final double centerY = size.height * 0.6;
//     final double centerX = size.width / 2;
//     final double radius = size.width * 0.35;

//     // Glowing effect
//     final glowPaint = Paint()
//       ..color = glowColor.withOpacity(0.25)
//       ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
//     canvas.drawCircle(Offset(centerX, centerY), radius * 1.5, glowPaint);

//     // Lantern cap
//     final capPaint = Paint()
//       ..color = const Color(0xFFD4AF37)
//       ..style = PaintingStyle.fill;
//     final capPath = Path()
//       ..moveTo(centerX - radius * 0.5, centerY - radius * 0.9)
//       ..lineTo(centerX + radius * 0.5, centerY - radius * 0.9)
//       ..lineTo(centerX + radius * 0.3, centerY - radius * 1.3)
//       ..lineTo(centerX - radius * 0.3, centerY - radius * 1.3)
//       ..close();
//     canvas.drawPath(capPath, capPaint);

//     // Lantern body (Islamic dome/glass shape)
//     final glassPaint = Paint()
//       ..color = const Color(0xFF2C4A6F).withOpacity(0.15)
//       ..style = PaintingStyle.fill;
//     final glassOutline = Paint()
//       ..color = const Color(0xFFD4AF37)
//       ..strokeWidth = 1.5
//       ..style = PaintingStyle.stroke;

//     final bodyPath = Path()
//       ..moveTo(centerX - radius * 0.5, centerY - radius * 0.9)
//       ..cubicTo(
//         centerX - radius * 1.1,
//         centerY - radius * 0.3,
//         centerX - radius * 1.1,
//         centerY + radius * 0.3,
//         centerX - radius * 0.5,
//         centerY + radius * 0.9,
//       )
//       ..lineTo(centerX + radius * 0.5, centerY + radius * 0.9)
//       ..cubicTo(
//         centerX + radius * 1.1,
//         centerY + radius * 0.3,
//         centerX + radius * 1.1,
//         centerY - radius * 0.3,
//         centerX + radius * 0.5,
//         centerY - radius * 0.9,
//       )
//       ..close();

//     canvas.drawPath(bodyPath, glassPaint);
//     canvas.drawPath(bodyPath, glassOutline);

//     // Grid details on lantern glass
//     final detailPaint = Paint()
//       ..color = const Color(0xFFD4AF37).withOpacity(0.6)
//       ..strokeWidth = 0.8
//       ..style = PaintingStyle.stroke;
//     canvas.drawLine(Offset(centerX, centerY - radius * 0.9),
//         Offset(centerX, centerY + radius * 0.9), detailPaint);
//     canvas.drawLine(Offset(centerX - radius * 0.75, centerY),
//         Offset(centerX + radius * 0.75, centerY), detailPaint);

//     // Lantern bottom details
//     final bottomPath = Path()
//       ..moveTo(centerX - radius * 0.3, centerY + radius * 0.9)
//       ..lineTo(centerX + radius * 0.3, centerY + radius * 0.9)
//       ..lineTo(centerX + radius * 0.15, centerY + radius * 1.25)
//       ..lineTo(centerX - radius * 0.15, centerY + radius * 1.25)
//       ..close();
//     canvas.drawPath(bottomPath, capPaint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

// ─────────────────────────────────────────────────────────────────────────────
// Petals (copied from SplashScreen)
// ─────────────────────────────────────────────────────────────────────────────

class _Petal {
  double x, y, size, speed, angle, wobble;
  _Petal({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.angle,
    required this.wobble,
  });
}

class _PetalsPainter extends CustomPainter {
  final List<_Petal> petals;
  _PetalsPainter({required this.petals});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final p in petals) {
      paint.color =
          const Color(0xFFD4AF37).withOpacity(0.22 + (p.size / 16) * 0.14);
      canvas.save();
      canvas.translate(p.x * size.width, p.y * size.height);
      canvas.rotate(p.angle);
      final path = Path()
        ..moveTo(0, -p.size / 2)
        ..quadraticBezierTo(p.size / 2, 0, 0, p.size / 2)
        ..quadraticBezierTo(-p.size / 2, 0, 0, -p.size / 2);
      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_PetalsPainter _) => true;
}
