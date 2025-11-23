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

    // ======================================================================
    // TODO(백엔드 연동 필요, POST):
    // ⚡ "사용자가 입력한 학습 정보로 학습 계획 생성 요청"을 FastAPI에 보내는 단계
    //
    // 예시 엔드포인트:
    // POST /plans/generate
    //
    // body:
    // {
    //   "skill": widget.skill,
    //   "hourPerDay": widget.hour,
    //   "startDate": widget.start.toIso8601String(),
    //   "restDays": widget.restDays,
    //   "selfLevel": widget.level
    // }
    //
    // 서버 역할:
    // - AI 모델 또는 규칙 기반 로직으로 학습 계획 생성
    // - 생성 완료 후 /plans API로 사용자가 조회할 수 있도록 저장
    //
    // 현재는 실제 POST 요청이 없고, 아래 progress 타이머만 UI용으로 동작 중.
    // 실제 서비스에서는 이 부분을 await로 처리한 뒤 다음 화면으로 이동해야 함.
    // ======================================================================

    // (실제 구현 예)
    // await PlanAPI.createPlan(
    //   skill: widget.skill,
    //   hourPerDay: widget.hour,
    //   startDate: widget.start,
    //   restDays: widget.restDays,
    //   level: widget.level,
    // );

    // UI용 더미 로딩 (POST 요청 완료 타이밍을 시뮬레이션)
    _timer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      setState(() => progress = (progress + 0.01).clamp(0.0, 1.0));
      if (progress >= 1.0) {
        t.cancel();

        // ======================================================================
        // TODO(백엔드 연동 필요 없음):
        // 단순히 학습 계획 생성이 완료되면 퀴즈 화면으로 이동하는 기능입니다.
        //
        // 서버 요청은 위 POST에서 이미 처리됨.
        // ======================================================================

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
            // 상단 헤더
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

            // 진행바
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
