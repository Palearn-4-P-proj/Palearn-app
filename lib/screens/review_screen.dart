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
              child: const Text('어제 했던 것 복습',
                  style: TextStyle(
                      color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 16),

            // 카드 3개 (예시)
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

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _blueLight,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
              const TextStyle(color: _ink, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Text(subtitle, style: const TextStyle(color: _ink, fontSize: 15)),
          const SizedBox(height: 12),
          const Text('보러가기',
              style: TextStyle(
                  color: Color(0xFF6CB5FD),
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline)),
        ],
      ),
    );
  }
}
