// lib/data/api_quiz_repository.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'quiz_repository.dart';

/// FastAPI와 직접 통신하는 실제 Repository
/// UI 코드(HomeScreen, QuizScreen 등)는 이 Repository만 바꿔 끼우면 그대로 동작함.
///
/// ⚠️ 본 파일에서 반드시 다뤄야 하는 두 가지 주요 API:
///   1) GET /quiz/items   → 문제 목록 가져오기
///   2) POST /quiz/grade  → 사용자가 제출한 답안 채점
///
/// 아래 코드에는 실제 통신이 필요한 지점을 TODO로 명확하게 표시해둠.
class APIQuizRepository implements QuizRepository {
  /// FastAPI 서버 주소
  final String baseUrl = "http://YOUR_FASTAPI_SERVER_ADDRESS";

  @override
  Future<List<QuizItem>> fetchQuizItems() async {
    // ================================================================
    // TODO: GET /quiz/items
    //
    // FastAPI로부터 문제 목록을 받아오는 HTTP GET 요청이 필요함.
    // 백엔드는 JSON 배열 형태로 문제 리스트를 반환해야 함.
    // 예:
    // [
    //   { "id": 1, "type": "OX", "question": "...", "options": [], "answerKey": "O" },
    //   { "id": 2, "type": "MULTI", "question": "...", "options": ["a","b"], "answerKey": "a" }
    // ]
    //
    // Flutter는 응답 JSON을 받아 QuizItem.fromMap으로 변환함.
    // ================================================================

    final url = Uri.parse('$baseUrl/quiz/items');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('문제 가져오기 실패');
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => QuizItem.fromMap(e)).toList();
  }

  @override
  Future<QuizResult> grade({
    required List<QuizItem> items,
    required List<String?> userAnswers,
  }) async {

    // 사용자가 제출한 답안 리스트 생성
    final payload = {
      "answers": [
        for (int i = 0; i < items.length; i++)
          {
            "id": items[i].id,
            "userAnswer": userAnswers[i] ?? ""
          }
      ]
    };

    // ========================================================================
    // TODO: POST /quiz/grade
    //
    // FastAPI로 사용자 답안을 보내 채점을 요청해야 함.
    // 전송 데이터(JSON):
    // {
    //   "answers": [
    //     { "id": 1, "userAnswer": "O" },
    //     { "id": 2, "userAnswer": "월요일" },
    //     ...
    //   ]
    // }
    //
    // FastAPI는 다음 형태의 JSON을 반환해야 함:
    // {
    //   "total": 10,
    //   "correct": 7,
    //   "detail": [true, false, ...]
    // }
    //
    // 이 응답을 QuizResult 객체로 변환해 UI로 전달.
    // ========================================================================

    final url = Uri.parse('$baseUrl/quiz/grade');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception('채점 요청 실패');
    }

    final Map<String, dynamic> result = jsonDecode(response.body);

    return QuizResult(
      total: result['total'] as int,
      correct: result['correct'] as int,
      detail: List<bool>.from(result['detail']),
    );
  }
}
