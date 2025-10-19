import 'package:flutter/material.dart';
import '../generated/a_launch.dart';

class SplashAScreen extends StatefulWidget {
  const SplashAScreen({super.key});
  @override
  State<SplashAScreen> createState() => _SplashAScreenState();
}

class _SplashAScreenState extends State<SplashAScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/launchB');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: const SingleChildScrollView(child: ALaunch()),
          ),
        ),
      ),
    );
  }
}
