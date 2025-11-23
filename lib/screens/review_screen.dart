import 'package:flutter/material.dart';

const _blueLight = Color(0xFFE7F0FF);
const _ink = Color(0xFF0E3E3E);

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 100),
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              decoration: const BoxDecoration(
                color: Color(0xFF7DB2FF),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Row(
                children: [
                  // 🔥 뒤로가기 버튼
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '어제 했던 것 복습',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ============================================================
            // 🔵 [FastAPI GET 필요]
            // 어제 학습한 리스트 불러오기
            //
            // 예시 FastAPI:
            //   GET /review/yesterday?user_id=123
            //
            // 서버에서 반환하는 JSON 예시:
            // [
            //   { "type": "youtube", "title": "Sentdex neural network P.1" },
            //   { "type": "book", "title": "딥러닝 전이학습" },
            //   { "type": "blog", "title": "TF-IDF 실습" }
            // ]
            //
            // Flutter에서는:
            //   final items = await http.get(...);
            //   화면에 표시
            //
            // 지금은 데모 데이터(하드코딩)로 표시 중
            // ============================================================

            ...[
              _ReviewCard(
                title: '유튜브',
                subtitle: 'Sentdex의 ‘처음부터 시작하는 신경망 - P.1 소개 및 뉴런 코드 ‘',
              ),
              _ReviewCard(
                title: '도서',
                subtitle: '파이썬을 활용한 딥러닝 전이학습',
              ),
              _ReviewCard(
                title: '블로그',
                subtitle: '[NLP] 텍스트 벡터화 : TF - IDF 실습',
              ),
            ],
          ],
        ),
      ),

      // 바텀 네비 동일 노출
      bottomNavigationBar: Container(
        height: 84,
        decoration: const BoxDecoration(
          color: Color(0xFFE3EEFF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            Icon(Icons.home, size: 28, color: _ink),
            Icon(Icons.insights_outlined, size: 28, color: _ink),
            Icon(Icons.sync_alt, size: 28, color: _ink),
            Icon(Icons.layers_outlined, size: 28, color: _ink),
            Icon(Icons.person_outline, size: 28, color: _ink),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────
// 🔹 Review Card Component
// ───────────────────────────────────────────
class _ReviewCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _ReviewCard({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: _blueLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700, color: _ink)),
          const SizedBox(height: 6),
          Text(subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              )),
        ],
      ),
    );
  }
}
