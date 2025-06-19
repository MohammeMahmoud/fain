import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nctu/provider/auth_provider.dart';
import 'package:nctu/screens/login.dart';
import 'package:nctu/Routes/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Wait for AuthProvider to initialize
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    while (!authProvider.isInitialized) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Add a small delay for better UX
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    if (authProvider.isAuthenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AppRoutes()),
      );
    } else {
      // Navigate to login screen if not authenticated
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final logoHeight = size.height * 0.15;
    final spacing = size.height * 0.03;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/Logo png.png', height: logoHeight),
            SizedBox(height: spacing),
            const CircularProgressIndicator(color: Color(0xFF2563FF)),
          ],
        ),
      ),
    );
  }
}
