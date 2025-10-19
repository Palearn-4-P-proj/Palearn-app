import 'package:flutter/material.dart';
import '../generated/login_signup_widgets.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              child: LoginWidget(
                // 🔹 회원가입으로 이동
                onTapSignUpText: () => Navigator.pushReplacementNamed(context, '/signup'),

                // 🔹 로그인 성공 시 홈으로 이동
                onTapLogin: () => Navigator.pushReplacementNamed(context, '/home'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
