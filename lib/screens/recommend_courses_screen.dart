import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/api_service.dart';

const Color _ink = Color(0xFF0E3E3E);
const Color _blue = Color(0xFF7DB2FF);
const Color _blueLight = Color(0xFFE7F0FF);

class RecommendCoursesScreen extends StatefulWidget {
  const RecommendCoursesScreen({super.key});

  @override
  State<RecommendCoursesScreen> createState() => _RecommendCoursesScreenState();
}

class _RecommendCoursesScreenState extends State<RecommendCoursesScreen> {
  List<Map<String, dynamic>> courses = [];
  String _skill = 'general';
  String _level = '초급';
  bool _loading = true;
  String _searchModel = '';
  String _searchStatus = 'idle';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loading) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        _skill = args['skill']?.toString() ?? 'general';
        _level = args['level']?.toString() ?? '초급';
      }
      _loadRecommendations();
    }
  }

  Future<void> _pollSearchStatus() async {
    // 검색 상태를 주기적으로 확인
    while (_loading && mounted) {
      try {
        final status = await RecommendService.getSearchStatus();
        if (mounted) {
          setState(() {
            _searchModel = status['model']?.toString() ?? '';
            _searchStatus = status['status']?.toString() ?? 'idle';
          });
        }
      } catch (e) {
        // 무시
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  Future<void> _loadRecommendations() async {
    // 상태 폴링 시작
    _pollSearchStatus();

    try {
      final data = await RecommendService.getCourses(
        skill: _skill,
        level: _level,
      );
      if (mounted) {
        setState(() {
          courses = data;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading recommendations: $e');
      if (mounted) {
        setState(() {
          courses = [];
          _loading = false;
        });
      }
    }
  }

  void _selectCourse(Map<String, dynamic> course) async {
    try {
      await RecommendService.selectCourse(
        userId: '',
        courseId: course['id']?.toString() ?? '',
      );
    } catch (e) {
      debugPrint('Error selecting course: $e');
    }

    if (!mounted) return;
    Navigator.pushNamed(
      context,
      '/recommend_loading',
      arguments: {
        "selectedCourse": course,
        "skill": _skill,
        "level": _level,
      },
    );
  }

  // 상세 정보 다이얼로그 표시
  void _showCourseDetail(Map<String, dynamic> course) {
    final title = course['title'] ?? '제목 없음';
    final provider = course['provider'] ?? '알 수 없음';
    final instructor = course['instructor'] ?? '';
    final type = course['type'] ?? 'course';
    final weeks = course['weeks']?.toString() ?? '-';
    final free = (course['free'] ?? false) ? '무료' : '유료';
    final summary = course['summary'] ?? '';
    final price = course['price'] ?? '가격 정보 없음';
    final link = course['link'] ?? '';
    final rating = course['rating']?.toString() ?? '';
    final students = course['students']?.toString() ?? '';
    final duration = course['duration']?.toString() ?? '';
    final levelDetail = course['level_detail']?.toString() ?? '';
    final reason = course['reason']?.toString() ?? '';
    final curriculum = (course['curriculum'] as List?)?.cast<String>() ??
        (course['syllabus'] as List?)?.cast<String>() ??
        [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // 드래그 핸들
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // 콘텐츠
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // 타입 배지
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: type == 'book'
                                ? Colors.orange[100]
                                : _blueLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            type == 'book' ? '📚 도서' : '🎓 강좌',
                            style: TextStyle(
                              color:
                                  type == 'book' ? Colors.orange[800] : _blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: free == '무료'
                                ? Colors.green[100]
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            free,
                            style: TextStyle(
                              color: free == '무료'
                                  ? Colors.green[800]
                                  : Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 제목
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _ink,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // 제공자 & 강사
                    Row(
                      children: [
                        const Icon(Icons.business, size: 18, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          provider,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        if (instructor.isNotEmpty) ...[
                          const Text(' · ', style: TextStyle(color: Colors.grey)),
                          const Icon(Icons.person, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            instructor,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),

                    // 평점 & 수강생
                    if (rating.isNotEmpty || students.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (rating.isNotEmpty) ...[
                            const Icon(Icons.star, size: 18, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              rating,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: _ink,
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                          if (students.isNotEmpty) ...[
                            const Icon(Icons.people, size: 18, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              students,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                          if (duration.isNotEmpty) ...[
                            const SizedBox(width: 16),
                            const Icon(Icons.schedule, size: 18, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              duration,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],

                    // 레벨 태그
                    if (levelDetail.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.trending_up, size: 16, color: Colors.green[700]),
                            const SizedBox(width: 6),
                            Text(
                              levelDetail,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.green[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // 추천 이유
                    if (reason.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.amber[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber[200]!),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.lightbulb_outline, size: 20, color: Colors.amber[700]),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '추천 이유',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber[800],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    reason,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.amber[900],
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // 정보 카드들
                    Row(
                      children: [
                        Expanded(
                          child: _infoCard('학습 기간', '${weeks}주'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _infoCard('강의 수', '${curriculum.length}개'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _infoCard('가격', price),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // 설명
                    const Text(
                      '소개',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        summary.isNotEmpty ? summary : '설명이 없습니다.',
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 커리큘럼 (상세 강의 목록)
                    if (curriculum.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(Icons.list_alt, color: _blue, size: 22),
                          const SizedBox(width: 8),
                          const Text(
                            '커리큘럼',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _ink,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _blueLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '총 ${curriculum.length}강',
                              style: const TextStyle(
                                fontSize: 12,
                                color: _blue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 강의 목록 - 확장 가능한 상세 뷰
                      ...curriculum.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final item = entry.value;
                        // 강의 제목에서 세부 정보 추출 시도
                        final isSection = item.startsWith('섹션') ||
                            item.startsWith('Section') ||
                            item.startsWith('Part');

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: isSection
                                ? const Color(0xFF5A9BF6)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: isSection
                                ? null
                                : Border.all(color: Colors.grey.shade200),
                            boxShadow: isSection
                                ? null
                                : [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(8),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () {},
                              child: Padding(
                                padding: EdgeInsets.all(isSection ? 14 : 16),
                                child: Row(
                                  children: [
                                    if (!isSection)
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF7DB2FF),
                                              Color(0xFF5A9BF6)
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '${idx + 1}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    if (!isSection) const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item,
                                            style: TextStyle(
                                              fontSize: isSection ? 15 : 14,
                                              fontWeight: isSection
                                                  ? FontWeight.bold
                                                  : FontWeight.w500,
                                              color: isSection
                                                  ? Colors.white
                                                  : _ink,
                                            ),
                                          ),
                                          if (!isSection) ...[
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.play_circle_outline,
                                                  size: 14,
                                                  color: Colors.grey[500],
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '영상 강의',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[500],
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Icon(
                                                  Icons.access_time,
                                                  size: 14,
                                                  color: Colors.grey[500],
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '약 ${10 + (idx * 5) % 30}분',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[500],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    if (!isSection)
                                      const Icon(
                                        Icons.chevron_right,
                                        color: Colors.grey,
                                        size: 20,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],

                    const SizedBox(height: 24),

                    // 버튼들
                    Row(
                      children: [
                        // 링크 복사 버튼
                        if (link.isNotEmpty)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: link));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('링크가 클립보드에 복사되었습니다!'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.copy, size: 18),
                              label: const Text('링크 복사'),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        if (link.isNotEmpty) const SizedBox(width: 12),

                        // 선택 버튼
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _selectCourse(course);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              '이 강좌로 학습하기',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: _blueLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _ink,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FD),
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 20),
              decoration: const BoxDecoration(
                color: _blue,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '추천 강좌 & 도서',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$_skill · $_level 수준에 맞는 콘텐츠',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 리스트
            Expanded(
              child: _loading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 20),
                          if (_searchModel.isNotEmpty) ...[
                            Text(
                              _searchStatus == 'searching'
                                  ? '$_searchModel 검색 중...'
                                  : _searchStatus == 'completed'
                                      ? '$_searchModel 완료'
                                      : _searchModel,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          Text(
                            _searchStatus == 'searching'
                                ? 'AI가 최적의 강좌를 찾고 있습니다'
                                : _searchStatus == 'completed'
                                    ? '결과를 불러오는 중...'
                                    : '잠시만 기다려주세요',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : courses.isEmpty
                      ? const Center(
                          child: Text(
                            '추천할 강좌가 없습니다.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: courses.length,
                          itemBuilder: (_, i) => _CourseListItem(
                            data: courses[i],
                            onTap: () => _showCourseDetail(courses[i]),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseListItem extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;

  const _CourseListItem({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final title = data['title'] ?? '제목 없음';
    final provider = data['provider'] ?? '';
    final type = data['type'] ?? 'course';
    final free = (data['free'] ?? false);
    final summary = data['summary'] ?? '';
    final curriculum = (data['curriculum'] as List?)?.cast<String>() ??
        (data['syllabus'] as List?)?.cast<String>() ??
        [];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 배지
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: type == 'book' ? Colors.orange[50] : _blueLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    type == 'book' ? '📚 도서' : '🎓 강좌',
                    style: TextStyle(
                      fontSize: 12,
                      color: type == 'book' ? Colors.orange[700] : _blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (free)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '무료',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const Spacer(),
                Text(
                  provider,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 제목
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: _ink,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            if (summary.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                summary,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 12),

            // 하단 정보
            Row(
              children: [
                const Icon(Icons.play_circle_outline, size: 16, color: _blue),
                const SizedBox(width: 4),
                Text(
                  '${curriculum.length}개 콘텐츠',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Spacer(),
                const Text(
                  '자세히 보기 →',
                  style: TextStyle(
                    fontSize: 12,
                    color: _blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
