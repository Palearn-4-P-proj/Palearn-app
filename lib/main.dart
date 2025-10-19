import 'package:flutter/material.dart';

// ── 기본 앱 화면들 ─────────────────────────────────────────────
import 'screens/splash_a.dart';
import 'screens/launch_b_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';

// ── 계획 생성 플로우 ───────────────────────────────────────────
import 'screens/create_plan_screen.dart';
import 'screens/loading_plan_screen.dart';

// ── 퀴즈/추천 플로우 ──────────────────────────────────────────
import 'screens/quiz_screen.dart';
import 'screens/quiz_result_screen.dart';
import 'screens/recommend_courses_screen.dart';
import 'screens/recommend_loading_screen.dart';

// ── 친구 플로우 ──────────────────────────────────────────────
import 'screens/friends_screen.dart';
import 'screens/friend_detail_screen.dart';

// ── 프로필 플로우 ────────────────────────────────────────────
import 'screens/profile_screen.dart';
import 'screens/profile_edit_screen.dart';

// ── 알림 화면 ────────────────────────────────────────────────
import 'screens/notifications_screen.dart'; // ✅ 반드시 추가

void main() => runApp(const AppRoot());

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF7DB2FF),
      ),
      home: const SplashAScreen(), // 앱 시작: 스플래시
      routes: {
        // ── 기본 플로우 ──
        '/launchB': (_) => const LaunchBScreen(),
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignUpScreen(),
        '/home': (_) => const HomeScreen(),

        // ── 계획 생성 플로우 ──
        '/create_plan': (_) => const CreatePlanScreen(),
        // 테스트용: const 제거(빌드 오류 방지)
        '/plan_loading': (_) => LoadingPlanScreen(
          skill: '딥러닝',
          hour: '1시간',
          start: DateTime(2025, 1, 1),
          restDays: const [],
          level: '초급(처음 배워요)',
        ),

        // ── 퀴즈/추천 플로우 ──
        '/quiz': (_) => const QuizScreen(),
        '/quiz_result': (_) => const QuizResultScreen(
          // 직접 진입 테스트용 (정상 플로우에서는 /quiz에서 arguments 전달)
          level: '중급',
          rate: 0.6,
          details: [true, false, true, true, false, true, false, true, true, true],
        ),
        '/recommend_courses': (_) => const RecommendCoursesScreen(),
        '/recommend_loading': (_) => const RecommendLoadingScreen(),

        // ── 친구 플로우 ──
        '/friends': (_) => const FriendsScreen(),
        '/friend_detail': (_) => const FriendDetailScreen(),

        // ── 프로필 플로우 ──
        '/profile': (_) => const ProfileScreen(),
        '/profile_edit': (_) => const ProfileEditScreen(),

        // ── 알림 플로우 ──
        '/notifications': (_) => const NotificationScreen(),
      }, // ✅ routes 닫기
    ); // ✅ MaterialApp 닫기
  }
}
