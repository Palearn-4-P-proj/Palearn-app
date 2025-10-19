import 'package:flutter/material.dart';

/// 공통 컬러
const _blue = Color(0xFF7DB2FF);
const _blueLight = Color(0xFFD4E5FE);
const _ink = Color(0xFF093030);

/// ==============================
/// Login
/// ==============================
class LoginWidget extends StatelessWidget {
  const LoginWidget({
    super.key,
    this.onTapSignUpText,
    this.onTapLogin,
  });

  final VoidCallback? onTapSignUpText;
  final VoidCallback? onTapLogin;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SizedBox(
      width: double.infinity,
      height: size.height,
      child: Stack(
        children: [
          // 상단 하늘색 헤더 (아치)
          SizedBox(
            width: double.infinity,
            height: size.height,
            child: ClipPath(
              clipper: _BottomArcClipper(),
              child: Container(color: _blue),
            ),
          ),

          // 흰 카드(모서리 40)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: size.height * 0.18, // 아치가 보이도록 상단 여백
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 16,
                    color: Colors.black.withOpacity(0.06),
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _LoginForm(onTapLogin: onTapLogin),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({this.onTapLogin});
  final VoidCallback? onTapLogin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: Text(
              'Welcome',
              style: TextStyle(
                color: _ink,
                fontSize: 30,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 28),

          const Text('아이디',
              style: TextStyle(color: _ink, fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          const _RoundedField(hint: 'example@example.com'),

          const SizedBox(height: 20),
          const Text('비밀번호',
              style: TextStyle(color: _ink, fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          _RoundedField(
            hint: '••••••••',
            obscure: true,
            trailing: Icon(Icons.visibility_off, size: 20, color: _ink.withOpacity(.7)),
          ),

          const SizedBox(height: 24),
          _PrimaryButton(text: 'Log In', onTap: onTapLogin), // ✅ 콜백 연결
          const SizedBox(height: 10),

          const Align(
            alignment: Alignment.center,
            child: Text(
              'Forgot Password?',
              style: TextStyle(
                color: _ink,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 16),
          _SecondaryButton(
            text: 'Sign Up',
            onTap: () => Navigator.pushReplacementNamed(context, '/signup'),
          ),
          const SizedBox(height: 16),

          const Center(
            child: Text('or sign up with',
                style: TextStyle(color: _ink, fontSize: 12)),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              _CircleIcon(label: 'N'),
              SizedBox(width: 24),
              _CircleIcon(label: 'G'),
            ],
          ),

          const Spacer(),

          GestureDetector(
            onTap: () {
              final state = context.findAncestorWidgetOfExactType<LoginWidget>();
              if (state?.onTapSignUpText != null) state!.onTapSignUpText!();
            },
            child: const Center(
              child: Text.rich(
                TextSpan(
                  text: "Don't have an account? ",
                  style: TextStyle(color: _ink, fontSize: 13, fontWeight: FontWeight.w300),
                  children: [
                    TextSpan(
                      text: 'Sign Up',
                      style: TextStyle(
                        color: Color(0xFF6CB5FD),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ==============================
/// Sign Up (Create Account)
/// ==============================
class CreateAccountWidget extends StatelessWidget {
  const CreateAccountWidget({super.key, this.onTapBackToLogin});
  final VoidCallback? onTapBackToLogin;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SizedBox(
      width: double.infinity,
      height: size.height,
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: size.height,
            child: ClipPath(
              clipper: _BottomArcClipper(),
              child: Container(color: _blue),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: size.height * 0.18,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 16,
                    color: Colors.black.withOpacity(0.06),
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const _SignUpForm(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignUpForm extends StatelessWidget {
  const _SignUpForm();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: Text(
              'Create Account',
              style: TextStyle(
                color: _ink,
                fontSize: 30,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 28),

          const Text('이메일',
              style: TextStyle(color: _ink, fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          const _RoundedField(hint: 'example@example.com'),

          const SizedBox(height: 16),
          const Text('이름',
              style: TextStyle(color: _ink, fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          const _RoundedField(hint: '홍길동'),

          const SizedBox(height: 16),
          const Text('비밀번호',
              style: TextStyle(color: _ink, fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          const _RoundedField(hint: '••••••••', obscure: true),

          const SizedBox(height: 16),
          const Text('비밀번호 확인',
              style: TextStyle(color: _ink, fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          const _RoundedField(hint: '••••••••', obscure: true),

          const SizedBox(height: 24),
          // 회원가입 버튼 — 일단 홈으로 이동 (원하면 /login 등으로 변경)
          _PrimaryButton(
            text: 'Sign Up',
            onTap: () => Navigator.pushReplacementNamed(context, '/home'),
          ),

          const Spacer(),
          GestureDetector(
            onTap: () {
              final state =
              context.findAncestorWidgetOfExactType<CreateAccountWidget>();
              if (state?.onTapBackToLogin != null) state!.onTapBackToLogin!();
            },
            child: const Center(
              child: Text.rich(
                TextSpan(
                  text: 'Already have an account?  ',
                  style:
                  TextStyle(color: _ink, fontSize: 13, fontWeight: FontWeight.w300),
                  children: [
                    TextSpan(
                      text: 'Log In',
                      style: TextStyle(
                        color: Color(0xFF6CB5FD),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ==============================
/// 공용 작은 위젯들
/// ==============================
class _RoundedField extends StatelessWidget {
  const _RoundedField({this.hint, this.obscure = false, this.trailing});
  final String? hint;
  final bool obscure;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: _blueLight,
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              obscureText: obscure,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                isCollapsed: true,
                hintStyle: TextStyle(
                  color: _ink.withOpacity(.45),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: const TextStyle(
                color: _ink,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.text, required this.onTap});
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: FilledButton(
        onPressed: onTap, // ✅ 자기 필드 사용
        style: FilledButton.styleFrom(
          backgroundColor: _blue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFFE0E6F6),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.text, required this.onTap});
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: FilledButton(
        onPressed: onTap, // ✅ 자기 필드 사용
        style: FilledButton.styleFrom(
          backgroundColor: _blueLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF0E3E3E),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _ink.withOpacity(.25)),
      ),
      alignment: Alignment.center,
      child: Text(label, style: const TextStyle(color: _ink, fontSize: 14)),
    );
  }
}

/// 상단 하늘색 영역의 '아래쪽 아치'를 만드는 클리퍼
class _BottomArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final topY = size.height * 0.28;
    final midDrop = size.height * 0.08;

    final path = Path()..lineTo(0, topY);
    final control = Offset(size.width / 2, topY + midDrop);
    final end = Offset(size.width, topY);
    path.quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _BottomArcClipper oldClipper) => false;
}
