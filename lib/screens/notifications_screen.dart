import 'package:flutter/material.dart';

const _blue = Color(0xFF7DB2FF);
const _ink = Color(0xFF0E3E3E);
const _light = Color(0xFFF7F8FD);

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _loading = true;

  // ▶ 서버에서 받아올 데이터
  List<String> _newAlerts = [];
  List<String> _oldAlerts = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  // ===========================================================================
  // 🟦 [중요] 알림 불러오기 — FastAPI 연동이 필요한 부분 (GET 요청)
  //
  // GET /notifications?user_id=123
  //
  // 응답 예:
  // {
  //   "new_alerts": ["오늘의 계획은 ~~ 입니다.", "Amy 님의 친구 신청"],
  //   "old_alerts": ["Uni 님의 친구 신청"]
  // }
  //
  // Flutter에서는 token을 포함하여 Authorization 헤더로 요청해야 함:
  //
  // final res = await http.get(
  //   Uri.parse('$BASE_URL/notifications'),
  //   headers: {"Authorization": "Bearer $token"},
  // );
  //
  // 받아온 데이터 _newAlerts, _oldAlerts에 저장
  // ===========================================================================
  Future<void> _loadNotifications() async {
    // TODO: 실제 서버 통신 필요
    // 예)
    // final alerts = await NotificationAPI.getAlerts();
    // setState(() {
    //   _newAlerts = alerts.newAlerts;
    //   _oldAlerts = alerts.oldAlerts;
    //   _loading = false;
    // });

    // 🔸 현재는 데모용 더미 데이터
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() {
      _newAlerts = [
        '오늘의 계획은 ~~ 입니다.',
        '오늘이 끝나기까지 계획을 완성하세요!',
        'Amy 님의 친구 신청',
      ];
      _oldAlerts = [
        'Uni 님의 친구 신청',
      ];
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _light,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
          children: [
            // 상단 헤더
            Container(
              padding:
              const EdgeInsets.fromLTRB(20, 18, 20, 18),
              decoration: const BoxDecoration(
                color: _blue,
                borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(28)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '알림',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 새로운 알림
            const Row(
              children: [
                Icon(Icons.notifications_active_outlined,
                    color: _ink),
                SizedBox(width: 6),
                Text(
                  '새로운 알림',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: _ink,
                  ),
                ),
              ],
            ),
            const Divider(
                height: 24, color: Colors.black45),

            if (_newAlerts.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('새로운 알림이 없습니다.',
                    style:
                    TextStyle(color: Colors.black54)),
              )
            else
              ..._newAlerts
                  .map(
                    (e) => Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0),
                  child: Text(
                    e,
                    style: const TextStyle(
                        color: _ink, fontSize: 15),
                  ),
                ),
              )
                  .toList(),

            const SizedBox(height: 24),
            const Divider(
                height: 32, color: Colors.black45),

            // 이전 알림
            const Row(
              children: [
                Icon(Icons.notifications_none_rounded,
                    color: _ink),
                SizedBox(width: 6),
                Text(
                  '이전 알림',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: _ink,
                  ),
                ),
              ],
            ),
            const Divider(
                height: 24, color: Colors.black45),

            if (_oldAlerts.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('이전 알림이 없습니다.',
                    style:
                    TextStyle(color: Colors.black54)),
              )
            else
              ..._oldAlerts
                  .map(
                    (e) => Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0),
                  child: Text(
                    e,
                    style: const TextStyle(
                        color: Colors.black54),
                  ),
                ),
              )
                  .toList(),
          ],
        ),
      ),
    );
  }
}
