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
  // ── Text entrance ──────────────────────────────────────────────────────────
  late AnimationController _entranceController;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;

  // ── Bouncing arrow hint ────────────────────────────────────────────────────
  late AnimationController _arrowController;
  late Animation<double> _arrowBounce;
  late Animation<double> _arrowFade;

  // ── Floating petals ────────────────────────────────────────────────────────
  late AnimationController _petalController;
  final List<_Petal> _petals = [];

  // ── Confetti burst ─────────────────────────────────────────────────────────
  late AnimationController _confettiController;
  final List<_ConfettiPiece> _confetti = [];
  bool _confettiActive = false;

  // ── Auto-timer progress bar ────────────────────────────────────────────────
  late AnimationController _timerController;

  // ── Exit fade ──────────────────────────────────────────────────────────────
  late AnimationController _exitController;
  late Animation<double> _exitFade;

  // ── State ──────────────────────────────────────────────────────────────────
  bool _swiped = false;
  Size _lastKnownSize = Size.zero;

  // Drag tracking
  double _dragStartY = 0;
  static const double _swipeThreshold = 60.0;

  @override
  void initState() {
    super.initState();

    // ── Entrance ─────────────────────────────────────────────────────────────
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
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    // ── Arrow bounce ──────────────────────────────────────────────────────────
    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _arrowBounce = Tween<double>(begin: 0, end: -14).animate(
      CurvedAnimation(parent: _arrowController, curve: Curves.easeInOut),
    );
    _arrowFade = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _arrowController, curve: Curves.easeInOut),
    );

    // ── Petals ────────────────────────────────────────────────────────────────
    _petalController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )
      ..addListener(_updatePetals)
      ..repeat();
    _initPetals();

    // ── Confetti ──────────────────────────────────────────────────────────────
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _confettiController.addListener(() {
      if (_confettiActive) {
        _updateConfetti(_confettiController.value);
        if (mounted) setState(() {});
      }
    });

    // ── Exit ──────────────────────────────────────────────────────────────────
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _exitFade = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeIn),
    );
    _exitController.addStatusListener((status) {
      if (status == AnimationStatus.completed) _navigateToInvitation();
    });

    // ── Auto-timer (5 s) ──────────────────────────────────────────────────────
    // Starts after the entrance animation finishes so the progress bar only
    // begins filling once the guest has had a moment to read the text.
    _timerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );
    _timerController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _triggerOpen(
          // We don't have BuildContext here, pass a dummy size;
          // _triggerOpen guards against double-trigger via _swiped flag.
          // The real screen size is used when spawning confetti from the build
          // method, so we store it there. For the timer path we use a sentinel.
          _lastKnownSize,
        );
      }
    });

    // Start entrance
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) {
        _entranceController.forward().then((_) {
          // Begin the countdown only after text has fully appeared
          if (mounted) _timerController.forward();
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pre-cache the bg image used on the invitation screen so the transition
    // is instant rather than showing a blank card while the image loads.
    precacheImage(const AssetImage('assets/images/bg.png'), context);
  }

  // ── Petals ──────────────────────────────────────────────────────────────────
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

  // ── Confetti ────────────────────────────────────────────────────────────────
  void _spawnConfetti(Size screenSize) {
    final rng = math.Random();
    _confetti.clear();

    // Wedding colour palette
    const colors = [
      Color(0xFFD4AF37), // gold
      Color(0xFFF9E7B9), // champagne
      Color(0xFF7B9EC1), // dusty blue
      Color(0xFFFFFFFF), // white
      Color(0xFFE8C4C4), // blush pink
      Color(0xFF2C4A6F), // navy
    ];

    for (int i = 0; i < 120; i++) {
      final angle = rng.nextDouble() * math.pi * 2;
      final speed = rng.nextDouble() * 520 + 180;
      _confetti.add(_ConfettiPiece(
        x: screenSize.width / 2,
        y: screenSize.height * 0.72,
        vx: math.cos(angle) * speed,
        vy: math.sin(angle) * speed - 300, // bias upward
        color: colors[rng.nextInt(colors.length)],
        size: rng.nextDouble() * 9 + 4,
        rotation: rng.nextDouble() * math.pi * 2,
        rotationSpeed: (rng.nextDouble() - 0.5) * 12,
        isCircle: rng.nextBool(),
      ));
    }
    _confettiActive = true;
  }

  void _updateConfetti(double t) {
    const gravity = 900.0;
    for (final c in _confetti) {
      // Simple physics: position = start + v*t + 0.5*g*t²
      // We store initial values and recompute each frame from t
      c.currentX = c.x + c.vx * t;
      c.currentY = c.y + c.vy * t + 0.5 * gravity * t * t;
      c.currentRotation = c.rotation + c.rotationSpeed * t;
      c.opacity = (1.0 - (t / 1.0)).clamp(0.0, 1.0);
    }
  }

  // ── Swipe trigger ───────────────────────────────────────────────────────────
  void _triggerOpen(Size screenSize) {
    if (_swiped) return;
    setState(() => _swiped = true);
    _timerController.stop();
    _arrowController.stop();
    _spawnConfetti(screenSize);
    _confettiController.forward();

    // Wait for confetti peak, then fade out and navigate
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) _exitController.forward();
    });
  }

  void _navigateToInvitation() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, __, ___) => Invitation(guestName: widget.guestName),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _arrowController.dispose();
    _petalController.dispose();
    _confettiController.dispose();
    _timerController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _lastKnownSize = size;

    return Scaffold(
      body: GestureDetector(
        // ── Swipe-up detection ──────────────────────────────────────────────
        onVerticalDragStart: (d) => _dragStartY = d.globalPosition.dy,
        onVerticalDragUpdate: (d) {
          final delta = _dragStartY - d.globalPosition.dy;
          if (delta > _swipeThreshold) _triggerOpen(size);
        },
        // Also allow a simple tap as fallback
        onTap: () => _triggerOpen(size),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Cover image ───────────────────────────────────────────────
            Image.asset('assets/images/cover.png', fit: BoxFit.cover),

            // ── Bottom gradient overlay ───────────────────────────────────
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    const Color(0xFF1A2E45).withOpacity(0.85),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.35, 1.0],
                ),
              ),
            ),

            // ── Floating petals ───────────────────────────────────────────
            IgnorePointer(
              child: CustomPaint(
                painter: _PetalsPainter(petals: _petals),
              ),
            ),

            // ── Confetti ──────────────────────────────────────────────────
            if (_confettiActive)
              IgnorePointer(
                child: AnimatedBuilder(
                  animation: _confettiController,
                  builder: (_, __) => CustomPaint(
                    painter: _ConfettiPainter(pieces: _confetti),
                  ),
                ),
              ),

            // ── Main content (fades out on exit) ──────────────────────────
            FadeTransition(
              opacity: _exitFade,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // ── Magical sentence ────────────────────────────────────
                  FadeTransition(
                    opacity: _textFade,
                    child: SlideTransition(
                      position: _textSlide,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 36),
                        child: Text(
                          "Some souls are chosen to witness\nthe most beautiful chapter of our life.\nYou are one of them.",
                          style: TextStyle(
                            fontFamily: 'AlexBrush',
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.95),
                            letterSpacing: 0.4,
                            height: 1.55,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ── Swipe-up arrow hint ─────────────────────────────────
                  if (!_swiped)
                    FadeTransition(
                      opacity: _textFade,
                      child: AnimatedBuilder(
                        animation: _arrowController,
                        builder: (_, __) {
                          return Transform.translate(
                            offset: Offset(0, _arrowBounce.value),
                            child: Opacity(
                              opacity: _arrowFade.value,
                              child: Column(
                                children: [
                                  // Double chevron stack for depth
                                  Icon(
                                    Icons.keyboard_arrow_up_rounded,
                                    color: const Color(0xFFD4AF37),
                                    size: 32,
                                  ),
                                  // Icon(
                                  //   Icons.keyboard_arrow_up_rounded,
                                  //   color: const Color(0xFFD4AF37)
                                  //       .withOpacity(0.75),
                                  //   size: 32,
                                  // ),
                                  Icon(
                                    Icons.keyboard_arrow_up_rounded,
                                    color: const Color(0xFFD4AF37)
                                        .withOpacity(0.45),
                                    size: 32,
                                  ),

                                  const SizedBox(height: 6),
                                  Text(
                                    "SWIPE UP TO OPEN",
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFD4AF37),
                                      letterSpacing: 3.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 48),
                ],
              ),
            ),
            // ── Gold progress bar (auto-timer) ───────────────────────────
            if (!_swiped)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: AnimatedBuilder(
                  animation: _timerController,
                  builder: (_, __) {
                    return Container(
                      height: 3,
                      alignment: Alignment.centerLeft,
                      color: Colors.white.withOpacity(0.15),
                      child: FractionallySizedBox(
                        widthFactor: _timerController.value,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFD4AF37),
                                Color(0xFFF9E7B9),
                                Color(0xFFD4AF37),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Confetti
// ─────────────────────────────────────────────────────────────────────────────

class _ConfettiPiece {
  // Initial (spawn) values
  final double x, y, vx, vy;
  final Color color;
  final double size;
  final double rotation;
  final double rotationSpeed;
  final bool isCircle;

  // Mutable current-frame values
  double currentX, currentY, currentRotation, opacity;

  _ConfettiPiece({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.isCircle,
  })  : currentX = x,
        currentY = y,
        currentRotation = rotation,
        opacity = 1.0;
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiPiece> pieces;
  _ConfettiPainter({required this.pieces});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in pieces) {
      if (p.opacity <= 0) continue;
      final paint = Paint()
        ..color = p.color.withOpacity(p.opacity.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(p.currentX, p.currentY);
      canvas.rotate(p.currentRotation);

      if (p.isCircle) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        // Rectangle ribbon piece
        canvas.drawRect(
          Rect.fromCenter(
              center: Offset.zero, width: p.size, height: p.size * 0.45),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter _) => true;
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
