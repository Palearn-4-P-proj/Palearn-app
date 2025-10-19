import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'friends_screen.dart'; // FriendDetailArgs 재사용

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

  // 하루 계획 (체크박스)
  List<CheckItem> _dayItems = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _args = ModalRoute.of(context)!.settings.arguments as FriendDetailArgs;
    _loadDay(_selected);
  }

  Future<void> _loadDay(DateTime day) async {
    setState(() => _loading = true);

    // ##############################
    // [DB/API] 특정 날짜의 친구 계획 불러오기
    // 예)
    // final items = await FriendsAPI.fetchPlan(
    //   friendId: _args.friendId, date: day,
    // );
    // setState(() => _dayItems = items);
    // ##############################
    await Future.delayed(const Duration(milliseconds: 250));
    setState(() {
      _dayItems = []; // 초기: 빈 목록 (실서비스에선 API 데이터)
      _loading = false;
    });
  }

  Future<void> _toggleItem(CheckItem item, bool value) async {
    setState(() => item.done = value);

    // ##############################
    // [DB/API] 체크 상태 업데이트
    // await FriendsAPI.updateCheck(
    //   friendId: _args.friendId, planId: item.id, done: value,
    // );
    // ##############################
  }

  @override
  Widget build(BuildContext context) {
    final ym = '${_focused.year}년 ${_focused.month}월';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FD),
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
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
                  setState(() { _selected = sel; _focused = foc; });
                  _loadDay(sel);
                },
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextFormatter: (_, __) => ym,
                ),
              ),
            ),

            const Divider(height: 1),

            // 오늘 계획 리스트
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
                    onChanged: (v) => _toggleItem(item, v ?? false),
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
