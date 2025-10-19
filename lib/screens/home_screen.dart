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
  // 상단 인사말/진행률
  String displayName = 'User';
  double todayProgress = 0.0; // 0.0~1.0

  // 학습 계획 (탭)
  late final TabController _tab;
  List<String> dailyPlans = [];
  List<String> weeklyPlans = [];
  List<String> monthlyPlans = [];

  // 어제 복습 리스트
  List<Map<String, String>> reviewItems = [];

  // Monthly 캘린더 포커스
  DateTime _focusedMonth = DateTime.now();

  bool loadingHeader = true;
  bool loadingPlans = true;
  bool loadingReview = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _loadHeader();
    _loadPlans();
    _loadReview();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _loadHeader() async {
    // ##########################
    // [DB 연동] 오늘 학습 현황 + 사용자 이름
    // final me = await UserAPI.fetchMe();
    // final stat = await StudyAPI.todaySummary(userId: me.id);
    // displayName = me.name;
    // todayProgress = stat.percent; // 0.0~1.0
    // ##########################
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() {
      displayName = 'User';
      todayProgress = 0.0; // 초기엔 0%
      loadingHeader = false;
    });
  }

  Future<void> _loadPlans() async {
    // ##########################
    // [DB 연동] Daily/Weekly/Monthly 계획 가져오기
    // dailyPlans   = await PlanAPI.getDaily(userId);
    // weeklyPlans  = await PlanAPI.getWeekly(userId);
    // monthlyPlans = await PlanAPI.getMonthly(userId);
    // ##########################
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() {
      dailyPlans = [];   // 처음엔 비어있음
      weeklyPlans = [];
      monthlyPlans = [];
      loadingPlans = false;
    });
  }

  Future<void> _loadReview() async {
    // ##########################
    // [DB 연동] 어제 학습한 콘텐츠 요약 목록
    // reviewItems = await ReviewAPI.yesterday(userId);
    // item 예: {"type":"유튜브","title":"...","desc":"...","link":"..."}
    // ##########################
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() {
      reviewItems = []; // 초기엔 없음
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
          onRefresh: () async {
            await Future.wait([_loadHeader(), _loadPlans(), _loadReview()]);
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _Header(
                displayName: displayName,
                progress: todayProgress,
                percentLabel: percentLabel,
                onBellTap: _goNotifications,
              )),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(child: _myPlanCard()),
              SliverToBoxAdapter(child: const SizedBox(height: 18)),
              SliverToBoxAdapter(child: _planTabs()),
              SliverToBoxAdapter(child: const Divider(height: 32)),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
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
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE7F0FF),
                borderRadius: BorderRadius.circular(22),
              ),
              child: hasAny
                  ? const Text('아래 탭에서 계획을 확인하세요.')
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('아직 학습 계획이 없습니다.\n새로운 계획을 만들어보세요!'),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      // ##########################
                      // [네비/LLM] 계획 생성 플로우로 연결
                      // ##########################
                      Navigator.pushNamed(context, '/create_plan');
                    },
                    child: const Text('새 계획 만들기',
                        style: TextStyle(
                            color: Color(0xFF4F79FF),
                            decoration: TextDecoration.underline)),
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
              borderRadius: BorderRadius.circular(24),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.black54,
            tabs: const [
              Tab(text: 'Daily'),
              Tab(text: 'Weekly'),
              Tab(text: 'Monthly'),
            ],
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 220,
          child: TabBarView(
            controller: _tab,
            children: [
              _planList(loadingPlans, dailyPlans),
              _planList(loadingPlans, weeklyPlans),
              _monthlyTab(), // 캘린더 뷰
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

  // ───────────────── Monthly Tab (Calendar + Review link) ─────────────────
// (Monthly 탭 부분만 교체)
  Widget _monthlyTab() {
    return Column(
      children: [
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () => setState(() =>
              _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1)),
              icon: const Icon(Icons.chevron_left),
            ),
            Text(
              '${_focusedMonth.year}년 ${_focusedMonth.month}월',
              style: const TextStyle(color: _ink, fontSize: 20, fontWeight: FontWeight.w800),
            ),
            IconButton(
              onPressed: () => setState(() =>
              _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1)),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // 달력만 표시
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TableCalendar(
              focusedDay: _focusedMonth,
              firstDay: DateTime(_focusedMonth.year - 1, 1, 1),
              lastDay: DateTime(_focusedMonth.year + 1, 12, 31),
              headerVisible: false,
              rowHeight: 44,
              daysOfWeekHeight: 24,
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(color: _blue, shape: BoxShape.circle),
                defaultTextStyle: TextStyle(fontSize: 14, color: _ink),
                weekendTextStyle: TextStyle(fontSize: 14, color: Colors.redAccent),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(fontSize: 13, color: _inkSub),
                weekendStyle: TextStyle(fontSize: 13, color: Colors.redAccent),
              ),
            ),
          ),
        ),
        // ✅ 텍스트 링크만
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: InkWell(
            onTap: () {
              // ##########################
              // [네비] 어제 복습 화면으로 이동 (데이터 연동)
              // Navigator.pushNamed(context, '/review');
              // ##########################
            },
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Text(
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
        ),
      ],
    );
  }


  // ───────────────── Review Section ─────────────────
  Widget _reviewSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('어제 했던 것 복습',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        if (loadingReview)
          const Center(child: Padding(
            padding: EdgeInsets.all(24.0),
            child: CircularProgressIndicator(),
          ))
        else if (reviewItems.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFE7F0FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('어제 학습한 항목이 없습니다.'),
          )
        else
          Column(
            children: reviewItems.map((e) => _reviewCard(e)).toList(),
          ),
      ]),
    );
  }

  Widget _reviewCard(Map<String, String> item) {
    final type = item['type'] ?? '';
    final title = item['title'] ?? '';
    final desc = item['desc'] ?? '';
    final link = item['link'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(type,
              style: const TextStyle(
                  color: Colors.black54, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(desc),
          const SizedBox(height: 8),
          InkWell(
            onTap: () {
              // ##########################
              // [외부 링크 열기]
              // await UrlLauncher.launchUrl(Uri.parse(link));
              // ##########################
            },
            child: const Text('보러가기',
                style: TextStyle(
                    color: Color(0xFF4F79FF),
                    decoration: TextDecoration.underline)),
          ),
        ],
      ),
    );
  }

  // ───────────────── Bottom Bar (Home / Friends / Profile) ─────────────────
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
            // 홈(현재)
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF9EC0FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: IconButton(
                icon: const Icon(Icons.home_rounded, color: Colors.white),
                onPressed: () {}, // 이미 홈
                tooltip: '홈',
              ),
            ),

            // 친구 (가운데)
            IconButton(
              icon: const Icon(Icons.compare_arrows_rounded, color: Color(0xFF11353A), size: 28),
              onPressed: _goFriends,
              tooltip: '친구',
            ),

            // 프로필 (오른쪽)
            IconButton(
              icon: const Icon(Icons.person_rounded, color: Color(0xFF11353A), size: 28),
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
              const Text('Plearn',
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
                color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),

          // 진행 퍼센트 바
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
              Icon(Icons.check_box_outlined, color: Colors.white, size: 18),
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
