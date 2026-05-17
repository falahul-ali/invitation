// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:audioplayers/audioplayers.dart';
import 'date_counter.dart';

class Invitation extends StatefulWidget {
  final String guestName;
  const Invitation({super.key, this.guestName = ''});

  @override
  State<Invitation> createState() => _InvitationState();
}

class _InvitationState extends State<Invitation> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _lanternController;
  late AnimationController _petalController;
  late AnimationController _shimmerController;

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  final List<Petal> _petals = [];
  final DateTime _weddingDate = DateTime(2026, 6, 7, 12, 0, 0);

  @override
  void initState() {
    super.initState();

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
      ..addListener(() {
        _updatePetals();
      })
      ..repeat();

    _initializePetals();

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

  void _initializePetals() {
    final random = math.Random();
    for (int i = 0; i < 20; i++) {
      _petals.add(Petal(
        x: random.nextDouble(),
        y: random.nextDouble() * 2 - 1.0,
        size: random.nextDouble() * 12 + 6,
        speed: random.nextDouble() * 0.02 + 0.01,
        angle: random.nextDouble() * math.pi * 2,
        wobbleSpeed: random.nextDouble() * 2 + 1,
      ));
    }
  }

  void _updatePetals() {
    final random = math.Random();
    for (var petal in _petals) {
      petal.y += petal.speed * 0.1;
      petal.angle += 0.01;
      if (petal.y > 1.2) {
        petal.y = -0.2;
        petal.x = random.nextDouble();
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _lanternController.dispose();
    _petalController.dispose();
    _shimmerController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _launchMap() async {
    const String query = "Ilma Reception Hall Mawanella";
    final Uri googleMapsUrl = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}");
    if (await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication)) {
      // Opened successfully
    } else {
      throw 'Could not launch maps';
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 800;

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
                  child: AnimatedBuilder(
                    animation: _petalController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _isPlaying
                            ? _petalController.value * 2 * math.pi
                            : 0,
                        child: FloatingActionButton.small(
                          onPressed: _togglePlay,
                          backgroundColor: Colors.white.withOpacity(0.9),
                          foregroundColor: const Color(0xFFD4AF37),
                          shape: const CircleBorder(
                            side: BorderSide(
                                color: Color(0xFFD4AF37), width: 1.5),
                          ),
                          elevation: 4,
                          child: Icon(
                            _isPlaying ? Icons.music_note : Icons.music_off,
                            size: 20,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Elegant swaying lanterns
              Positioned(
                top: 0,
                left: size.width * 0.15,
                child: AnimatedBuilder(
                  animation: _lanternController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: math.sin(_lanternController.value * math.pi * 2) *
                          0.05,
                      origin: const Offset(0, 0),
                      child: const CustomPaint(
                        size: Size(60, 160),
                        painter: LanternPainter(glowColor: Color(0xFFE5C060)),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 0,
                right: size.width * 0.15,
                child: AnimatedBuilder(
                  animation: _lanternController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: math.cos(_lanternController.value * math.pi * 2) *
                          0.04,
                      origin: const Offset(0, 0),
                      child: const CustomPaint(
                        size: Size(50, 140),
                        painter: LanternPainter(glowColor: Color(0xFFE5C060)),
                      ),
                    );
                  },
                ),
              ),

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

              // Floating Petals
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: PetalsPainter(petals: _petals),
                  ),
                ),
              ),

              // Main Card Content Scrollable area
              Center(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isMobile ? size.width * 0.92 : 620,
                    ),
                    child: AnimatedBuilder(
                      animation: _shimmerController,
                      builder: (context, child) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.92),
                            image: const DecorationImage(
                              image: AssetImage('assets/images/bg.png'),
                              fit: BoxFit.cover,
                              opacity: 0.15, // Blends elegantly without overpowering the golden text
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
                              width: 2.0,
                              color: Color.lerp(
                                const Color(0xFFD4AF37), // Classic Gold
                                const Color(0xFFF9E7B9), // Pale/Shimmer Gold
                                _shimmerController.value,
                              )!,
                            ),
                          ),
                          child: child,
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: isMobile ? 32 : 48,
                          horizontal: isMobile ? 20 : 40,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Arabic Calligraphy Reveal Animation
                            FadeTransition(
                              opacity:
                                  Tween<double>(begin: 0.0, end: 1.0).animate(
                                CurvedAnimation(
                                  parent: _fadeController,
                                  curve: const Interval(0.0, 0.4,
                                      curve: Curves.easeIn),
                                ),
                              ),
                              child: ScaleTransition(
                                scale: Tween<double>(begin: 0.95, end: 1.0)
                                    .animate(
                                  CurvedAnimation(
                                    parent: _fadeController,
                                    curve: const Interval(0.0, 0.4,
                                        curve: Curves.easeOut),
                                  ),
                                ),
                                child: const Text(
                                  "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
                                  style: TextStyle(
                                    fontFamily: 'Scheherazade',
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2C4A6F),
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Subtitle: In the name of Allah
                            _buildFadeIn(
                              start: 0.2,
                              end: 0.5,
                              child: const Text(
                                "IN THE NAME OF ALLAH,\nTHE MOST BENEFICENT AND MOST MERCIFUL",
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF7B9EC1),
                                  letterSpacing: 2.0,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Host Greeting
                            _buildFadeIn(
                              start: 0.3,
                              end: 0.6,
                              child: const Text(
                                "Mrs. M.J Ismath (Wife of Late Mr. M.J Ismath)",
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF2C4A6F),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 10),

                            _buildFadeIn(
                              start: 0.35,
                              end: 0.65,
                              child: const Text(
                                "Request the pleasure of the company of",
                                style: TextStyle(
                                  fontFamily: 'AlexBrush',
                                  fontSize: 20,
                                  color: Color(0xFF7B9EC1),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Personalized Guest Greeting / Greeting placeholder
                            _buildFadeIn(
                              start: 0.4,
                              end: 0.7,
                              child: widget.guestName.isNotEmpty
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 24),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: const Color(0xFFD4AF37)
                                                .withOpacity(0.5),
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          widget.guestName.toUpperCase(),
                                          style: const TextStyle(
                                            fontFamily: 'Outfit',
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFFD4AF37),
                                            letterSpacing: 1.5,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          "MR. & MRS./MS.",
                                          style: TextStyle(
                                            fontFamily: 'Outfit',
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF7B9EC1),
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          "......................................................................",
                                          style: TextStyle(
                                            color: const Color(0xFF7B9EC1)
                                                .withOpacity(0.4),
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                            const SizedBox(height: 12),

                            _buildFadeIn(
                              start: 0.45,
                              end: 0.75,
                              child: const Text(
                                "on the occasion of the",
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 13,
                                  color: Color(0xFF2C4A6F),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Waleema Ceremony Title
                            _buildFadeIn(
                              start: 0.5,
                              end: 0.8,
                              child: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  "Waleema Ceremony",
                                  style: TextStyle(
                                    fontFamily: 'AlexBrush',
                                    fontSize: 42,
                                    color: Color(0xFFD4AF37),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            _buildFadeIn(
                              start: 0.52,
                              end: 0.82,
                              child: const Text(
                                "of their son",
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 13,
                                  color: Color(0xFF7B9EC1),
                                ),
                              ),
                            ),
                            // const SizedBox(height: 10),

                            // Groom and Bride Name
                            _buildFadeIn(
                              start: 0.55,
                              end: 0.85,
                              child: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  "Falahul Ali",
                                  style: TextStyle(
                                    fontFamily: 'AlexBrush',
                                    fontSize: 50,
                                    color: Color(0xFF2C4A6F),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            // const SizedBox(height: 4),
                            _buildFadeIn(
                              start: 0.58,
                              end: 0.88,
                              child: const Text(
                                "&",
                                style: TextStyle(
                                  fontFamily: 'AlexBrush',
                                  fontSize: 28,
                                  color: Color(0xFFD4AF37),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            // const SizedBox(height: 4),
                            _buildFadeIn(
                              start: 0.6,
                              end: 0.9,
                              child: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  "Fathima Ihshana",
                                  style: TextStyle(
                                    fontFamily: 'AlexBrush',
                                    fontSize: 50,
                                    color: Color(0xFF2C4A6F),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            // const SizedBox(height: 16),

                            // Bride's parent details
                            _buildFadeIn(
                              start: 0.62,
                              end: 0.92,
                              child: const Text(
                                "Daughter of Mr. & Mrs. M. Mohideen",
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF2C4A6F),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildFadeIn(
                              start: 0.64,
                              end: 0.94,
                              child: const Text(
                                "In sha Allah on",
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 13,
                                  color: Color(0xFF7B9EC1),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Date display
                            _buildFadeIn(
                              start: 0.66,
                              end: 0.96,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 75,
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                            color: Color(0xFF2C4A6F), width: 1),
                                        bottom: BorderSide(
                                            color: Color(0xFF2C4A6F), width: 1),
                                      ),
                                    ),
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: const Text(
                                      "SUNDAY",
                                      style: TextStyle(
                                        fontFamily: 'Outfit',
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2C4A6F),
                                        letterSpacing: 1.0,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Column(
                                    children: [
                                      const Text(
                                        "7",
                                        style: TextStyle(
                                          fontFamily: 'PlayfairDisplay',
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFD4AF37),
                                        ),
                                      ),
                                      const Text(
                                        "JUNE",
                                        style: TextStyle(
                                          fontFamily: 'Outfit',
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2C4A6F),
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 15),
                                  Container(
                                    width: 75,
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                            color: Color(0xFF2C4A6F), width: 1),
                                        bottom: BorderSide(
                                            color: Color(0xFF2C4A6F), width: 1),
                                      ),
                                    ),
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: const Text(
                                      "2026",
                                      style: TextStyle(
                                        fontFamily: 'Outfit',
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2C4A6F),
                                        letterSpacing: 1.0,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Lunch timing and Venue details
                            _buildFadeIn(
                              start: 0.7,
                              end: 0.98,
                              child: const Column(
                                children: [
                                  Text(
                                    "For Lunch",
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C4A6F),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "From 12:00 PM onwards",
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 14,
                                      color: Color(0xFF2C4A6F),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    "At Ilma Reception Hall",
                                    style: TextStyle(
                                      fontFamily: 'PlayfairDisplay',
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C4A6F),
                                    ),
                                  ),
                                  Text(
                                    "Mawanella",
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 15,
                                      color: Color(0xFF7B9EC1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Countdown DayCounter component
                            _buildFadeIn(
                              start: 0.75,
                              end: 1.0,
                              child: DayCounter(targetDate: _weddingDate),
                            ),
                            const SizedBox(height: 32),

                            // Actions: Venue Map
                            _buildFadeIn(
                              start: 0.8,
                              end: 1.0,
                              child: Center(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2C4A6F),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 32, vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 4,
                                    shadowColor: const Color(0xFF2C4A6F)
                                        .withOpacity(0.3),
                                  ),
                                  onPressed: _launchMap,
                                  icon:
                                      const Icon(Icons.map_outlined, size: 20),
                                  label: const Text(
                                    "VENUE MAP",
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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

// Particle design for floating petals
class Petal {
  double x;
  double y;
  double size;
  double speed;
  double angle;
  double wobbleSpeed;

  Petal({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.angle,
    required this.wobbleSpeed,
  });
}

// Custom Painter for Petals Animation
class PetalsPainter extends CustomPainter {
  final List<Petal> petals;
  PetalsPainter({required this.petals});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF7B9EC1).withOpacity(0.2)
      ..style = PaintingStyle.fill;

    for (var petal in petals) {
      canvas.save();
      final offset = Offset(petal.x * size.width, petal.y * size.height);
      canvas.translate(offset.dx, offset.dy);
      canvas.rotate(petal.angle);

      // Draw elegant leaf/petal path
      final path = Path()
        ..moveTo(0, -petal.size / 2)
        ..quadraticBezierTo(petal.size / 2, -petal.size / 4, 0, petal.size / 2)
        ..quadraticBezierTo(
            -petal.size / 2, -petal.size / 4, 0, -petal.size / 2);

      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
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
class LanternPainter extends CustomPainter {
  final Color glowColor;
  const LanternPainter({required this.glowColor});

  @override
  void paint(Canvas canvas, Size size) {
    // Elegant hanging line
    final linePaint = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.6)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(size.width / 2, 0),
        Offset(size.width / 2, size.height * 0.35), linePaint);

    final double centerY = size.height * 0.6;
    final double centerX = size.width / 2;
    final double radius = size.width * 0.35;

    // Glowing effect
    final glowPaint = Paint()
      ..color = glowColor.withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(Offset(centerX, centerY), radius * 1.5, glowPaint);

    // Lantern cap
    final capPaint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..style = PaintingStyle.fill;
    final capPath = Path()
      ..moveTo(centerX - radius * 0.5, centerY - radius * 0.9)
      ..lineTo(centerX + radius * 0.5, centerY - radius * 0.9)
      ..lineTo(centerX + radius * 0.3, centerY - radius * 1.3)
      ..lineTo(centerX - radius * 0.3, centerY - radius * 1.3)
      ..close();
    canvas.drawPath(capPath, capPaint);

    // Lantern body (Islamic dome/glass shape)
    final glassPaint = Paint()
      ..color = const Color(0xFF2C4A6F).withOpacity(0.15)
      ..style = PaintingStyle.fill;
    final glassOutline = Paint()
      ..color = const Color(0xFFD4AF37)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final bodyPath = Path()
      ..moveTo(centerX - radius * 0.5, centerY - radius * 0.9)
      ..cubicTo(
        centerX - radius * 1.1,
        centerY - radius * 0.3,
        centerX - radius * 1.1,
        centerY + radius * 0.3,
        centerX - radius * 0.5,
        centerY + radius * 0.9,
      )
      ..lineTo(centerX + radius * 0.5, centerY + radius * 0.9)
      ..cubicTo(
        centerX + radius * 1.1,
        centerY + radius * 0.3,
        centerX + radius * 1.1,
        centerY - radius * 0.3,
        centerX + radius * 0.5,
        centerY - radius * 0.9,
      )
      ..close();

    canvas.drawPath(bodyPath, glassPaint);
    canvas.drawPath(bodyPath, glassOutline);

    // Grid details on lantern glass
    final detailPaint = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.6)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(centerX, centerY - radius * 0.9),
        Offset(centerX, centerY + radius * 0.9), detailPaint);
    canvas.drawLine(Offset(centerX - radius * 0.75, centerY),
        Offset(centerX + radius * 0.75, centerY), detailPaint);

    // Lantern bottom details
    final bottomPath = Path()
      ..moveTo(centerX - radius * 0.3, centerY + radius * 0.9)
      ..lineTo(centerX + radius * 0.3, centerY + radius * 0.9)
      ..lineTo(centerX + radius * 0.15, centerY + radius * 1.25)
      ..lineTo(centerX - radius * 0.15, centerY + radius * 1.25)
      ..close();
    canvas.drawPath(bottomPath, capPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
