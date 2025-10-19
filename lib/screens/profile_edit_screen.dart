import 'package:flutter/material.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late TextEditingController emailCtrl;
  late TextEditingController nameCtrl;
  late TextEditingController birthCtrl;
  late TextEditingController pwCtrl;
  late TextEditingController pw2Ctrl;

  String photoUrl =
      'https://images.unsplash.com/photo-1603415526960-f7e0328d13a2?w=256&h=256&fit=crop';
  String userId = '25030024';
  bool hidePw = true;
  bool hidePw2 = true;

  @override
  void initState() {
    super.initState();
    emailCtrl = TextEditingController(text: 'example@example.com');
    nameCtrl = TextEditingController(text: 'John Smith');
    birthCtrl = TextEditingController();
    pwCtrl = TextEditingController();
    pw2Ctrl = TextEditingController();

    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    // ModalRoute는 build 이후 접근되므로 addPostFrameCallback으로 보완
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final a = ModalRoute.of(context)?.settings.arguments as Map?;
      if (a != null) {
        setState(() {
          nameCtrl.text = a['name']?.toString() ?? nameCtrl.text;
          userId = a['userId']?.toString() ?? userId;
          final p = a['photoUrl']?.toString();
          if (p != null) photoUrl = p;
        });
      }
    });
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    nameCtrl.dispose();
    birthCtrl.dispose();
    pwCtrl.dispose();
    pw2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    // ##########################
    // [DB 연동] 프로필 업데이트 API
    // await UserAPI.update(
    //   email: emailCtrl.text, name: nameCtrl.text, birth: birthCtrl.text,
    //   password: pwCtrl.text.isEmpty ? null : pwCtrl.text, photoUrl: photoUrl,
    // );
    // ##########################
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('프로필이 업데이트되었습니다.')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
                child: Text('Edit My Profile',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(radius: 48, backgroundImage: NetworkImage(photoUrl)),
                        InkWell(
                          onTap: () {
                            // ##########################
                            // [업로드 연동] 프로필 사진 변경
                            // final newUrl = await Storage.pickAndUpload();
                            // setState(() => photoUrl = newUrl);
                            // ##########################
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 4, bottom: 4),
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFF7DB2FF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.photo_camera_outlined,
                                size: 18, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(nameCtrl.text,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800)),
                    Text('ID: $userId', style: const TextStyle(color: Colors.black54)),
                    const SizedBox(height: 18),

                    _field(label: '아이디', child: TextField(
                      controller: emailCtrl,
                      decoration: _decoration('example@example.com'),
                    )),
                    _field(label: '이름', child: TextField(
                      controller: nameCtrl,
                      decoration: _decoration('홍길동'),
                    )),
                    _field(label: '생일', child: TextField(
                      controller: birthCtrl,
                      decoration: _decoration('DD / MM / YYYY'),
                    )),
                    _field(label: '비밀번호', child: TextField(
                      controller: pwCtrl,
                      obscureText: hidePw,
                      decoration: _decoration(null).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(hidePw ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => hidePw = !hidePw),
                        ),
                      ),
                    )),
                    _field(label: '비밀번호 확인', child: TextField(
                      controller: pw2Ctrl,
                      obscureText: hidePw2,
                      decoration: _decoration(null).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(hidePw2 ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => hidePw2 = !hidePw2),
                        ),
                      ),
                    )),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7DB2FF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Update Profile'),
                      ),
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

  Widget _field({required String label, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }

  InputDecoration _decoration(String? hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFD6E6FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}
