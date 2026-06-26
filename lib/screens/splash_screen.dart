// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/expense_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/google_sign_in_button.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();

    // Auto-navigate if already signed in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ExpenseProvider>();
      provider.addListener(() {
        if (provider.isSignedIn && mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.dark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: FadeTransition(
            opacity: _fadeIn,
            child: SlideTransition(
              position: _slideUp,
              child: _spalshScreenContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _spalshScreenContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Image.asset('assets/logo.png'),
        ),
        const SizedBox(height: 12),
        const Text(
          'My Book',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.1,
          ),
        ),
        // const SizedBox(height: 12),
        // Text(
        //   'Sync your expenses directly to Google Sheets.',
        //   style: TextStyle(
        //     fontSize: 16,
        //     color: Colors.white.withOpacity(0.55),
        //     height: 1.5,
        //   ),
        // ),
        const SizedBox(height: 20),
        Consumer<ExpenseProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primary,
                ),
              );
            }
            return _signInButton(provider, context);
          },
        ),
      ],
    );
  }

  Widget _signInButton(ExpenseProvider provider, BuildContext context) {
    return Column(
      children: [
        GoogleSignInButton(
          onTap: () async {
            final success = await provider.signIn();
            if (!mounted) return;
            if (!success) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          },
        ),
        if (provider.errorMessage.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            provider.errorMessage,
            style: const TextStyle(
              color: AppTheme.danger,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
