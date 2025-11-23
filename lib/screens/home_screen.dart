import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

const Color _ink = Color(0xFF0E3E3E);
const Color _inkSub = Color(0xFF2A3A3A);
const Color _blue = Color(0xFF7DB2FF);
const Color _blueLight = Color(0xFFE7F0FF);
const Color _surface = Color(0xFFF7F8FD);
const Color _progress = Color(0xFF17122A);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  String displayName = 'User';
  double todayProgress = 0.0;

  late final TabController _tab;
  int _currentTabIndex = 0;

  List<String> dailyPlans = [];
  List<String> weeklyPlans = [];
  List<String> monthlyPlans = [];

  List<Map<String, String>> reviewItems = [];

  DateTime _focusedMonth = DateTime.now();

  bool loadingHeader = true;
  bool loadingPlans = true;
  bool loadingReview = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);

    // 탭 변경 시 인덱스를 저장해 화면 요소 제어
    _tab.addListener(() {
      setState(() {
        _currentTabIndex = _tab.index;
      });
    });

    _loadHeader();
    _loadPlans();
    _loadReview();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  // ================================================================
  // TODO(백엔드 연동 필요, GET):
  // 사용자의 이름(displayName), 오늘 학습 달성률(todayProgress)을
  // FastAPI에서 받아와야 하는 부분.
  //
  // 예: GET /home/header
  //
  // 응답 예:
  // {
  //   "name": "은진",
  //   "todayProgress": 0.65
  // }
  //
  // 현재는 더미 데이터 넣고 있음 → 실제 서비스에서는 반드시 GET 필요
  // ================================================================
  Future<void> _loadHeader() async {
    await Future.delayed(const Duration(milliseconds: 200));

    setState(() {
      displayName = 'User';  // ← 서버 값으로 변경해야 함
      todayProgress = 0.0;   // ← 서버 값으로 변경해야 함
      loadingHeader = false;
    });
  }

  // ================================================================
  // TODO(백엔드 연동 필요, GET):
  // Daily / Weekly / Monthly 학습 계획을 모두 서버에서 받아와야 함.
  //
  // 예: GET /plans?scope=daily
  // 예: GET /plans?scope=weekly
  // 예: GET /plans?scope=monthly
  //
  // 서버 응답 예:
  // ["딥러닝 강의 1강", "코딩테스트 문제 1개"]
  //
  // 현재는 리스트를 비워둔 상태 → 실제 서비스에서는 GET 필수
  // ================================================================
  Future<void> _loadPlans() async {
    await Future.delayed(const Duration(milliseconds: 200));

    setState(() {
      dailyPlans = [];   // ← 실제 GET 결과로 설정
      weeklyPlans = [];  // ← 실제 GET 결과로 설정
      monthlyPlans = []; // ← 실제 GET 결과로 설정
      loadingPlans = false;
    });
  }

  // ================================================================
  // TODO(백엔드 연동 필요, GET):
  // "어제 했던 공부" 복습 리스트(reviewItems)를 서버에서 받아와야 하는 부분.
  //
  // 예: GET /plans/review
  //
  // 응답 예:
  // [
  //   {"title": "CNN 기본 개념", "id": "101"},
  //   {"title": "핵심 알고리즘 정리", "id": "102"}
  // ]
  //
  // 현재는 더미로 빈 리스트 → 실제 서비스에서는 GET 필요
  // ================================================================
  Future<void> _loadReview() async {
    await Future.delayed(const Duration(milliseconds: 200));

    setState(() {
      reviewItems = []; // ← 실제 GET 결과로 대체
      loadingReview = false;
    });
  }

  void _goNotifications() => Navigator.pushNamed(context, '/notifications');
  void _goFriends() => Navigator.pushNamed(context, '/friends');
  void _goProfile() => Navigator.pushNamed(context, '/profile');

  @override
  Widget build(BuildContext context) {
    final percentLabel = '${(todayProgress * 100).round()}%';

    return Scaffold(
      backgroundColor: _surface,
      body: SafeArea(
        child: RefreshIndicator(
          // 당겨서 새로고침: GET 3개 동시에 호출
          onRefresh: () async {
            await Future.wait([_loadHeader(), _loadPlans(), _loadReview()]);
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _Header(
                  displayName: displayName,
                  progress: todayProgress,
                  percentLabel: percentLabel,
                  onBellTap: _goNotifications,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              if (_currentTabIndex != 2)
                SliverToBoxAdapter(child: _myPlanCard()),

              if (_currentTabIndex != 2)
                const SliverToBoxAdapter(child: SizedBox(height: 18)),

              SliverToBoxAdapter(child: _planTabs()),

              SliverToBoxAdapter(child: const Divider(height: 32)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _bottomBar(),
    );
  }

  // ───────────────── My Plan Card ─────────────────
  Widget _myPlanCard() {
    final hasAny =
    (dailyPlans.isNotEmpty || weeklyPlans.isNotEmpty || monthlyPlans.isNotEmpty);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x11000000),
              blurRadius: 12,
              offset: Offset(0, 6),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text('📚  나의 학습 계획',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFE7F0FF),
                borderRadius: BorderRadius.circular(22),
              ),
              child: hasAny
                  ? const Text(
                '아래 탭에서 계획을 확인하세요.',
                style: TextStyle(fontSize: 16),
              )
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '아직 학습 계획이 없습니다.\n새로운 계획을 만들어보세요!',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/create_plan');
                    },
                    child: const Text(
                      '새 계획 만들기',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF4F79FF),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────── Plan Tabs ─────────────────
  Widget _planTabs() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF4FF),
            borderRadius: BorderRadius.circular(28),
          ),
          child: TabBar(
            controller: _tab,
            indicator: BoxDecoration(
              color: const Color(0xFF9EC0FF),
              borderRadius: BorderRadius.circular(22),
            ),
            indicatorPadding:
            const EdgeInsets.symmetric(horizontal: -8, vertical: 4),
            labelPadding: const EdgeInsets.symmetric(vertical: 10),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.black54,
            labelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
            tabs: const [
              Tab(text: 'Daily'),
              Tab(text: 'Weekly'),
              Tab(text: 'Monthly'),
            ],
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: _currentTabIndex == 2
              ? MediaQuery.of(context).size.height * 0.6
              : 220,
          child: TabBarView(
            controller: _tab,
            children: [
              _planList(loadingPlans, dailyPlans),
              _planList(loadingPlans, weeklyPlans),
              _monthlyTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _planList(bool loading, List<String> items) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFE7F0FF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text('아직 학습 계획이 없습니다.\n새로운 계획을 만들어보세요!'),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFE7F0FF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text('• ${items[i]}'),
      ),
    );
  }

  // ───────────────── Monthly Tab ─────────────────
  Widget _monthlyTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => setState(() =>
                _focusedMonth = DateTime(
                    _focusedMonth.year, _focusedMonth.month - 1, 1)),
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                '${_focusedMonth.year}년 ${_focusedMonth.month}월',
                style: const TextStyle(
                    color: _ink, fontSize: 20, fontWeight: FontWeight.w800),
              ),
              IconButton(
                onPressed: () => setState(() =>
                _focusedMonth = DateTime(
                    _focusedMonth.year, _focusedMonth.month + 1, 1)),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TableCalendar(
              focusedDay: _focusedMonth,
              firstDay: DateTime(_focusedMonth.year - 1, 1, 1),
              lastDay: DateTime(_focusedMonth.year + 1, 12, 31),
              headerVisible: false,
              rowHeight: 58,
              daysOfWeekHeight: 28,
              availableGestures: AvailableGestures.horizontalSwipe,
              calendarStyle: const CalendarStyle(
                todayDecoration:
                BoxDecoration(color: _blue, shape: BoxShape.circle),
                defaultTextStyle: TextStyle(fontSize: 16, color: _ink),
                weekendTextStyle:
                TextStyle(fontSize: 16, color: Colors.redAccent),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(fontSize: 15, color: _inkSub),
                weekendStyle: TextStyle(fontSize: 15, color: Colors.redAccent),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _focusedMonth = focusedDay;
                });
                _tab.animateTo(0);
              },
            ),
          ),

          const SizedBox(height: 20),

          // ================================================================
          // TODO(백엔드 연동 필요, GET):
          // “어제 했던 공부 복습하기”를 눌렀을 때 표시될 복습 리스트는
          // 서버에서 받아온 reviewItems 데이터 기반이어야 함.
          //
          // 예: GET /plans/review
          // ================================================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: InkWell(
              onTap: () {
                // 복습 화면으로 이동할 경우 reviewItems 전달 가능
              },
              child: const Text(
                '📚 어제 했던 거 복습',
                style: TextStyle(
                  color: _ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ───────────────── Bottom Bar ─────────────────
  Widget _bottomBar() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF4FF),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF9EC0FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: IconButton(
                icon: const Icon(Icons.home_rounded, color: Colors.white),
                onPressed: () {},
                tooltip: '홈',
              ),
            ),
            IconButton(
              icon: const Icon(Icons.compare_arrows_rounded,
                  color: Color(0xFF11353A), size: 28),
              onPressed: _goFriends,
              tooltip: '친구',
            ),
            IconButton(
              icon: const Icon(Icons.person_rounded,
                  color: Color(0xFF11353A), size: 28),
              onPressed: _goProfile,
              tooltip: '프로필',
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────── Header Widget ───────────────────
class _Header extends StatelessWidget {
  const _Header({
    required this.displayName,
    required this.progress,
    required this.percentLabel,
    required this.onBellTap,
  });

  final String displayName;
  final double progress;
  final String percentLabel;
  final VoidCallback onBellTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
      decoration: const BoxDecoration(
        color: _blue,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Palearn',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),
              const Spacer(),
              IconButton(
                onPressed: onBellTap,
                icon: const Icon(Icons.notifications_none_rounded,
                    color: Colors.white),
                tooltip: '알림',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '안녕하세요, $displayName 님!',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          Stack(
            alignment: Alignment.centerLeft,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 16,
                  backgroundColor: Colors.white24,
                  color: Colors.white,
                ),
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    percentLabel,
                    style: const TextStyle(
                        color: Colors.black54, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: const [
              Icon(Icons.check_box_outlined,
                  color: Colors.white, size: 18),
              SizedBox(width: 6),
              Text('오늘의 공부 현황',
                  style: TextStyle(color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }
}
