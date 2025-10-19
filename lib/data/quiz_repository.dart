// lib/data/quiz_repository.dart

/// ===== 모델 =====
class QuizItem {
  final int id;
  final String type; // 'OX' | 'MULTI' | 'SHORT'
  final String question;
  final List<String> options; // MULTI 전용
  final String? answerKey;    // 정답(있다면)

  QuizItem({
    required this.id,
    required this.type,
    required this.question,
    this.options = const [],
    this.answerKey,
  });

  factory QuizItem.fromMap(Map<String, dynamic> m) => QuizItem(
    id: m['id'] as int,
    type: m['type'] as String,
    question: m['question'] as String,
    options:
    (m['options'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
        const [],
    answerKey: m['answerKey']?.toString(),
  );
}

class QuizResult {
  final int total;
  final int correct;
  final List<bool> detail;

  QuizResult({required this.total, required this.correct, required this.detail});

  double get rate => total == 0 ? 0 : correct / total;

  String get level {
    if (rate >= 0.8) return '고급';
    if (rate >= 0.5) return '중급';
    return '초급';
  }
}

/// ===== DB 연동용 인터페이스 =====
abstract class QuizRepository {
  Future<List<QuizItem>> fetchQuizItems();

  Future<QuizResult> grade({
    required List<QuizItem> items,
    required List<String?> userAnswers,
  });
}
