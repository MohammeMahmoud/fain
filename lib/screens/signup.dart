import 'package:flutter/material.dart';
import 'package:nctu/Routes/routes.dart';
import 'package:nctu/provider/auth_provider.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _gradeCtrl = TextEditingController();
  final _sectionCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  String? _gender;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    _gradeCtrl.dispose();
    _sectionCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (_gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your gender'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.signup(
      username: _userCtrl.text,
      password: _passCtrl.text,
      grade: _gradeCtrl.text,
      section: _sectionCtrl.text,
      code: _codeCtrl.text,
      gender: _gender!,
    );

    if (!mounted) return;

    if (success) {
      // Navigate to main route after successful signup and auto-login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AppRoutes()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Registration failed'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final illustrationHeight = size.height * 0.20;
    final spacing = size.height * 0.025;
    final buttonHeight = size.height * 0.065;
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
                    'assets/images/sign_up.png',
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: spacing),
                Text(
                  'Register',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: spacing * 0.5),
                Text(
                  'please Register to login',
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
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passCtrl,
                        decoration: InputDecoration(
                          hintText: 'Password',
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
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _gradeCtrl,
                              decoration: InputDecoration(
                                hintText: 'Grade',
                                filled: true,
                                fillColor: const Color(0xFFF5F5F5),
                                contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              style: const TextStyle(fontSize: 16),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Grade required' : null,
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _sectionCtrl,
                              decoration: InputDecoration(
                                hintText: 'Section',
                                filled: true,
                                fillColor: const Color(0xFFF5F5F5),
                                contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              style: const TextStyle(fontSize: 16),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Section required' : null,
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _codeCtrl,
                              decoration: InputDecoration(
                                hintText: 'code',
                                filled: true,
                                fillColor: const Color(0xFFF5F5F5),
                                contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              style: const TextStyle(fontSize: 16),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Code required' : null,
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('gender', style: TextStyle(fontSize: 16, color: Colors.grey)),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Radio<String>(
                                          value: 'Male',
                                          groupValue: _gender,
                                          onChanged: (val) => setState(() => _gender = val),
                                        ),
                                        Flexible(child: Text('Male', overflow: TextOverflow.ellipsis)),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Radio<String>(
                                          value: 'Female',
                                          groupValue: _gender,
                                          onChanged: (val) => setState(() => _gender = val),
                                        ),
                                        Flexible(child: Text('Female', overflow: TextOverflow.ellipsis)),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: buttonHeight,
                        child: ElevatedButton(
                          onPressed: _handleSignUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Sign up',
                            style: TextStyle(
                              fontSize: 22,
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
                      'Already have account ',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'login',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.blue,
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