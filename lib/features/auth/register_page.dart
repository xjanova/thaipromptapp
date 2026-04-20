import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_exceptions.dart';
import '../../core/auth/auth_state.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/clay_card.dart';
import '../../shared/widgets/puffy_button.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _pw2Ctrl = TextEditingController();
  final _refCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  Map<String, List<String>> _fieldErrors = {};

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _pwCtrl.dispose();
    _pw2Ctrl.dispose();
    _refCtrl.dispose();
    super.dispose();
  }

  /// Accept a raw referral code ("ABC123") OR a Thaiprompt affiliate
  /// link ("https://thaiprompt.online/?ref=ABC123", or any
  /// thaiprompt.online page with `?ref=…`). Extracts just the code.
  /// Returns null for empty input so the API call omits the field.
  String? _parseReferral(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return null;
    // Bare code — no protocol, no query string.
    if (!t.contains('://') && !t.contains('?') && !t.contains('/')) {
      return t;
    }
    // Try to extract ?ref= / ?referral= / ?referrer= from a URL.
    try {
      final uri = Uri.parse(t.startsWith('http') ? t : 'https://$t');
      for (final key in const ['ref', 'referral', 'referral_code', 'referrer', 'r']) {
        final v = uri.queryParameters[key];
        if (v != null && v.isNotEmpty) return v;
      }
      // Path-style: /invite/CODE or /r/CODE
      final segs = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if (segs.length >= 2 &&
          (segs.first == 'invite' || segs.first == 'r' || segs.first == 'ref')) {
        return segs[1];
      }
    } catch (_) {
      // Fall through to treat raw text as the code.
    }
    return t;
  }

  Future<void> _submit() async {
    if (_loading) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _error = null;
      _fieldErrors = {};
      _loading = true;
    });
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pw = _pwCtrl.text;
    final pw2 = _pw2Ctrl.text;
    if (name.isEmpty || email.isEmpty || pw.isEmpty) {
      if (mounted) {
        setState(() {
          _error = 'กรอกชื่อ · อีเมล · รหัสผ่าน ก่อนนะคะ';
          _loading = false;
        });
      }
      return;
    }
    if (pw != pw2) {
      if (mounted) {
        setState(() {
          _error = 'รหัสผ่านยืนยันไม่ตรงกัน';
          _fieldErrors = {
            'password_confirmation': ['รหัสผ่านยืนยันไม่ตรงกัน']
          };
          _loading = false;
        });
      }
      return;
    }
    if (pw.length < 8) {
      if (mounted) {
        setState(() {
          _error = 'รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร';
          _fieldErrors = {
            'password': ['รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร']
          };
          _loading = false;
        });
      }
      return;
    }
    try {
      await ref.read(authControllerProvider.notifier).register(
            name: name,
            email: email,
            password: pw,
            passwordConfirmation: pw2,
            phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
            referralCode: _parseReferral(_refCtrl.text),
          );
      if (mounted) context.go('/home');
    } on ValidationException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _fieldErrors = e.errors ?? {};
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } on StateError catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      // Catch-all: never show "Exception: …" or "Bad state: …" to users.
      if (mounted) {
        setState(() =>
            _error = 'สมัครไม่สำเร็จ · ลองอีกสักครู่หรือตรวจการเชื่อมต่อนะคะ');
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
          // Mirror the login page — back returns the user to the browse-
          // ready home, not the onboarding splash.
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Text('สมัครสมาชิก', style: TpText.display2),
              const SizedBox(height: 6),
              Text(
                'เริ่มช้อปและหารายได้ในไม่กี่วินาที',
                style: TpText.bodyMd.copyWith(color: TpColors.muted),
              ),
              const SizedBox(height: 28),
              _field(
                label: 'ชื่อ-สกุล',
                controller: _nameCtrl,
                errorKey: 'name',
              ),
              _field(
                label: 'อีเมล',
                controller: _emailCtrl,
                keyboard: TextInputType.emailAddress,
                errorKey: 'email',
              ),
              _field(
                label: 'เบอร์โทร (ไม่บังคับ)',
                controller: _phoneCtrl,
                keyboard: TextInputType.phone,
                errorKey: 'phone',
              ),
              _field(
                label: 'รหัสผ่าน (อย่างน้อย 8 ตัวอักษร)',
                controller: _pwCtrl,
                obscure: true,
                errorKey: 'password',
              ),
              _field(
                label: 'ยืนยันรหัสผ่าน',
                controller: _pw2Ctrl,
                obscure: true,
                errorKey: 'password_confirmation',
              ),
              _field(
                label: 'รหัสแนะนำ / ลิงก์แนะนำ (ไม่บังคับ)',
                controller: _refCtrl,
                errorKey: 'referral_code',
                hint: 'ABC123 หรือ thaiprompt.online/?ref=ABC123',
              ),
              if (_error != null) ...[
                const SizedBox(height: 6),
                Text(_error!, style: TpText.bodySm.copyWith(color: const Color(0xFFD92D2D))),
              ],
              const SizedBox(height: 20),
              PuffyButton(
                label: _loading ? 'กำลังสมัคร...' : 'สมัครเลย',
                variant: PuffyVariant.pink,
                fullWidth: true,
                size: PuffySize.large,
                onPressed: _loading ? null : _submit,
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text.rich(TextSpan(
                    style: TpText.bodySm.copyWith(color: TpColors.muted),
                    children: [
                      const TextSpan(text: 'มีบัญชีแล้ว? '),
                      TextSpan(
                        text: 'เข้าสู่ระบบ',
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

  Widget _field({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboard,
    bool obscure = false,
    String? errorKey,
    String? hint,
  }) {
    final errs = errorKey == null ? null : _fieldErrors[errorKey];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 0, 6),
            child: Text(label.toUpperCase(), style: TpText.monoLabel),
          ),
          ClayCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            shadow: ClayShadow.small,
            child: TextField(
              controller: controller,
              keyboardType: keyboard,
              obscureText: obscure,
              autocorrect: !obscure,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: TpText.bodySm.copyWith(color: TpColors.muted),
              ),
            ),
          ),
          if (errs != null && errs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 0, 0),
              child: Text(
                errs.first,
                style: TpText.bodyXs.copyWith(color: const Color(0xFFD92D2D)),
              ),
            ),
        ],
      ),
    );
  }
}
