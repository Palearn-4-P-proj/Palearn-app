// lib/data/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'quiz_repository.dart';

/// FastAPI 서버 URL - 실제 배포시 변경 필요
const String baseUrl = 'http://localhost:8000';

/// 인증 토큰 저장 (실제 앱에서는 flutter_secure_storage 사용 권장)
String? _authToken;

void setAuthToken(String token) {
  _authToken = token;
}

String? getAuthToken() => _authToken;

void clearAuthToken() {
  _authToken = null;
}

/// HTTP 헤더 생성
Map<String, String> _headers({bool withAuth = true}) {
  final headers = {'Content-Type': 'application/json'};
  if (withAuth && _authToken != null) {
    headers['Authorization'] = 'Bearer $_authToken';
  }
  return headers;
}

// ==================== 인증 API ====================

class AuthService {
  /// 회원가입
  static Future<Map<String, dynamic>> signup({
    required String username,
    required String email,
    required String password,
    required String name,
    required String birth,
    String? photoUrl,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: _headers(withAuth: false),
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'name': name,
        'birth': birth,
        'photo_url': photoUrl,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? '회원가입 실패');
    }
  }

  /// 로그인
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers(withAuth: false),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['token'] != null) {
        setAuthToken(data['token']);
      }
      return data;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? '로그인 실패');
    }
  }

  /// 로그아웃
  static Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: _headers(),
      );
    } finally {
      clearAuthToken();
    }
  }
}

// ==================== 프로필 API ====================

class ProfileService {
  /// 내 프로필 조회
  static Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile/me'),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('프로필 조회 실패');
    }
  }

  /// 프로필 업데이트
  static Future<bool> updateProfile({
    required String userId,
    String? email,
    String? name,
    String? birth,
    String? password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/profile/update'),
      headers: _headers(),
      body: jsonEncode({
        'user_id': userId,
        'email': email,
        'name': name,
        'birth': birth,
        'password': password,
      }),
    );

    return response.statusCode == 200;
  }
}

// ==================== 홈 API ====================

class HomeService {
  /// 홈 헤더 정보 조회
  static Future<Map<String, dynamic>> getHeader() async {
    final response = await http.get(
      Uri.parse('$baseUrl/home/header'),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('홈 데이터 조회 실패');
    }
  }

  /// 계획 목록 조회 (daily/weekly/monthly)
  static Future<List<String>> getPlans({String scope = 'daily'}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/plans?scope=$scope'),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => e.toString()).toList();
    } else {
      throw Exception('계획 조회 실패');
    }
  }

  /// 복습 항목 조회
  static Future<List<Map<String, dynamic>>> getReviewPlans() async {
    final response = await http.get(
      Uri.parse('$baseUrl/plans/review'),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception('복습 항목 조회 실패');
    }
  }
}

// ==================== 퀴즈 API ====================

class QuizService implements QuizRepository {
  /// 퀴즈 문제 조회
  @override
  Future<List<QuizItem>> fetchQuizItems({
    String skill = 'general',
    String level = '초급',
    int limit = 10,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/quiz/items?skill=$skill&level=$level&limit=$limit'),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => QuizItem.fromMap(e)).toList();
    } else {
      throw Exception('퀴즈 조회 실패');
    }
  }

