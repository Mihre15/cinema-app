import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotateController;
  late AnimationController _slideController;
  late AnimationController _opacityController;

  late Animation<double> _rotation;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    // Rotation Animation
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _rotation = Tween<double>(begin: 0, end: 359 / 360).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeInOut),
    );

    // Slide Animation
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slide = Tween<Offset>(begin: Offset.zero, end: const Offset(-1.2, 0))
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    // Opacity Animation for Fade-in
    _opacityController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _opacityController, curve: Curves.easeIn),
    );

    // Start animations in sequence and navigate after completion
    _rotateController.forward().whenComplete(() {
      _slideController.forward().whenComplete(() {
        _opacityController.forward().whenComplete(() {
          // Navigate to SignUp screen after animations
          Navigator.pushReplacementNamed(context, '/login');
        });
      });
    });
  }

  @override
  void dispose() {
    _rotateController.dispose();
    _slideController.dispose();
    _opacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            SlideTransition(
              position: _slide,
              child: RotationTransition(
                turns: _rotation,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 30,
              child: FadeTransition(
                opacity: _fade,
                child: Text(
                  "Abyssinia",
                  style: GoogleFonts.bebasNeue(
                    textStyle: const TextStyle(
                      color: Colors.yellow,
                      fontSize: 20,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}