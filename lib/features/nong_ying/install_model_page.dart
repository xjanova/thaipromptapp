import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/ai/ai_engine.dart';
import '../../core/ai/nong_ying_service.dart';
import '../../core/db/local_db.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/blob_3d.dart';
import '../../shared/widgets/clay_card.dart';
import '../../shared/widgets/puffy_button.dart';

const _kHfTokenKey = 'tp.ai.hf_token';

/// First-run installer for the on-device Gemma model.
///
/// Entry: /nong-ying/install
///
/// Behaviour:
///   1. On open, asks [NongYingService.planInstall] which tier + URL is
///      advertised by remote config.
///   2. If no plan → shows a "cloud mode only" message and lets the user
///      back out. They can still chat — just via the server fallback.
///   3. Otherwise shows size + name + "ดาวน์โหลด" CTA.
///   4. Download streams progress to a progress bar + "45%" label.
class InstallModelPage extends ConsumerStatefulWidget {
  const InstallModelPage({super.key});

  @override
  ConsumerState<InstallModelPage> createState() => _InstallModelPageState();
}

class _InstallModelPageState extends ConsumerState<InstallModelPage> {
  ModelInstallPlan? _plan;
  bool _loadingPlan = true;
  double _progress = 0;
  bool _downloading = false;
  bool _done = false;
  String? _error;
  final _tokenCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPlan();
    _loadSavedToken();
  }

  @override
  void dispose() {
    _tokenCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSavedToken() async {
    try {
      final kv = await ref.read(kvStoreProvider.future);
      final t = await kv.read(_kHfTokenKey);
      if (t != null && t.isNotEmpty && mounted) {
        _tokenCtrl.text = t;
      }
    } catch (_) {
      // no-op — token is optional
    }
  }

  Future<void> _loadPlan() async {
    try {
      final svc = await ref.read(nongYingServiceProvider.future);
      final plan = await svc.planInstall();
      if (mounted) {
        setState(() {
          _plan = plan;
          _loadingPlan = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '$e';
          _loadingPlan = false;
        });
      }
    }
  }

  Future<void> _download() async {
    final plan = _plan;
    if (plan == null || !plan.isReady || _downloading) return;
    setState(() {
      _downloading = true;
      _progress = 0;
      _error = null;
    });

    // Persist the HF token so retries don't force re-entry, and so the
    // chat flow can reuse it silently for future model swaps.
    final token = _tokenCtrl.text.trim();
    if (token.isNotEmpty) {
      try {
        final kv = await ref.read(kvStoreProvider.future);
        await kv.write(_kHfTokenKey, token);
      } catch (_) {/* best-effort */}
    }

    try {
      final svc = await ref.read(nongYingServiceProvider.future);
      await svc.installModel(
        plan: plan,
        hfToken: token.isEmpty ? null : token,
        onProgress: (pct) {
          if (mounted) setState(() => _progress = pct / 100.0);
        },
      );
      if (mounted) {
        setState(() {
          _progress = 1;
          _done = true;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = _friendlyError('$e'));
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  String _friendlyError(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('401') ||
        lower.contains('403') ||
        lower.contains('unauthorized') ||
        lower.contains('gated')) {
      return 'ดาวน์โหลดไม่ได้ · HuggingFace ล็อกโมเดลนี้ไว้ค่ะ '
          'ต้อง:\n1) กดขอสิทธิ์บนหน้าโมเดล (free)\n'
          '2) ไปที่ huggingface.co/settings/tokens · สร้าง access token\n'
          '3) วาง token ในช่องด้านบน แล้วกดดาวน์โหลดอีกครั้งค่ะ';
    }
    if (lower.contains('timed out') || lower.contains('timeout')) {
      return 'ดาวน์โหลดช้าเกินไป · ลองใหม่เมื่อเน็ตดีขึ้นนะคะ';
    }
    return raw;
  }

  Future<void> _openHfTokenPage() async {
    final uri = Uri.parse('https://huggingface.co/settings/tokens');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openModelLicensePage() async {
    final plan = _plan;
    if (plan == null || !plan.isReady) return;
    // Derive the repo URL from the install URL:
    //   https://huggingface.co/<owner>/<repo>/resolve/main/<file>.task
    // → https://huggingface.co/<owner>/<repo>
    final m = RegExp(r'^https://huggingface\.co/([^/]+/[^/]+)/resolve/')
        .firstMatch(plan.url);
    if (m == null) return;
    final repo = m.group(1)!;
    final uri = Uri.parse('https://huggingface.co/$repo');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
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
          onPressed: _downloading ? null : () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Center(child: const Blob3D(size: 96, hue: BlobHue.pink)),
              const SizedBox(height: 16),
              Text('ติดตั้งน้องหญิงในเครื่องคุณ', style: TpText.display3),
              const SizedBox(height: 6),
              Text(
                _headline(),
                style: TpText.bodySm.copyWith(color: TpColors.muted),
              ),
              const SizedBox(height: 20),
              _PlanCard(plan: _plan),
              if (_plan != null && _plan!.isReady) ...[
                const SizedBox(height: 14),
                _HfTokenSection(
                  controller: _tokenCtrl,
                  onOpenTokenPage: _openHfTokenPage,
                  onOpenModelPage: _openModelLicensePage,
                  downloading: _downloading,
                ),
              ],
              const SizedBox(height: 20),
              if (_downloading || _progress > 0) _ProgressBlock(progress: _progress, done: _done),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text('ผิดพลาด: $_error',
                    style: TpText.bodySm.copyWith(color: const Color(0xFFD92D2D))),
              ],
              const Spacer(),
              PuffyButton(
                label: _buttonLabel(),
                variant: _buttonVariant(),
                size: PuffySize.large,
                fullWidth: true,
                onPressed: _buttonAction(),
              ),
              const SizedBox(height: 8),
              Center(
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: Text(
                    'ใช้โหมด cloud ก็ได้ (ไม่ต้องติดตั้ง)',
                    style: TpText.bodySm.copyWith(
                      color: TpColors.muted,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  VoidCallback? _buttonAction() {
    final plan = _plan;
    if (plan == null) return null;
    if (_downloading) return null;
    if (_done) return () => context.go('/nong-ying');
    if (plan.isReady) return _download;
    // unavailable / unconfigured → the only useful action is dismiss.
    return () => context.go('/home');
  }

  String _buttonLabel() {
    final plan = _plan;
    if (_done) return 'พร้อมใช้งาน · เปิดแชท';
    if (_downloading) return 'กำลังดาวน์โหลด...';
    if (plan == null) return 'กำลังตรวจ...';
    if (plan.isReady) return 'ดาวน์โหลด';
    return 'กลับหน้าแรก';
  }

  PuffyVariant _buttonVariant() {
    if (_done) return PuffyVariant.mint;
    final plan = _plan;
    if (plan == null || !plan.isReady) return PuffyVariant.ghost;
    return PuffyVariant.pink;
  }

  String _headline() {
    if (_loadingPlan) {
      return 'กำลังตรวจรุ่นที่เหมาะกับเครื่องของคุณ...';
    }
    final plan = _plan;
    if (plan == null) return 'ตรวจเครื่องไม่สำเร็จ · ลองอีกครั้งนะคะ';
    switch (plan.status) {
      case ModelInstallStatus.unavailable:
        return plan.reason ?? 'ใช้โหมด cloud เท่านั้น (ไม่มีโมเดลสำหรับเครื่องนี้)';
      case ModelInstallStatus.unconfigured:
        return plan.reason ?? 'ยังไม่เปิดให้ติดตั้ง AI ตอนนี้ค่ะ';
      case ModelInstallStatus.ready:
        return switch (plan.kind) {
          AiEngineKind.gemma4 =>
            'เครื่องของคุณรองรับโมเดลใหญ่ Gemma 4 · ตอบไว + แม่นยำ',
          AiEngineKind.gemma3_4b =>
            'แนะนำ Gemma 3 4B · สมดุลระหว่างคุณภาพและขนาด',
          AiEngineKind.gemma3_1b =>
            'แนะนำ Gemma 3 1B · ขนาดเล็ก เหมาะกับเครื่องที่ RAM จำกัด',
          _ => 'พร้อมติดตั้งค่ะ',
        };
    }
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan});
  final ModelInstallPlan? plan;

  @override
  Widget build(BuildContext context) {
    final p = plan;
    if (p == null) {
      return ClayCard(
        padding: const EdgeInsets.all(14),
        shadow: ClayShadow.small,
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: TpColors.pink),
            ),
            const SizedBox(width: 12),
            Text('กำลังเช็คการตั้งค่า...', style: TpText.bodySm),
          ],
        ),
      );
    }

    if (p.status != ModelInstallStatus.ready) {
      return ClayCard(
        padding: const EdgeInsets.all(14),
        shadow: ClayShadow.small,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.cloud_outlined,
                color: TpColors.muted, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('ใช้โหมด cloud ได้ทันทีนะคะ', style: TpText.titleMd),
                  const SizedBox(height: 4),
                  Text(
                    p.reason ??
                        'น้องตอบผ่านเซิร์ฟเวอร์ได้ปกติ · รอการตั้งค่าจากทีมอีกนิด',
                    style: TpText.bodyXs.copyWith(color: TpColors.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return ClayCard(
      padding: const EdgeInsets.all(14),
      shadow: ClayShadow.small,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(_kindLabel(p.kind), style: TpText.titleMd),
              const Spacer(),
              Text(p.modelId, style: TpText.monoLabelSm),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '≈ ${_sizeEstimate(p.kind)}  · ดาวน์โหลดครั้งแรกครั้งเดียว',
            style: TpText.bodyXs,
          ),
          const SizedBox(height: 4),
          Text(
            'เก็บใน cache ของแอพ · หลังติดตั้งน้องตอบแบบ offline ได้',
            style: TpText.bodyXs.copyWith(color: TpColors.muted),
          ),
        ],
      ),
    );
  }

  String _kindLabel(AiEngineKind k) => switch (k) {
        AiEngineKind.gemma4 => 'Gemma 4',
        AiEngineKind.gemma3_4b => 'Gemma 3 4B',
        AiEngineKind.gemma3_1b => 'Gemma 3 1B',
        _ => 'Cloud',
      };

  String _sizeEstimate(AiEngineKind k) => switch (k) {
        AiEngineKind.gemma4 => '1.2 GB',
        AiEngineKind.gemma3_4b => '800 MB',
        AiEngineKind.gemma3_1b => '300 MB',
        _ => '0 MB',
      };
}

class _ProgressBlock extends StatelessWidget {
  const _ProgressBlock({required this.progress, required this.done});
  final double progress;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).clamp(0, 100).toStringAsFixed(0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(done ? 'ติดตั้งสำเร็จ' : 'กำลังดาวน์โหลด', style: TpText.monoLabel),
            Text('$pct%', style: TpText.monoTag),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: TpColors.mangoTint,
            valueColor: AlwaysStoppedAnimation<Color>(
              done ? TpColors.mint : TpColors.pink,
            ),
          ),
        ),
      ],
    );
  }
}

