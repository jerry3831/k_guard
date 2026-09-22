import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/auth_bloc.dart';
import '../providers/auth_event.dart';
import '../providers/auth_state.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: isDark ? Colors.white : AppColors.primaryBlue,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Roboto',
                          ),
                          children: [
                            TextSpan(
                              text: 'Kwacha',
                              style: TextStyle(color: isDark ? Colors.white : AppColors.primaryBlue),
                            ),
                            const TextSpan(
                              text: 'Guard',
                              style: TextStyle(color: AppColors.goldAccent),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pushNamed('/login'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 2),

              Center(
                child: SizedBox(
                  width: 260,
                  height: 260,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Positioned(top: 20, left: 30, child: _AnimatedBlueDot(size: 14, opacity: 0.35, seed: 1)),
                      const Positioned(top: 60, right: 30, child: _AnimatedBlueDot(size: 20, opacity: 0.15, seed: 2)),
                      const Positioned(bottom: 40, left: 40, child: _AnimatedBlueDot(size: 12, opacity: 0.4, seed: 3)),
                      const Positioned(bottom: 70, right: 20, child: _AnimatedBlueDot(size: 8, opacity: 0.3, seed: 4)),
                      const Positioned(top: 130, left: 10, child: _AnimatedBlueDot(size: 6, opacity: 0.6, seed: 5)),
                      const Positioned(bottom: 20, right: 100, child: _AnimatedBlueDot(size: 16, opacity: 0.2, seed: 6)),
                      const Positioned(top: 15, right: 100, child: _AnimatedBlueDot(size: 9, opacity: 0.45, seed: 7)),
                      
                      const Positioned(top: 100, right: 15, child: _AnimatedBlueDot(size: 4, opacity: 0.7, seed: 8)),
                      const Positioned(bottom: 110, left: 20, child: _AnimatedBlueDot(size: 10, opacity: 0.25, seed: 9)),
                      const Positioned(top: -5, left: 120, child: _AnimatedBlueDot(size: 7, opacity: 0.5, seed: 10)),
                      const Positioned(bottom: -5, left: 140, child: _AnimatedBlueDot(size: 5, opacity: 0.55, seed: 11)),
                      const Positioned(top: 180, right: 40, child: _AnimatedBlueDot(size: 18, opacity: 0.12, seed: 12)),
                      const Positioned(top: 80, left: 45, child: _AnimatedBlueDot(size: 5, opacity: 0.4, seed: 13)),
                      const Positioned(bottom: 25, left: 90, child: _AnimatedBlueDot(size: 8, opacity: 0.35, seed: 14)),
                      const Positioned(top: 40, right: 60, child: _AnimatedBlueDot(size: 6, opacity: 0.6, seed: 15)),

                      const Icon(
                        Icons.shield_outlined,
                        size: 180,
                        color: AppColors.primaryBlue,
                      ),
                      const Text(
                        'mk',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: AppColors.goldAccent,
                          letterSpacing: 2,
                        ),
                      ),
                      Positioned(
                        top: 55,
                        right: 55,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primaryBlue, width: 4),
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 28,
                              color: AppColors.goldAccent,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                  children: [
                    const TextSpan(
                      text: 'Detect Counterfeit\n',
                      style: TextStyle(color: AppColors.goldAccent),
                    ),
                    TextSpan(
                      text: 'kwacha notes',
                      style: TextStyle(
                          color: isDark ? Colors.white : AppColors.primaryBlue),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              Text(
                'Instant AI verification of Malawian Kwacha notes',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const Spacer(flex: 3),

              ElevatedButton(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthGuestSignInRequested());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pushNamed('/login'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? Colors.white : AppColors.primaryBlue,
                  minimumSize: const Size(double.infinity, 56),
                  side: BorderSide(
                    color: isDark ? Colors.white30 : AppColors.primaryBlue,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    ),
    );
  }
}

class _AnimatedBlueDot extends StatefulWidget {
  final double size;
  final double opacity;
  final int seed;

  const _AnimatedBlueDot({
    required this.size,
    required this.opacity,
    required this.seed,
  });

  @override
  State<_AnimatedBlueDot> createState() => _AnimatedBlueDotState();
}

class _AnimatedBlueDotState extends State<_AnimatedBlueDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late double _offsetX;
  late double _offsetY;

  @override
  void initState() {
    super.initState();
    final random = math.Random(widget.seed);
    
    _offsetX = random.nextDouble() * 30 - 15;
    _offsetY = random.nextDouble() * 30 - 15;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3000 + random.nextInt(3000)),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    );

    _controller.value = random.nextDouble();
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final val = (_animation.value * 2) - 1;
        return Transform.translate(
          offset: Offset(_offsetX * val, _offsetY * val),
          child: child,
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withOpacity(widget.opacity),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
