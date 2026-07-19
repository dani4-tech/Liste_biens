import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import 'products_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await ApiService.login(_emailCtrl.text.trim(), _passwordCtrl.text);
      await SessionService.saveUser(user);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (context, animation, secondary) => const ProductsScreen(),
          transitionsBuilder: (context, animation, secondary, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Bandeau décoratif en haut, avec un dégradé doux
          Container(
            height: 260,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, Color(0xFF9333EA)],
              ),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 24, offset: const Offset(0, 10)),
                      ],
                    ),
                    child: const Icon(Icons.shopping_bag_rounded, color: AppColors.primary, size: 38),
                  ),
                  const SizedBox(height: 20),
                  const Text('Ventes Privées', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('Connecte-toi pour découvrir les offres', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14)),
                  const SizedBox(height: 32),

                  // Carte de formulaire flottante par-dessus le dégradé
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 30, offset: const Offset(0, 12)),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Connexion', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                          const SizedBox(height: 20),

                          const Text('Email', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textGrey)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(hintText: 'toi@example.com', prefixIcon: Icon(Icons.mail_outline_rounded)),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Email requis';
                              if (!v.contains('@')) return 'Email invalide';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          const Text('Mot de passe', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textGrey)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    color: AppColors.textGrey),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            validator: (v) => (v == null || v.isEmpty) ? 'Mot de passe requis' : null,
                          ),

                          AnimatedSize(
                            duration: const Duration(milliseconds: 200),
                            child: _errorMessage != null
                                ? Padding(
                              padding: const EdgeInsets.only(top: 14),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline_rounded, color: Colors.red.shade400, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(_errorMessage!, style: TextStyle(color: Colors.red.shade700, fontSize: 13))),
                                  ],
                                ),
                              ),
                            )
                                : const SizedBox.shrink(),
                          ),

                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: FilledButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              child: _isLoading
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Text('Se connecter'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}