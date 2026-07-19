import 'package:flutter/material.dart';
import 'theme.dart';
import 'services/session_service.dart';
import 'screens/login_screen.dart';
import 'screens/products_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ventes Privées',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashDecider(),
    );
  }
}

/// Vérifie s'il existe déjà une session utilisateur avant d'afficher le bon écran,
/// avec une courte animation de logo pendant la vérification.
class SplashDecider extends StatefulWidget {
  const SplashDecider({super.key});

  @override
  State<SplashDecider> createState() => _SplashDeciderState();
}

class _SplashDeciderState extends State<SplashDecider> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..forward();
    _checkSession();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkSession() async {
    // Petit délai minimum pour éviter un flash trop brutal de l'écran de démarrage
    final results = await Future.wait([
      SessionService.getUser(),
      Future.delayed(const Duration(milliseconds: 500)),
    ]);
    final user = results[0];
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondary) =>
        user != null ? const ProductsScreen() : const LoginScreen(),
        transitionsBuilder: (context, animation, secondary, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: ScaleTransition(
          scale: CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
          child: FadeTransition(
            opacity: _controller,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 42),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Ventes Privées',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}