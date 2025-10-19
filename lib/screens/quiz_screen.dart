// lib/screens/quiz_screen.dart
import 'package:flutter/material.dart';

import '../data/quiz_repository.dart';
import '../data/quiz_repository_mock.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _repo = MockQuizRepository(); // ⛳️ DB 붙이면 교체
  List<QuizItem> _items = [];
  int _idx = 0;
  late List<String?> _answers;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // ##########################
    // [DB 데이터삽입부분] 문제 리스트를 DB에서 가져오기
    // 예) final list = await DBHelper.fetchQuizItems();
    // ##########################

    final list = await _repo.fetchQuizItems(); // 데모용
    _items = list.take(10).toList();
    _answers = List<String?>.filled(_items.length, null);
    setState(() => _loading = false);
  }

  void _setAnswer(String? v) => _answers[_idx] = v;

  Future<void> _finish() async {
    // ##########################
    // [DB 데이터삽입부분] 서버에서 채점/결과 받기
    // 예) final result = await DBHelper.grade(items: _items, answers: _answers);
    // ##########################

    final result = await _repo.grade(items: _items, userAnswers: _answers); // 데모

    if (!mounted) return;
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
            // 상단 헤더 + 질문 카드
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: const BoxDecoration(
                color: Color(0xFF7DB2FF),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 6),
                  const Text('📝 수준 진단 퀴즈',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text('${_idx + 1} / ${_items.length}',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6E6FA),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(q.question,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 유형별 본문 (위젯 3종을 이 파일 안에 구현)
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

            // 하단 네비 버튼
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _navButton('뒤로', () => Navigator.pop(context)),
                  const SizedBox(width: 8),
                  _navButton('이전 질문', () {
                    if (_idx > 0) setState(() => _idx--);
                  }),
                  const SizedBox(width: 8),
                  _navButton(_idx == _items.length - 1 ? '제출' : '다음 질문', () {
                    if (_idx < _items.length - 1) {
                      setState(() => _idx++);
                    } else {
                      _finish();
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
/// 아래부터: 이 파일 안에 포함된 문항 위젯 3종
/// =======================================

class _OXQuestion extends StatefulWidget {
  final ValueChanged<String?> onAnswer; // 'O' or 'X'
  const _OXQuestion({required this.onAnswer});

  @override
  State<_OXQuestion> createState() => _OXQuestionState();
}

class _OXQuestionState extends State<_OXQuestion> {
  String? selected;

  Widget _square(String label) {
    final isSel = selected == label;
    return GestureDetector(
      onTap: () {
        setState(() => selected = label);
        widget.onAnswer(selected);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          color: const Color(0xFFD6E6FA),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [if (isSel) const BoxShadow(blurRadius: 8, offset: Offset(0, 4))],
          border: Border.all(color: isSel ? const Color(0xFFE53935) : Colors.transparent, width: 2),
        ),
        alignment: Alignment.center,
        child: const Text('O / X', style: TextStyle(fontSize: 0)), // 접근성
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () { setState(() => selected = 'O'); widget.onAnswer('O'); },
              child: _tile('O', selected == 'O'),
            ),
            GestureDetector(
              onTap: () { setState(() => selected = 'X'); widget.onAnswer('X'); },
              child: _tile('X', selected == 'X'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _tile(String label, bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 110, height: 110,
      decoration: BoxDecoration(
        color: const Color(0xFFD6E6FA),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [if (active) const BoxShadow(blurRadius: 8, offset: Offset(0, 4))],
        border: Border.all(color: active ? const Color(0xFFE53935) : Colors.transparent, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(label, style: const TextStyle(fontSize: 48, color: Color(0xFFE53935))),
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
  void dispose() { _ctrl.dispose(); super.dispose(); }

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
