import 'package:flutter/material.dart';

const _blue = Color(0xFF7DB2FF);
const _blueLight = Color(0xFFE7F0FF);
const _ink = Color(0xFF0E3E3E);

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final TextEditingController _codeCtrl = TextEditingController();

  bool _loading = true;
  bool _adding = false;
  List<FriendSummary> _friends = [];

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    setState(() => _loading = true);

    // ##############################
    // [DB/API] 친구 목록 불러오기
    // 예)
    // final list = await FriendsAPI.fetchList(userId: me.id);
    // setState(() => _friends = list);
    // ##############################
    await Future.delayed(const Duration(milliseconds: 300)); // demo delay
    setState(() {
      _friends = []; // 초기엔 빈 목록 (실제에선 API 응답)
      _loading = false;
    });
  }

  Future<void> _addByCode() async {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) return;

    setState(() => _adding = true);

    // ##############################
    // [DB/API] 친구 추가 (코드로)
    // 예)
    // final ok = await FriendsAPI.addByCode(myId: me.id, code: code);
    // if (!mounted) return;
    // if (ok) {
    //   _codeCtrl.clear();
    //   await _loadFriends();
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('친구가 추가되었습니다.')),
    //   );
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('코드가 올바르지 않습니다.')),
    //   );
    // }
    // ##############################

    await Future.delayed(const Duration(milliseconds: 400)); // demo
    if (!mounted) return;
    _codeCtrl.clear();
    setState(() => _adding = false);
    // 데모: 목록 새로고침
    await _loadFriends();
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  void _openDetail(FriendSummary f) {
    Navigator.pushNamed(
      context,
      '/friend_detail',
      arguments: FriendDetailArgs(friendId: f.id, name: f.name),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FD),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadFriends,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              // 헤더
              Container(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                decoration: const BoxDecoration(
                  color: _blue,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
                ),
                child: Row(
                  children: [
                    const Text('친구',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pushNamed(context, '/notifications'),
                      icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 친구 추가
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _blueLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('친구 추가', style: TextStyle(color: _ink, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _codeCtrl,
                            decoration: InputDecoration(
                              hintText: '친구 코드 입력',
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 42,
                          child: ElevatedButton(
                            onPressed: _adding ? null : _addByCode,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _blue,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _adding
                                ? const SizedBox(
                              width: 16, height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                                : const Text('추가', style: TextStyle(color: Colors.white)),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // 친구 목록
              Container(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 4),
                decoration: BoxDecoration(
                  color: _blue,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('친구 목록',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                    const SizedBox(height: 8),
                    if (_loading)
                      const Padding(
                        padding: EdgeInsets.all(28.0),
                        child: Center(child: CircularProgressIndicator(color: Colors.white)),
                      )
                    else if (_friends.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(28.0),
                        child: Text('등록된 친구가 없습니다.',
                            style: TextStyle(color: Colors.white70)),
                      )
                    else
                      ..._friends.map((f) => _FriendTile(friend: f, onTap: () => _openDetail(f))),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== 모델 & 타일 =====

class FriendSummary {
  final String id;         // 고유 id
  final String name;       // 닉네임
  final String? avatarUrl; // 프로필 이미지 (nullable)
  final int todayRate;     // 오늘 달성률 (%)

  FriendSummary({
    required this.id,
    required this.name,
    required this.todayRate,
    this.avatarUrl,
  });
}

class _FriendTile extends StatelessWidget {
  const _FriendTile({required this.friend, required this.onTap});
  final FriendSummary friend;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 6),
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: Colors.white,
        backgroundImage: friend.avatarUrl != null ? NetworkImage(friend.avatarUrl!) : null,
        child: friend.avatarUrl == null ? const Icon(Icons.person, color: _blue) : null,
      ),
      title: Text(friend.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      subtitle: Text('달성률 ${friend.todayRate}%',
          style: const TextStyle(color: Colors.white70)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white),
      onTap: onTap,
    );
  }
}

// 상세 화면 arguments 전달용
class FriendDetailArgs {
  final String friendId;
  final String name;
  const FriendDetailArgs({required this.friendId, required this.name});
}
