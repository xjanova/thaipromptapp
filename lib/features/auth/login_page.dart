import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_exceptions.dart';
import '../../core/auth/auth_state.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/clay_card.dart';
import '../../shared/widgets/puffy_button.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _idCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _idCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _error = null;
      _loading = true;
    });
    final id = _idCtrl.text.trim();
    final pw = _pwCtrl.text;
    if (id.isEmpty || pw.isEmpty) {
      if (mounted) {
        setState(() {
          _error = 'กรอกอีเมล/เบอร์ และรหัสผ่านก่อนนะคะ';
          _loading = false;
        });
      }
      return;
    }
    try {
      await ref.read(authControllerProvider.notifier).login(
            identifier: id,
            password: pw,
          );
      if (mounted) context.go('/home');
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } on StateError catch (e) {
      // Backend returned 200 but no token field — very rare, keep it readable.
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      // Catch-all: never show "Exception: …" or "Bad state: …" to users.
      if (mounted) {
        setState(() =>
            _error = 'เข้าระบบไม่สำเร็จ · ตรวจสอบอีเมล/รหัสผ่านแล้วลองใหม่ค่ะ');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TpColors.paper,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          // Guests are routed to /login when they tap protected actions
          // (cart, wallet, my orders, ...). Letting back jump to /home
          // keeps them in the app instead of bouncing to onboarding.
          onPressed: () => context.go('/home'),
        ),
        actions: [
          TextButton(
            onPressed: () => context.go('/home'),
            child: Text('ข้ามไปก่อน',
                style: TpText.bodySm.copyWith(
                  color: TpColors.muted,
                  fontWeight: FontWeight.w700,
                )),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Text('ยินดีต้อนรับ 👋', style: TpText.display2),
              const SizedBox(height: 6),
              Text('เข้าสู่ระบบเพื่อกลับมาช้อปต่อ', style: TpText.bodyMd.copyWith(color: TpColors.muted)),
              const SizedBox(height: 32),
              _label('อีเมล หรือ เบอร์โทร'),
              ClayCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                shadow: ClayShadow.small,
                child: TextField(
                  controller: _idCtrl,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'somporn@example.com',
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _label('รหัสผ่าน'),
              ClayCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                shadow: ClayShadow.small,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _pwCtrl,
                        obscureText: _obscure,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '••••••••',
                        ),
                        onSubmitted: (_) => _submit(),
                      ),
                    ),
                    IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ],
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: TpText.bodySm.copyWith(color: const Color(0xFFD92D2D))),
              ],
              const SizedBox(height: 24),
              PuffyButton(
                label: _loading ? 'กำลังเข้าสู่ระบบ...' : 'เข้าสู่ระบบ',
                variant: PuffyVariant.pink,
                fullWidth: true,
                size: PuffySize.large,
                onPressed: _loading ? null : _submit,
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/register'),
                  child: Text.rich(TextSpan(
                    style: TpText.bodySm.copyWith(color: TpColors.muted),
                    children: [
                      const TextSpan(text: 'ยังไม่มีบัญชี? '),
                      TextSpan(
                        text: 'สมัครสมาชิก',
                        style: TpText.bodySm.copyWith(
                          color: TpColors.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 0, 0, 6),
        child: Text(text.toUpperCase(), style: TpText.monoLabel),
      );
}
