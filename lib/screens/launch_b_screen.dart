import 'package:flutter/material.dart';
import '../generated/b_launch.dart';

class LaunchBScreen extends StatelessWidget {
  const LaunchBScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              child: BLaunch(
                onTapLogin: () => Navigator.pushNamed(context, '/login'),
                onTapSignUp: () => Navigator.pushNamed(context, '/signup'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