  /// 퀴즈 채점
  @override
  Future<QuizResult> grade({
    required List<QuizItem> items,
    required List<String?> userAnswers,
  }) async {
    final answers = <Map<String, dynamic>>[];
    for (int i = 0; i < items.length; i++) {
      answers.add({
        'id': items[i].id,
        'userAnswer': userAnswers[i] ?? '',
      });
    }

    final response = await http.post(
      Uri.parse('$baseUrl/quiz/grade'),
      headers: _headers(),
      body: jsonEncode({'answers': answers}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return QuizResult(
        total: data['total'],
        correct: data['correct'],
        detail: (data['detail'] as List).map((e) => e as bool).toList(),
      );
    } else {
      throw Exception('채점 실패');
    }
  }
}

// ==================== 강좌 추천 API ====================

class RecommendService {
  /// AI 검색 상태 조회 (로딩 화면용)
  static Future<Map<String, dynamic>> getSearchStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/recommend/search_status'),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      // 실패해도 기본값 반환
    }
    return {'model': null, 'status': 'idle'};
  }

  /// 추천 강좌 조회
  static Future<List<Map<String, dynamic>>> getCourses({
    required String skill,
    required String level,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/recommend/courses?skill=$skill&level=$level'),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception('강좌 추천 실패');
    }
  }

  /// 강좌 선택
  static Future<bool> selectCourse({
    required String userId,
    required String courseId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/recommend/select'),
      headers: _headers(),
      body: jsonEncode({
        'user_id': userId,
        'course_id': courseId,
      }),
    );

    return response.statusCode == 200;
  }

  /// 추천 적용 (계획 생성)
  static Future<Map<String, dynamic>> applyRecommendation({
    required Map<String, dynamic> selectedCourse,
    required String quizLevel,
    required String skill,
    required double hourPerDay,
    required String startDate,
    required List<String> restDays,
    Map<String, dynamic>? quizDetails,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/plan/apply_recommendation'),
      headers: _headers(),
      body: jsonEncode({
        'selected_course': selectedCourse,
        'quiz_level': quizLevel,
        'skill': skill,
        'hourPerDay': hourPerDay,
        'startDate': startDate,
        'restDays': restDays,
        'quiz_details': quizDetails,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('계획 생성 실패');
    }
  }
}

// ==================== 학습 계획 API ====================

class PlanService {
  /// 계획 생성
  static Future<Map<String, dynamic>> generatePlan({
    required String skill,
    required double hourPerDay,
    required String startDate,
    required List<String> restDays,
    required String selfLevel,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/plans/generate'),
      headers: _headers(),
      body: jsonEncode({
        'skill': skill,
        'hourPerDay': hourPerDay,
        'startDate': startDate,
        'restDays': restDays,
        'selfLevel': selfLevel,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('계획 생성 실패');
    }
  }

  /// 특정 날짜의 상세 계획 조회
  static Future<Map<String, dynamic>> getPlansByDate({
    required String date,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/plans/date/$date'),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('계획 조회 실패');
    }
  }

  /// 태스크 상태 업데이트
  static Future<bool> updateTask({
    required String date,
    required String taskId,
    required bool completed,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/plans/task/update?date=$date&task_id=$taskId&completed=$completed'),
      headers: _headers(),
    );

    return response.statusCode == 200;
  }

  /// 내 모든 학습 계획 목록 조회
  static Future<List<Map<String, dynamic>>> getMyPlans() async {
    final response = await http.get(
      Uri.parse('$baseUrl/plans/all'),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception('계획 목록 조회 실패');
    }
  }

  /// 특정 주제에 대한 연관 자료 조회
  static Future<List<Map<String, dynamic>>> getRelatedMaterials({
    required String topic,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/plans/related_materials?topic=${Uri.encodeComponent(topic)}'),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return data.map((e) => e as Map<String, dynamic>).toList();
      } else if (data['materials'] is List) {
        return (data['materials'] as List).map((e) => e as Map<String, dynamic>).toList();
      }
      return [];
    } else {
      throw Exception('연관 자료 조회 실패');
    }
  }

  /// 어제 복습 자료 조회 (팝업용)
  static Future<Map<String, dynamic>> getYesterdayReview() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/plans/yesterday_review'),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      // 실패해도 기본값 반환
    }
    return {'has_review': false, 'materials': [], 'yesterday_topic': ''};
  }
}

// ==================== 친구 API ====================

class FriendsService {
  /// 친구 목록 조회
  static Future<List<Map<String, dynamic>>> getFriends() async {
    final response = await http.get(
      Uri.parse('$baseUrl/friends'),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception('친구 목록 조회 실패');
    }
  }

  /// 친구 추가
  static Future<Map<String, dynamic>> addFriend({required String code}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/friends/add'),
      headers: _headers(),
      body: jsonEncode({'code': code}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? '친구 추가 실패');
    }
  }

  /// 친구 계획 조회
  static Future<List<Map<String, dynamic>>> getFriendPlans({
    required String friendId,
    String? date,
  }) async {
    String url = '$baseUrl/friends/$friendId/plans';
    if (date != null) {
      url += '?date=$date';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception('친구 계획 조회 실패');
    }
  }

  /// 친구 계획 체크 (응원)
  static Future<bool> checkFriendPlan({
    required String friendId,
    required String planId,
    required bool done,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/friends/$friendId/plans/check'),
      headers: _headers(),
      body: jsonEncode({
        'planId': planId,
        'done': done,
      }),
    );

    return response.statusCode == 200;
  }
}

// ==================== 알림 API ====================

class NotificationService {
  /// 알림 조회
  static Future<Map<String, dynamic>> getNotifications() async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications'),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('알림 조회 실패');
    }
  }

  /// 알림 읽음 처리
  static Future<bool> markAsRead() async {
    final response = await http.post(
      Uri.parse('$baseUrl/notifications/read'),
      headers: _headers(),
    );

    return response.statusCode == 200;
  }
}

// ==================== 복습 자료 API ====================

class ReviewService {
  /// 어제 복습 자료 조회
  static Future<List<Map<String, dynamic>>> getYesterdayMaterials({
    String? userId,
  }) async {
    String url = '$baseUrl/review/yesterday';
    if (userId != null) {
      url += '?user_id=$userId';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception('복습 자료 조회 실패');
    }
  }
}
