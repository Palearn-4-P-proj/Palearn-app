import 'package:flutter/material.dart';
// 📌 백엔드 연동 시 필요한 import
// import 'package:http/http.dart' as http;
// import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool loading = true;

  // ▶ 서버에서 불러와야 할 실제 내 프로필 정보
  String name = 'John Smith';
  String userId = '25030024';
  String photoUrl =
      'https://images.unsplash.com/photo-1603415526960-f7e0328d13a2?w=256&h=256&fit=crop';

  @override
  void initState() {
    super.initState();
    _loadMyProfile();
  }

  // =========================================================================
  // 🟦 [중요] 프로필 불러오기 — FastAPI GET 필요
  //
  // GET /profile/me  또는  GET /profile/{user_id}
  //
  // 응답 예:
  // {
  //   "name": "한은진",
  //   "user_id": "25030024",
  //   "photo_url": "https://...",
  // }
  //
  // Flutter 예:
  // final res = await http.get(Uri.parse('$BASE/profile/me'),
  //     headers: {"Authorization": "Bearer $token"});
  // final data = json.decode(res.body);
  //
  // setState(() {
  //   name = data["name"];
  //   userId = data["user_id"];
  //   photoUrl = data["photo_url"];
  // });
  //
  // =========================================================================
  Future<void> _loadMyProfile() async {
    await Future.delayed(const Duration(milliseconds: 200));

    // TODO: 여기를 실제 GET API로 교체해야 함

    setState(() => loading = false);
  }

  // =========================================================================
  // 🟦 [중요] 로그아웃 — FastAPI POST 필요 (토큰 제거 or 세션 만료)
  //
  // POST /auth/logout
  //
  // Flutter 예:
  // await http.post(Uri.parse('$BASE/auth/logout'),
  //      headers: {"Authorization": "Bearer $token"});
  //
  // 그리고 local storage에서 토큰 삭제:
  // await storage.delete(key: 'token');
  //
  // =========================================================================
  void _logout() async {
    // TODO: 서버 로그아웃 API 연동 필요

    if (!mounted) return;

    // 클라이언트 이동 처리
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FD),
      body: SafeArea(
        child: Column(
          children: [
            // ─────────── 🔥 뒤로가기 버튼 포함 헤더 ───────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF7DB2FF),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),

                  const Spacer(),

                  const Text(
                    'Profile',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),

                  const Spacer(),

                  // 오른쪽 더미 아이콘 (정렬용)
                  Opacity(
                    opacity: 0,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),

            // ─────────── 프로필 카드 ───────────
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: Column(
                  children: [
                    CircleAvatar(radius: 48, backgroundImage: NetworkImage(photoUrl)),
                    const SizedBox(height: 12),
                    Text(name,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text('ID: $userId',
                        style: const TextStyle(color: Colors.black54)),

                    const SizedBox(height: 28),

                    _menuTile(
                      icon: Icons.person_outline_rounded,
                      label: '프로필 수정',
                      onTap: () {
                        Navigator.pushNamed(context, '/profile_edit', arguments: {
                          'name': name,
                          'userId': userId,
                          'photoUrl': photoUrl,
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    _menuTile(
                      icon: Icons.settings_outlined,
                      label: '설정',
                      onTap: () {
                        Navigator.pushNamed(context, '/profile_edit', arguments: {
                          'name': name,
                          'userId': userId,
                          'photoUrl': photoUrl,
                          'openTab': 'settings',
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    _menuTile(
                      icon: Icons.logout_rounded,
                      label: 'Logout',
                      onTap: _logout,
                      danger: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool danger = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFE0ECFF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF7DB2FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text(label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: danger ? const Color(0xFFE53935) : Colors.black,
                )),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}
