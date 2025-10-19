import 'package:flutter/material.dart';
import '../generated/login_signup_widgets.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              child: CreateAccountWidget(
                onTapBackToLogin: () => Navigator.pushReplacementNamed(context, '/login'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
