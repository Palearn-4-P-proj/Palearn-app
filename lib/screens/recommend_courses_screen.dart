import 'package:flutter/material.dart';

class RecommendCoursesScreen extends StatefulWidget {
  const RecommendCoursesScreen({super.key});

  @override
  State<RecommendCoursesScreen> createState() => _RecommendCoursesScreenState();
}

class _RecommendCoursesScreenState extends State<RecommendCoursesScreen> {
  final _page = PageController(viewportFraction: 0.88);
  int _index = 0;

  List<Map<String, dynamic>> courses = [];

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {

    // =====================================================================
    // 🔵 [FastAPI GET 필요]
    // 사용자의 수준(level) 또는 퀴즈 결과를 기반으로 서버에서 추천 강좌 받아오기
    //
    // 예시 FastAPI:
    //   GET /recommend/courses?level=초급
    //
    // Flutter 예시:
    //   final res = await http.get(Uri.parse('$BASE/recommend/courses?level=$level'));
    //   final data = jsonDecode(res.body);
    //   courses = List<Map<String,dynamic>>.from(data);
    //
    // 현재는 DEMO 데이터 사용
    // =====================================================================

    await Future.delayed(const Duration(milliseconds: 300));

    courses = [
      {
        "id": "c1",
        "title": "딥러닝을 활용한 고급 이미지 처리",
        "provider": "부스트코스",
        "weeks": 6,
        "free": true,
        "summary": "딥러닝을 활용하여 고급 이미지 처리 기법을 학습합니다.",
        "syllabus": [
          "1강: 딥러닝 개요",
          "2강: CNN 이해",
          "3강: 분류 모델 구축",
          "4강: 전이학습",
          "5강: 세그멘테이션"
        ],
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

    // =====================================================================
    // 🔵 [FastAPI POST 필요 가능성]
    // 사용자가 어떤 강좌를 선택했는지를 서버에 기록해야 할 수 있음 (선택 로그)
    //
    // 예시 FastAPI:
    //   POST /recommend/select
    //   body:
    //   {
    //     "user_id": "...",
    //     "course_id": course["id"]
    //   }
    //
    // Flutter 예시:
    //   await http.post(
    //     Uri.parse('$BASE/recommend/select'),
    //     headers: {"Content-Type": "application/json"},
    //     body: jsonEncode({"course_id": course["id"]}),
    //   );
    //
    // 현재는 Navigator로 다음 화면 이동만 함
    // =====================================================================

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
            // ───────────── 헤더 + 뒤로가기 추가 ─────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: const BoxDecoration(
                color: Color(0xFF7DB2FF),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔙 뒤로가기 버튼
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),

                      // 오른쪽 균형 맞추기용 더미
                      Opacity(
                        opacity: 0,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  const Text('🎯 추천 강좌',
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  const Text('당신의 수준에 맞는 강좌를 추천드려요!',
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            // ────────────────────────────────────────────────

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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                courses.length,
                    (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin:
                  const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
                  height: 6,
                  width: _index == i ? 20 : 8,
                  decoration: BoxDecoration(
                    color: _index == i
                        ? const Color(0xFF7DB2FF)
                        : Colors.black12,
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
    final title = data['title'] ?? '';
    final provider = data['provider'] ?? '';
    final weeks = data['weeks'].toString();
    final free = (data['free'] ?? false) ? '무료' : '유료';
    final summary = data['summary'] ?? '';
    final syllabus = (data['syllabus'] as List?)?.cast<String>() ?? [];

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
                style:
                const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
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

            // 강의 리스트 박스
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
