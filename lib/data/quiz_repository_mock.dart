// 데모용
import 'quiz_repository.dart';

class MockQuizRepository implements QuizRepository {
  @override
  Future<List<QuizItem>> fetchQuizItems() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      QuizItem(id: 1, type: 'OX', question: '지금은 여름이다.', answerKey: 'O'),
      QuizItem(
        id: 2, type: 'MULTI', question: '오늘은 무슨 요일인가요?',
        options: ['월요일', '화요일', '금요일', '토요일'], answerKey: '토요일',
      ),
      QuizItem(id: 3, type: 'SHORT', question: '당신의 이름은?', answerKey: '은진'),
      QuizItem(id: 4, type: 'OX', question: '플러터는 크로스 플랫폼이다.', answerKey: 'O'),
      QuizItem(
        id: 5, type: 'MULTI', question: 'Dart null-safety 관련 키워드?',
        options: ['late', 'var', 'null', 'safe'], answerKey: 'late',
      ),
      QuizItem(id: 6, type: 'SHORT', question: '가천대는 어느 도시에?', answerKey: '성남'),
      QuizItem(id: 7, type: 'OX', question: 'Stateless는 상태가 있다.', answerKey: 'X'),
      QuizItem(
        id: 8, type: 'MULTI', question: '상태관리 라이브러리가 아닌 것은?',
        options: ['Provider', 'Riverpod', 'GetX', 'jQuery'], answerKey: 'jQuery',
      ),
      QuizItem(id: 9, type: 'SHORT', question: '네 이름 첫 글자?', answerKey: '한'),
      QuizItem(id: 10, type: 'OX', question: 'Dart는 JS다.', answerKey: 'X'),
    ];
  }

  @override
  Future<QuizResult> grade({
    required List<QuizItem> items,
    required List<String?> userAnswers,
  }) async {
    int correct = 0;
    final detail = <bool>[];
    for (var i = 0; i < items.length; i++) {
      final right = (items[i].answerKey ?? '').trim();
      final user = (userAnswers[i] ?? '').trim();
      final ok = right.isNotEmpty ? right == user : false;
      detail.add(ok);
      if (ok) correct++;
    }
    return QuizResult(total: items.length, correct: correct, detail: detail);
  }
}
