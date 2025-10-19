// lib/screens/recommend_loading_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();

    // arguments는 build 이후 안전하게 접근
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        selectedCourse = Map<String, dynamic>.from(args['selectedCourse'] ?? {});
      }
    });

    // 로딩 UI (실제론 API 완료 타이밍에 맞춰 이동)
    _timer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      setState(() => progress = (progress + 0.01).clamp(0.0, 1.0));
      if (progress >= 1.0) {
        t.cancel();
        _applyRecommendationAndGoHome();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _applyRecommendationAndGoHome() async {
    // ##########################
    // [DB/추천 API 연동]
    // - 퀴즈 결과/선택 강좌를 바탕으로 Daily/Weekly/Monthly 계획 생성 또는 업데이트
    // - 예)
    // await PlanAPI.applyRecommendation(
    //   selectedCourse: selectedCourse,
    //   quizLevel: quizLevel,
    //   quizDetails: quizDetails,
    // );
    // ##########################

    if (!mounted) return;

    // 홈으로 스택 정리 후 이동(이전 화면들 제거)
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).clamp(0, 100).toStringAsFixed(0);

    return WillPopScope(
      // 로딩 중 뒤로가기 방지(필요 시 false를 true로 변경)
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
