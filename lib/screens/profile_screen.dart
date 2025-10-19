import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool loading = true;
  String name = 'John Smith';
  String userId = '25030024';
  String photoUrl =
      'https://images.unsplash.com/photo-1603415526960-f7e0328d13a2?w=256&h=256&fit=crop';

  @override
  void initState() {
    super.initState();
    _loadMyProfile();
  }

  Future<void> _loadMyProfile() async {
    // ##########################
    // [DB 연동] 내 프로필 정보 조회
    // 예)
    // final me = await UserAPI.fetchMe();
    // name = me.name; userId = me.code; photoUrl = me.photoUrl;
    // ##########################
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() => loading = false);
  }

  void _logout() async {
    // ##########################
    // [인증 연동] 로그아웃 처리
    // await Auth.signOut();
    // ##########################
    if (!mounted) return;
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
            // 헤더
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF7DB2FF),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
              ),
              child: const Center(
                child: Text('Profile',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              ),
            ),

            // 프로필 카드
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
                          'openTab': 'settings', // 필요시 탭 구분
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
