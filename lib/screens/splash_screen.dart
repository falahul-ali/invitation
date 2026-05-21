// ignore_for_file: deprecated_member_use

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'invitation.dart';

class SplashScreen extends StatefulWidget {
  final String guestName;
  const SplashScreen({super.key, this.guestName = ''});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Text entrance
  late AnimationController _entranceController;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;

  // Pulsing "tap" hint
  late AnimationController _pulseController;
  late Animation<double> _pulseOpacity;

  // Floating petals
  late AnimationController _petalController;
  final List<_Petal> _petals = [];

  // Envelope open animation (triggered on tap)
  late AnimationController _openController;
  late Animation<double> _flapAngle;
  late Animation<double> _cardRise;
  late Animation<double> _exitFade;

  bool _tapped = false;

  @override
  void initState() {
    super.initState();

    // ── Entrance ───────────────────────────────────────────────────────────
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _textFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    // ── Pulse hint ─────────────────────────────────────────────────────────
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseOpacity = Tween<double>(begin: 0.45, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // ── Petals ─────────────────────────────────────────────────────────────
    _petalController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )
      ..addListener(_updatePetals)
      ..repeat();
    _initPetals();

    // ── Envelope open ──────────────────────────────────────────────────────
    _openController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _flapAngle = Tween<double>(begin: 0, end: math.pi).animate(
      CurvedAnimation(
        parent: _openController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );
    _cardRise = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _openController,
        curve: const Interval(0.35, 0.85, curve: Curves.easeOut),
      ),
    );
    _exitFade = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _openController,
        curve: const Interval(0.75, 1.0, curve: Curves.easeIn),
      ),
    );

    _openController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToInvitation();
      }
    });

    // Start entrance after a short delay
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _entranceController.forward();
    });
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

  void _onTap() {
    if (_tapped) return;
    setState(() => _tapped = true);
    _pulseController.stop();
    _openController.forward();
  }

  void _navigateToInvitation() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, __, ___) => Invitation(guestName: widget.guestName),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    _petalController.dispose();
    _openController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            // ── Cover image fills the entire screen ──────────────────────
            Image.asset(
              'assets/images/cover.png',
              fit: BoxFit.cover,
            ),

            // ── Soft dark overlay so text is readable ────────────────────
            // Container(
            //   decoration: BoxDecoration(
            //     gradient: LinearGradient(
            //       colors: [
            //         Colors.black.withOpacity(0.18),
            //         Colors.black.withOpacity(0.42),
            //       ],
            //       begin: Alignment.topCenter,
            //       end: Alignment.bottomCenter,
            //     ),
            //   ),
            // ),

            // ── Floating petals ──────────────────────────────────────────
            IgnorePointer(
              child: CustomPaint(
                painter: _PetalsPainter(petals: _petals),
              ),
            ),

            // ── Envelope + text overlay ──────────────────────────────────
            AnimatedBuilder(
              animation: _openController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _exitFade,
                  child: child,
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // ── Envelope ────────────────────────────────────────────
                  // AnimatedBuilder(
                  //   animation: _openController,
                  //   builder: (context, _) {
                  //     return _EnvelopeWidget(
                  //       flapAngle: _flapAngle.value,
                  //       cardRise: _cardRise.value,
                  //     );
                  //   },
                  // ),

                  // const SizedBox(height: 36),

                  // ── Magical sentence ─────────────────────────────────────
                  FadeTransition(
                    opacity: _textFade,
                    child: SlideTransition(
                      position: _textSlide,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          children: [
                            Text(
                              "A moment written in the stars,",
                              style: TextStyle(
                                fontFamily: 'AlexBrush',
                                fontSize: 22,
                                color: Colors.white.withOpacity(0.92),
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "sealed with love & blessed by Allah.",
                              style: TextStyle(
                                fontFamily: 'AlexBrush',
                                fontSize: 22,
                                color: Colors.white.withOpacity(0.92),
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Tap hint ─────────────────────────────────────────────
                  if (!_tapped)
                    FadeTransition(
                      opacity: _textFade,
                      child: AnimatedBuilder(
                        animation: _pulseOpacity,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _pulseOpacity.value,
                            child: child,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 48),
                          child: Text(
                            "✦  touch anywhere to unveil  ✦",
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFD4AF37).withOpacity(0.9),
                              letterSpacing: 2.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Envelope widget
// ─────────────────────────────────────────────────────────────────────────────

class _EnvelopeWidget extends StatelessWidget {
  final double flapAngle; // 0 → π  (closed → open)
  final double cardRise; // 0 → 1

  const _EnvelopeWidget({required this.flapAngle, required this.cardRise});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 160,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // ── Envelope body ──────────────────────────────────────────────
          CustomPaint(
            size: const Size(220, 140),
            painter: _EnvelopeBodyPainter(),
          ),

          // ── Card rising out ────────────────────────────────────────────
          Positioned(
            bottom: 20 + cardRise * 80,
            child: Opacity(
              opacity: cardRise.clamp(0.0, 1.0),
              child: Container(
                width: 160,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withOpacity(0.6),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    "بِسْمِ اللَّهِ",
                    style: TextStyle(
                      fontFamily: 'Scheherazade',
                      fontSize: 22,
                      color: const Color(0xFF2C4A6F).withOpacity(0.85),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Envelope flap (rotates open) ───────────────────────────────
          Positioned(
            top: 0,
            child: Transform(
              alignment: Alignment.topCenter,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(flapAngle),
              child: CustomPaint(
                size: const Size(220, 70),
                painter: _EnvelopeFlapPainter(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom Painters
// ─────────────────────────────────────────────────────────────────────────────

class _EnvelopeBodyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = const Color(0xFFF5EDD8).withOpacity(0.92)
      ..style = PaintingStyle.fill;

    final border = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final body = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(body, fill);
    canvas.drawPath(body, border);

    // Inner V fold lines
    final fold = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(size.width / 2, size.height * 0.55),
      fold,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width, 0)
        ..lineTo(size.width / 2, size.height * 0.55),
      fold,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

class _EnvelopeFlapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = const Color(0xFFEDE0C4).withOpacity(0.95)
      ..style = PaintingStyle.fill;

    final border = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final flap = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(flap, fill);
    canvas.drawPath(flap, border);

    // Wax seal
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.55),
      10,
      Paint()..color = const Color(0xFFD4AF37).withOpacity(0.75),
    );
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.55),
      10,
      Paint()
        ..color = const Color(0xFFB8960C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Petals
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
