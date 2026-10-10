import 'package:flutter/material.dart';

import '../theme.dart';

/// Abertura: o logo aparece com fade e leve zoom, segura um instante, some
/// suavemente e a próxima tela entra com fade e um pequeno deslize.
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.next,
    this.duration = const Duration(milliseconds: 2800),
  });

  /// Constrói a tela que vem depois da splash (a Home).
  final WidgetBuilder next;
  final Duration duration;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fadeIn;
  late final Animation<double> _scale;
  late final Animation<double> _fadeOut;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.duration);
    _fadeIn = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    );
    _scale = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _c,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );
    _fadeOut = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.8, 1.0, curve: Curves.easeIn),
    );
    _c.addStatusListener((status) {
      if (status == AnimationStatus.completed) _goNext();
    });
    _c.forward();
  }

  void _goNext() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            widget.next(context),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved =
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.03),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 700),
      ),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, child) {
                final opacity = (_fadeIn.value * (1 - _fadeOut.value))
                    .clamp(0.0, 1.0)
                    .toDouble();
                return Opacity(
                  opacity: opacity,
                  child: Transform.scale(scale: _scale.value, child: child),
                );
              },
              child: Image.asset(
                'assets/logo.png',
                width: width * 0.75,
                // Se o asset não for encontrado (pubspec sem o logo), mostra o nome.
                errorBuilder: (context, error, stackTrace) => const Text(
                  'Retinova',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 56,
            child: Center(
              child: SizedBox(
                width: 120,
                child: AnimatedBuilder(
                  animation: _c,
                  builder: (context, _) {
                    final opacity = (_fadeIn.value * (1 - _fadeOut.value))
                        .clamp(0.0, 1.0)
                        .toDouble();
                    return Opacity(
                      opacity: opacity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _c.value,
                          minHeight: 4,
                          backgroundColor: AppColors.primaryTint,
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
