import 'dart:async';
import 'package:flutter/material.dart';

const _ink = Color(0xFF0E3E3E);
const _blue = Color(0xFF7DB2FF);

class LoadingPlanScreen extends StatefulWidget {
  const LoadingPlanScreen({
    super.key,
    required this.skill,
    required this.hour,
    required this.start,
    required this.restDays,
    required this.level,
  });

  final String skill;
  final String hour;
  final DateTime start;
  final List<String> restDays;
  final String level;

  @override
  State<LoadingPlanScreen> createState() => _LoadingPlanScreenState();
}

class _LoadingPlanScreenState extends State<LoadingPlanScreen> {
  double progress = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // ##########################
    // [서버/LLM 준비 단계]
    // - 폼에서 받은 값으로 임시 세션/초기 설정 생성
    // - 퀴즈 문항 생성을 위한 컨텍스트 준비
    // 예)
    // await PlanAPI.createDraft(
    //   skill: widget.skill,
    //   hourPerDay: widget.hour,
    //   startDate: widget.start,
    //   restDays: widget.restDays,
    //   selfLevel: widget.level,
    // );
    // ##########################

    // 간단한 더미 로딩 (UI용). 실제로는 위 비동기 완료 시점에 맞춰 이동하세요.
    _timer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      setState(() => progress = (progress + 0.01).clamp(0.0, 1.0));
      if (progress >= 1.0) {
        t.cancel();

        // ##########################
        // [다음 단계로 이동]
        // 준비가 끝났다면 퀴즈 시작 화면으로 이동합니다.
        // ##########################
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/quiz');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round();
    return Scaffold(
      backgroundColor: const Color(0xFFEFF4FF),
      body: SafeArea(
        child: Column(
          children: [
            // 상단 흐린 헤더
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE7F0FF),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: const [
                  // 뒤로가기는 로딩 단계에선 막아두는 걸 권장 (실수 방지)
                  // 필요하면 GestureDetector로 교체해서 Navigator.pop 사용
                  Icon(Icons.menu_book_rounded, color: _ink, size: 18),
                  SizedBox(width: 6),
                  Text(
                    '새로운 학습 계획 만들기',
                    style: TextStyle(color: _ink, fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // 프로그레스 바
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  minHeight: 22,
                  value: progress,
                  color: _blue,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text('$percent%', style: const TextStyle(fontSize: 16, color: _ink)),
            const SizedBox(height: 18),
            const Text('AI가 열심히 작업 중입니다 …',
                style: TextStyle(fontSize: 16, color: _ink)),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}
