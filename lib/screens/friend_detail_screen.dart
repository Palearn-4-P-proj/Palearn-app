import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'friends_screen.dart';

const _ink = Color(0xFF0E3E3E);
const _blue = Color(0xFF7DB2FF);

class FriendDetailScreen extends StatefulWidget {
  const FriendDetailScreen({super.key});

  @override
  State<FriendDetailScreen> createState() => _FriendDetailScreenState();
}

class _FriendDetailScreenState extends State<FriendDetailScreen> {
  late FriendDetailArgs _args;

  bool _loading = true;
  DateTime _focused = DateTime.now();
  DateTime _selected = DateTime.now();

  List<CheckItem> _dayItems = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _args = ModalRoute.of(context)!.settings.arguments as FriendDetailArgs;
    _loadDay(_selected);
  }

  Future<void> _loadDay(DateTime day) async {
    setState(() => _loading = true);

    // ================================================================
    // TODO(백엔드 연동 필요, GET):
    // FastAPI에서 친구의 날짜별 학습 계획을 받아와야 하는 부분.
    //
    // GET /friends/{friendId}/plans?date=yyyy-mm-dd
    //
    // - 달력에서 날짜를 클릭할 때마다 호출됨
    // - 서버에서 해당 날짜의 계획 리스트를 JSON으로 받아와
    //   CheckItem(id, title, done) 리스트로 변환해야 함
    //
    // ex 응답:
    // [
    //   {"id": "1", "title": "딥러닝 공부", "done": false},
    //   {"id": "2", "title": "코딩테스트 1문제", "done": true}
    // ]
    //
    // 현재는 더미로 빈 리스트 넣고 있음 → 실제 서비스에서는 반드시 GET 요청 필요
    // ================================================================

    await Future.delayed(const Duration(milliseconds: 250));

    setState(() {
      _dayItems = [];   // ← 실제 FastAPI GET 결과 리스트로 대체되어야 함
      _loading = false;
    });
  }

  Future<void> _toggleItem(CheckItem item, bool value) async {
    setState(() => item.done = value);

    // ================================================================
    // TODO(백엔드 연동 필요, POST 또는 PATCH):
    // 체크박스를 변경할 때 그 변경 사항을 서버(FastAPI)에 저장해야 하는 부분.
    //
    // POST /friends/{friendId}/plans/check
    // body:
    // {
    //   "planId": item.id,
    //   "done": value
    // }
    //
    // - 완료 여부를 서버 DB에 반영해야 데이터가 유지됨
    // - 현재는 UI 상태만 변경 → 실제 서비스에서는 반드시 POST/PATCH 필요
    // ================================================================
  }

  @override
  Widget build(BuildContext context) {
    final ym = '${_focused.year}년 ${_focused.month}월';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.black87,
          onPressed: () => Navigator.pop(context),
        ),
      ),

      backgroundColor: const Color(0xFFF7F8FD),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // 기존 커스텀 헤더
            Container(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
              decoration: const BoxDecoration(
                color: _blue,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 6),
                  Text(_args.name,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pushNamed(context, '/notifications'),
                    icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                  ),
                ],
              ),
            ),

            // 달력
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 8, 4),
              child: TableCalendar(
                firstDay: DateTime(_focused.year - 1, 1, 1),
                lastDay: DateTime(_focused.year + 1, 12, 31),
                focusedDay: _focused,
                selectedDayPredicate: (d) => isSameDay(d, _selected),
                onDaySelected: (sel, foc) {
                  setState(() {
                    _selected = sel;
                    _focused = foc;
                  });
                  _loadDay(sel); // ← 날짜 클릭 시 GET API 호출 지점
                },
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextFormatter: (_, __) => ym,
                ),
              ),
            ),

            const Divider(height: 1),

            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _dayItems.isEmpty
                  ? const Center(child: Text('해당 날짜의 계획이 없습니다.'))
                  : ListView.separated(
                itemCount: _dayItems.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final item = _dayItems[i];
                  return CheckboxListTile(
                    value: item.done,
                    controlAffinity: ListTileControlAffinity.trailing,
                    title: Text(item.title),
                    onChanged: (v) => _toggleItem(item, v ?? false), // ← POST/PATCH 반영 지점
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CheckItem {
  final String id;
  final String title;
  bool done;
  CheckItem({required this.id, required this.title, this.done = false});
}
