// lib/screens/recommend_loading_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../data/api_service.dart';

const _ink = Color(0xFF0E3E3E);

class RecommendLoadingScreen extends StatefulWidget {
  const RecommendLoadingScreen({super.key});

  @override
  State<RecommendLoadingScreen> createState() => _RecommendLoadingScreenState();
}

class _RecommendLoadingScreenState extends State<RecommendLoadingScreen> {
  double progress = 0.0;
  Timer? _timer;

  // 선택한 강좌(있다면)
  Map<String, dynamic>? selectedCourse;
  String _skill = 'general';
  String _level = '초급';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        selectedCourse = Map<String, dynamic>.from(args['selectedCourse'] ?? {});
        _skill = args['skill']?.toString() ?? 'general';
        _level = args['level']?.toString() ?? '초급';
      }
      _applyRecommendation();
    });
  }

  Future<void> _applyRecommendation() async {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      if (mounted) {
        setState(() => progress = (progress + 0.005).clamp(0.0, 0.9));
      }
    });

    try {
      if (selectedCourse != null) {
        await RecommendService.applyRecommendation(
          selectedCourse: selectedCourse!,
          quizLevel: _level,
          skill: _skill,
          hourPerDay: 1.0,
          startDate: DateTime.now().toIso8601String(),
          restDays: [],
        );
      }

      _timer?.cancel();
      if (!mounted) return;
      setState(() => progress = 1.0);
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } catch (e) {
      debugPrint('Error applying recommendation: $e');
      _timer?.cancel();
      if (!mounted) return;
      setState(() => progress = 1.0);
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).clamp(0, 100).toStringAsFixed(0);

    return WillPopScope(
      // 로딩 중 뒤로가기 방지(필요하면 true로 변경 가능)
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FD),
        body: SafeArea(
          child: Column(
            children: [
              // 상단 헤더
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                decoration: const BoxDecoration(
                  color: Color(0xFFE7F0FF),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
                ),
                child: const Row(
                  children: [
                    SizedBox(width: 8),
                    Text(
                      '📘 새로운 학습 계획 만들기',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black38,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 80),

              // 로딩바
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 20,
                    backgroundColor: const Color(0xFFEAECEF),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text('$percent%', style: const TextStyle(fontSize: 16, color: Colors.black54)),
              const SizedBox(height: 18),
              const Text('AI가 열심히 작업 중입니다 …',
                  style: TextStyle(fontSize: 16, color: _ink)),
            ],
          ),
        ),
      ),
    );
  }
}
