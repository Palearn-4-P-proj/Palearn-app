import 'package:flutter/material.dart';

class RecommendCoursesScreen extends StatefulWidget {
  const RecommendCoursesScreen({super.key});

  @override
  State<RecommendCoursesScreen> createState() => _RecommendCoursesScreenState();
}

class _RecommendCoursesScreenState extends State<RecommendCoursesScreen> {
  final _page = PageController(viewportFraction: 0.88);
  int _index = 0;

  // 데모용 더미 데이터 (LLM/DB 연결 시 교체)
  List<Map<String, dynamic>> courses = [];

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    // ##########################
    // [LLM/DB 호출 지점]
    // 퀴즈 결과(등급/정오표 등)를 서버/LLM으로 보내 여러 강좌 추천을 받아온다.
    // 예)
    // courses = await RecommendAPI.fetchCourses(level, detail);
    // 각 item 예시 {
    //   "title": "...", "provider":"...", "weeks":6, "free":true,
    //   "summary":"...", "syllabus":[...], "id":"course_123"
    // }
    // ##########################

    await Future.delayed(const Duration(milliseconds: 300));
    courses = [
      {
        "id": "c1",
        "title": "딥러닝을 활용한 고급 이미지 처리",
        "provider": "부스트코스",
        "weeks": 6,
        "free": true,
        "summary": "딥러닝을 활용하여 고급 이미지 처리 기법을 학습합니다.",
        "syllabus": ["1강: 딥러닝 개요", "2강: CNN 이해", "3강: 분류 모델 구축", "4강: 전이학습", "5강: 세그멘테이션"],
      },
      {
        "id": "c2",
        "title": "파이썬 데이터 분석 A-Z",
        "provider": "Inflearn",
        "weeks": 4,
        "free": false,
        "summary": "Pandas로 시작하는 데이터 전처리와 시각화.",
        "syllabus": ["1강: Numpy/Pandas", "2강: EDA", "3강: 시각화", "4강: 리포팅"],
      },
      {
        "id": "c3",
        "title": "기초 수학 리프레시",
        "provider": "K-MOOC",
        "weeks": 5,
        "free": true,
        "summary": "미분·확률 기초를 다시 탄탄히.",
        "syllabus": ["1강: 함수", "2강: 미분", "3강: 적분", "4강: 확률", "5강: 통계 기초"],
      },
    ];
    setState(() {});
  }

  void _selectCourse(Map<String, dynamic> course) {
    Navigator.pushNamed(
      context,
      '/recommend_loading',
      arguments: {"selectedCourse": course},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FD),
      body: SafeArea(
        child: Column(
          children: [
            // 상단 헤더
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: const BoxDecoration(
                color: Color(0xFF7DB2FF),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🎯 추천 강좌', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  SizedBox(height: 6),
                  Text('당신의 수준에 맞는 강좌를 추천드려요!', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (courses.isEmpty)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              Expanded(
                child: PageView.builder(
                  controller: _page,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemCount: courses.length,
                  itemBuilder: (_, i) => _CourseCard(
                    data: courses[i],
                    onSelect: () => _selectCourse(courses[i]),
                  ),
                ),
              ),

            const SizedBox(height: 12),
            // 인디케이터
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                courses.length,
                    (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
                  height: 6,
                  width: _index == i ? 20 : 8,
                  decoration: BoxDecoration(
                    color: _index == i ? const Color(0xFF7DB2FF) : Colors.black12,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onSelect;
  const _CourseCard({required this.data, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final title = data['title']?.toString() ?? '';
    final provider = data['provider']?.toString() ?? '';
    final weeks = data['weeks']?.toString() ?? '-';
    final free = (data['free'] ?? false) ? '무료' : '유료';
    final summary = data['summary']?.toString() ?? '';
    final syllabus = (data['syllabus'] as List?)?.cast<String>() ?? const [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFCCDAFF),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Row(
              children: [
                Text('강좌  $provider  ·  ${syllabus.length}개 강의  ·  ${weeks}주  ·  $free',
                    style: const TextStyle(color: Colors.black54)),
              ],
            ),
            const SizedBox(height: 12),
            Text(summary, style: const TextStyle(color: Colors.black87)),
            const SizedBox(height: 14),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFBFD0FF),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ListView.builder(
                  itemCount: syllabus.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text('• ${syllabus[i]}'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onSelect,
                child: const Text('선택하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
