import 'package:flutter/material.dart';
import 'package:nctu/Routes/routes.dart';
import 'package:nctu/provider/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:nctu/screens/signup.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.login(_userCtrl.text, _passCtrl.text);

    if (!mounted) return;

    if (success) {
      // Navigate to main route after successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AppRoutes()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Login failed'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final illustrationHeight = size.height * 0.22;
    final spacing = size.height * 0.03;
    final buttonHeight = size.height * 0.07;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: illustrationHeight,
                  child: Image.asset(
                    'assets/images/login.png',
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: spacing),
                Text(
                  'login',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: spacing * 0.25),
                Text(
                  'please sign in to continue',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: spacing),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _userCtrl,
                        decoration: InputDecoration(
                          hintText: 'User name',
                          prefixIcon: const Icon(Icons.person_outline),
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(fontSize: 16),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Username required' : null,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passCtrl,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        style: const TextStyle(fontSize: 16),
                        obscureText: _obscurePassword,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Password required' : null,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _handleLogin(),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: buttonHeight,
                        child: auth.loading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563FF),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'login',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: spacing),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have any account? ",
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SignUpScreen()),
                        );
                      },
                      child: Text(
                        'sign up',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF2563FF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
