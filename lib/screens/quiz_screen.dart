// lib/screens/quiz_screen.dart
import 'package:flutter/material.dart';

import '../data/quiz_repository.dart';
// 현재 Mock인데, 실제 FastAPI 연동 시 교체됨
import '../data/quiz_repository_mock.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {

  // ============================================================
  // ⛳ 현재는 Mock 저장소.
  // ❗❗ 실제 FastAPI 서버 연동 시에는
  //     final _repo = ApiQuizRepository();  로 교체해야 함.
  //
  // ApiQuizRepository는 GET/POST 구현:
  //   GET  /quizzes          → 문제 불러오기
  //   POST /quizzes/grade    → 채점 요청
  // ============================================================
  final _repo = MockQuizRepository(); // ⛳️ DB 붙이면 ApiQuizRepository() 로 교체

  List<QuizItem> _items = [];
  int _idx = 0;
  late List<String?> _answers;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ============================================================
  // 🔵 ① 퀴즈 문항 불러오기 (FastAPI GET 필요)
  //
  // 실제 API 예시:
  // GET /quiz?limit=10
  //
  // Flutter 예시:
  // final res = await http.get(Uri.parse('$BASE/quiz?limit=10'));
  // final data = jsonDecode(res.body);
  // _items = data.map((e)=>QuizItem.fromJson(e)).toList();
  //
  // 현재는 mock 사용 (테스트용)
  // ============================================================
  Future<void> _load() async {
    final list = await _repo.fetchQuizItems();  // ← 실제 GET API로 변경됨
    _items = list.take(10).toList();
    _answers = List<String?>.filled(_items.length, null);
    setState(() => _loading = false);
  }

  void _setAnswer(String? v) => _answers[_idx] = v;

  // ============================================================
  // 🔵 ② 채점 요청 (FastAPI POST 필요)
  //
  // 실제 API 예시:
  // POST /quiz/grade
  // body:
  // {
  //   "items": [...],
  //   "answers": [...]
  // }
  //
  // Flutter 예시:
  // final res = await http.post(
  //    Uri.parse('$BASE/quiz/grade'),
  //    headers: {"Content-Type":"application/json"},
  //    body: jsonEncode({
  //      "items": _items.map((e)=>e.toJson()).toList(),
  //      "answers": _answers,
  //    })
  // );
  // final result = QuizResult.fromJson(jsonDecode(res.body));
  //
  // 현재는 mock 사용 (로컬 채점)
  // ============================================================
  Future<void> _finish() async {
    final result = await _repo.grade(items: _items, userAnswers: _answers); // 실제는 POST API 호출
    if (!mounted) return;

    // 결과 화면으로 전달
    Navigator.pushNamed(context, '/quiz_result', arguments: {
      'level': result.level,
      'rate': result.rate,
      'details': result.detail,
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final q = _items[_idx];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FD),
      body: SafeArea(
        child: Column(
          children: [
            // ───────────── 헤더 + 뒤로가기 버튼 ─────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: const BoxDecoration(
                color: Color(0xFF7DB2FF),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      const Text(
                        '📝 수준 진단 퀴즈',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Opacity(
                        opacity: 0,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Text('${_idx + 1} / ${_items.length}',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),

                  // 질문 박스 UI
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6E6FA),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      q.question,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            // ────────────────────────────────────────────────

            const SizedBox(height: 18),

            // 문제 본문
            Expanded(
              child: Builder(
                builder: (_) {
                  switch (q.type) {
                    case 'OX':
                      return _OXQuestion(onAnswer: _setAnswer);
                    case 'MULTI':
                      return _MultiQuestion(options: q.options, onAnswer: _setAnswer);
                    case 'SHORT':
                      return _ShortQuestion(onAnswer: _setAnswer);
                    default:
                      return const Center(child: Text('유효하지 않은 질문 유형입니다.'));
                  }
                },
              ),
            ),

            // 하단 버튼 (이전 / 다음 / 제출)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _navButton('이전 질문', () {
                    if (_idx > 0) setState(() => _idx--);
                  }),
                  const SizedBox(width: 8),
                  _navButton(_idx == _items.length - 1 ? '제출' : '다음 질문', () {
                    if (_idx < _items.length - 1) {
                      setState(() => _idx++);
                    } else {
                      _finish();  // 🔵 여기에서 FastAPI POST 호출
                    }
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navButton(String label, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      onPressed: onTap,
      child: Text(label),
    );
  }
}

/// =======================================
/// 아래부터: 질문 위젯들 (서버 연동 전혀 필요 없음)
/// =======================================

class _OXQuestion extends StatefulWidget {
  final ValueChanged<String?> onAnswer; // 'O' or 'X'
  const _OXQuestion({required this.onAnswer});

  @override
  State<_OXQuestion> createState() => _OXQuestionState();
}

class _OXQuestionState extends State<_OXQuestion> {
  String? selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _tile('O'),
            _tile('X'),
          ],
        ),
      ],
    );
  }

  Widget _tile(String label) {
    final active = selected == label;
    return GestureDetector(
      onTap: () {
        setState(() => selected = label);
        widget.onAnswer(selected);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 110, height: 110,
        decoration: BoxDecoration(
          color: const Color(0xFFD6E6FA),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [if (active) const BoxShadow(blurRadius: 8, offset: Offset(0, 4))],
          border: Border.all(
            color: active ? const Color(0xFFE53935) : Colors.transparent,
            width: 2,
          ),
        ),
        alignment: Alignment.center,
        child: Text(label, style: const TextStyle(fontSize: 48, color: Color(0xFFE53935))),
      ),
    );
  }
}

class _MultiQuestion extends StatefulWidget {
  final List<String> options;
  final ValueChanged<String?> onAnswer;
  const _MultiQuestion({required this.options, required this.onAnswer});

  @override
  State<_MultiQuestion> createState() => _MultiQuestionState();
}

class _MultiQuestionState extends State<_MultiQuestion> {
  String? selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12),
      child: Wrap(
        spacing: 24, runSpacing: 16,
        children: widget.options.map((opt) {
          final isSel = selected == opt;
          return ChoiceChip(
            label: Text(opt),
            selected: isSel,
            onSelected: (_) {
              setState(() => selected = opt);
              widget.onAnswer(selected);
            },
          );
        }).toList(),
      ),
    );
  }
}

class _ShortQuestion extends StatefulWidget {
  final ValueChanged<String?> onAnswer;
  const _ShortQuestion({required this.onAnswer});

  @override
  State<_ShortQuestion> createState() => _ShortQuestionState();
}

class _ShortQuestionState extends State<_ShortQuestion> {
  final _ctrl = TextEditingController();
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: TextField(
        controller: _ctrl,
        decoration: InputDecoration(
          hintText: '답안을 입력하세요.',
          filled: true,
          fillColor: const Color(0xFFD6E6FA),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onChanged: widget.onAnswer,
      ),
    );
  }
}