/// Optional HuggingFace token input + instructions.
///
/// Google's Gemma models on HuggingFace are gated — users must accept
/// the license on the model's page and use a personal access token to
/// download. We persist the token to [KvStore] so retries and future
/// re-installs don't force the user to re-enter it.
class _HfTokenSection extends StatefulWidget {
  const _HfTokenSection({
    required this.controller,
    required this.onOpenTokenPage,
    required this.onOpenModelPage,
    required this.downloading,
  });

  final TextEditingController controller;
  final VoidCallback onOpenTokenPage;
  final VoidCallback onOpenModelPage;
  final bool downloading;

  @override
  State<_HfTokenSection> createState() => _HfTokenSectionState();
}

class _HfTokenSectionState extends State<_HfTokenSection> {
  bool _obscure = true;

  Future<void> _paste() async {
    final clip = await Clipboard.getData('text/plain');
    final t = clip?.text?.trim();
    if (t != null && t.isNotEmpty) {
      widget.controller.text = t;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClayCard(
      padding: const EdgeInsets.all(14),
      shadow: ClayShadow.small,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.key_rounded, size: 18, color: TpColors.pink),
              const SizedBox(width: 8),
              Text('HuggingFace token (ถ้าจำเป็น)', style: TpText.titleMd),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'โมเดล Gemma บน HF ถูกล็อกไว้ค่ะ · ทำ 3 ขั้นตอนครั้งเดียว:',
            style: TpText.bodyXs.copyWith(color: TpColors.muted),
          ),
          const SizedBox(height: 8),
          _StepRow(
            number: '1',
            text: 'กดขอสิทธิ์ใช้โมเดล (ฟรี · อนุมัติเร็ว)',
            actionLabel: 'เปิดหน้าโมเดล',
            onAction: widget.onOpenModelPage,
          ),
          _StepRow(
            number: '2',
            text: 'สร้าง access token (scope: read)',
            actionLabel: 'huggingface.co/settings/tokens',
            onAction: widget.onOpenTokenPage,
          ),
          _StepRow(
            number: '3',
            text: 'วาง token ในช่องด้านล่าง แล้วกด "ดาวน์โหลด"',
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              color: TpColors.mangoTint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    enabled: !widget.downloading,
                    obscureText: _obscure,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'hf_...',
                    ),
                    style: TpText.monoLabel.copyWith(fontSize: 13),
                  ),
                ),
                IconButton(
                  tooltip: 'วาง',
                  icon: const Icon(Icons.content_paste_rounded, size: 18),
                  onPressed: widget.downloading ? null : _paste,
                ),
                IconButton(
                  tooltip: _obscure ? 'แสดง' : 'ซ่อน',
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 18,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Token เก็บใน SQLite ภายในเครื่องค่ะ · ไม่ส่งไปไหน · ใช้ครั้งถัดไปก็ไม่ต้องกรอกอีก',
            style: TpText.bodyXs.copyWith(color: TpColors.muted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.number,
    required this.text,
    this.actionLabel,
    this.onAction,
  });

  final String number;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: TpColors.pink,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              number,
              style: TpText.bodyXs.copyWith(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: TpText.bodySm),
                if (actionLabel != null && onAction != null)
                  GestureDetector(
                    onTap: onAction,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        actionLabel!,
                        style: TpText.bodyXs.copyWith(
                          color: TpColors.ink,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
