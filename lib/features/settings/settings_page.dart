import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/ai/ai_engine.dart';
import '../../core/ai/nong_ying_service.dart';
import '../../core/tts/piper_voice_manager.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/blob_3d.dart';
import '../../shared/widgets/clay_card.dart';
import '../../shared/widgets/puffy_button.dart';
import '../../shared/widgets/section_header.dart';

/// App Settings — entry at `/settings`.
///
/// "AI น้องหญิง" section exposes:
///   • Gemma model download (on-device AI, Settings-only install)
///   • Piper voice download (offline TTS fallback, free forever)
///
/// Both downloads are strictly user-initiated — nothing runs in the background
/// or at first launch. If neither is installed the app still works (cloud mode).
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: TpColors.paper,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('ตั้งค่า', style: TpText.titleLg),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          // Nav-dock uses `context.go('/settings')` which REPLACES the top
          // of the stack, so there's often nothing to pop back to. Prefer
          // pop when possible; otherwise jump back to home so the user
          // never sees a dead-end or a "Nothing to pop" exception.
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: const [
          SectionHeader(titleTh: 'AI น้องหญิง', titleEn: 'AI assistant'),
          _GemmaCard(),
          SizedBox(height: 10),
          _PiperCard(),
          SectionHeader(titleTh: 'เกี่ยวกับแอพ', titleEn: 'About'),
          _AboutCard(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Gemma card
// ---------------------------------------------------------------------------

class _GemmaCard extends ConsumerStatefulWidget {
  const _GemmaCard();
  @override
  ConsumerState<_GemmaCard> createState() => _GemmaCardState();
}

class _GemmaCardState extends ConsumerState<_GemmaCard> {
  ModelInstallPlan? _plan;
  bool _loading = true;
  bool _downloading = false;
  bool _installed = false;
  double _progress = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    try {
      final svc = await ref.read(nongYingServiceProvider.future);
      final plan = await svc.planInstall();
      bool isInstalled = false;
      if (plan.isReady) {
        try {
          await NongYingService.initializePlugin();
          isInstalled = await FlutterGemma.isModelInstalled(plan.modelId);
        } catch (_) {
          // Plugin not ready or never initialised — treat as not installed.
        }
      }
      if (mounted) {
        setState(() {
          _plan = plan;
          _installed = isInstalled;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  // Download flow lives on /nong-ying/install — that page owns the
  // HuggingFace token input needed for gated Gemma repos. Settings just
  // surfaces the current state + a button to take the user there.

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClayCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Blob3D(size: 40, hue: BlobHue.pink),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('โมเดลสมองน้องหญิง (Gemma)', style: TpText.titleMd),
                      Text(_subtitle(), style: TpText.bodyXs.copyWith(color: TpColors.muted)),
                    ],
                  ),
                ),
                _statusChip(),
              ],
            ),
            const SizedBox(height: 10),
            if (_loading)
              const LinearProgressIndicator(color: TpColors.pink, minHeight: 3)
            else if (_plan == null || !_plan!.isReady)
              Text(
                _plan?.reason ??
                    'ยังไม่มีโมเดลสำหรับเครื่องนี้ · น้องจะตอบผ่าน cloud ให้นะคะ',
                style: TpText.bodySm.copyWith(color: TpColors.muted),
              )
            else
              _ProgressRow(
                downloading: _downloading,
                progress: _progress,
                done: _installed,
                sizeLabel: _size(_plan!.kind),
              ),
            if (_error != null) ...[
              const SizedBox(height: 6),
              Text('ผิดพลาด: $_error',
                  style: TpText.bodyXs.copyWith(color: const Color(0xFFD92D2D))),
            ],
            if (_plan != null && _plan!.isReady) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: PuffyButton(
                      label: _installed
                          ? 'ติดตั้งแล้ว'
                          : 'ติดตั้งน้องหญิง',
                      variant: _installed ? PuffyVariant.mint : PuffyVariant.pink,
                      fullWidth: true,
                      // Redirect to the dedicated install page — it owns the
                      // HuggingFace token flow (gated Gemma repos need a PAT)
                      // which is too much UX to duplicate inline here.
                      onPressed: _installed
                          ? null
                          : () => context.push('/nong-ying/install'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusChip() {
    if (_installed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: TpColors.mintTint,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text('พร้อม', style: TpText.bodyXs.copyWith(fontSize: 10, color: const Color(0xFF006B5A))),
      );
    }
    return const SizedBox.shrink();
  }

  String _subtitle() {
    if (_plan == null) return 'ตรวจหาโมเดลที่เหมาะกับเครื่อง...';
    if (!_plan!.isReady) return 'ยังไม่พร้อมให้ติดตั้ง · ใช้ cloud ได้';
    return switch (_plan!.kind) {
      AiEngineKind.gemma4 => 'Gemma 4 · ตอบไว แม่น เหมาะกับเครื่องแรงๆ',
      AiEngineKind.gemma3_4b => 'Gemma 3 4B · สมดุล ขนาดไม่ใหญ่',
      AiEngineKind.gemma3_1b => 'Gemma 3 1B · เล็ก เร็ว',
      _ => 'Cloud only',
    };
  }

  String _size(AiEngineKind k) => switch (k) {
        AiEngineKind.gemma4 => '≈ 1.2 GB',
        AiEngineKind.gemma3_4b => '≈ 800 MB',
        AiEngineKind.gemma3_1b => '≈ 300 MB',
        _ => '',
      };
}

// ---------------------------------------------------------------------------
// Piper voice card
// ---------------------------------------------------------------------------

class _PiperCard extends ConsumerStatefulWidget {
  const _PiperCard();
  @override
  ConsumerState<_PiperCard> createState() => _PiperCardState();
}

class _PiperCardState extends ConsumerState<_PiperCard> {
  PiperVoiceBundle? _bundle;
  bool _loading = true;
  bool _downloading = false;
  int _received = 0;
  int _total = 0;
  String? _currentFile;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    try {
      final manager = ref.read(piperVoiceManagerProvider);
      final b = await manager.readInstalled();
      if (mounted) {
        setState(() {
          _bundle = b;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '$e';
          _loading = false;
        });
      }
    }
  }

  Future<void> _download() async {
    if (_downloading) return;
    setState(() {
      _downloading = true;
      _received = 0;
      _total = 0;
      _error = null;
    });
    try {
      final manager = ref.read(piperVoiceManagerProvider);
      await for (final p in manager.install()) {
        if (!mounted) return;
        setState(() {
          _received = p.received;
          _total = p.total;
          _currentFile = p.currentFile;
        });
      }
      await _refresh();
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  Future<void> _uninstall() async {
    try {
      await ref.read(piperVoiceManagerProvider).uninstall();
      await _refresh();
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final installed = _bundle != null;
    final progress = _total == 0 ? 0.0 : (_received / _total).clamp(0.0, 1.0);
    final pct = (progress * 100).round();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClayCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.record_voice_over_rounded,
                    color: TpColors.purple, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('เสียงพูดแบบ offline (Piper)', style: TpText.titleMd),
                      Text(
                        'ฟรีเสมอ · ใช้ได้ไม่ต้องต่อเน็ต · auto-fallback เมื่อโควต้า Google หมด',
                        style: TpText.bodyXs.copyWith(color: TpColors.muted),
                      ),
                    ],
                  ),
                ),
                if (installed)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: TpColors.mintTint,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text('พร้อม',
                        style: TpText.bodyXs.copyWith(
                          fontSize: 10,
                          color: const Color(0xFF006B5A),
                        )),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            if (_loading)
              const LinearProgressIndicator(color: TpColors.purple, minHeight: 3)
            else if (_downloading) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('กำลังดาวน์โหลด ${_currentFile ?? ''}', style: TpText.monoLabel),
                  Text('$pct%', style: TpText.monoTag),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: _total == 0 ? null : progress,
                  minHeight: 8,
                  backgroundColor: TpColors.mangoTint,
                  valueColor: const AlwaysStoppedAnimation<Color>(TpColors.purple),
                ),
              ),
            ] else if (_error != null)
              Text('ผิดพลาด: $_error',
                  style: TpText.bodyXs.copyWith(color: const Color(0xFFD92D2D)))
            else
              Text(
                installed
                    ? 'เสียงไทย (หญิง) พร้อมใช้งานแบบ offline แล้วค่ะ'
                    : 'แตะ "ดาวน์โหลด" เพื่อติดตั้งเสียงออฟไลน์ (≈ 60-100 MB)',
                style: TpText.bodySm,
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: PuffyButton(
                    label: installed
                        ? 'ติดตั้งแล้ว'
                        : (_downloading ? 'กำลังดาวน์โหลด...' : 'ดาวน์โหลด'),
                    variant: installed ? PuffyVariant.mint : PuffyVariant.purple,
                    fullWidth: true,
                    onPressed: (_downloading || installed) ? null : _download,
                  ),
                ),
                if (installed) ...[
                  const SizedBox(width: 8),
                  PuffyButton(
                    label: 'ลบ',
                    variant: PuffyVariant.ghost,
                    onPressed: _uninstall,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.downloading,
    required this.progress,
    required this.done,
    required this.sizeLabel,
  });
  final bool downloading;
  final double progress;
  final bool done;
  final String sizeLabel;

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!downloading && !done)
          Text('ขนาดที่ต้องดาวน์โหลด: $sizeLabel',
              style: TpText.bodyXs.copyWith(color: TpColors.muted)),
        if (downloading || done) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(done ? 'ติดตั้งสำเร็จ' : 'กำลังดาวน์โหลด',
                  style: TpText.monoLabel),
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
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// About
// ---------------------------------------------------------------------------

class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (_, snap) {
        final v = snap.data == null ? '...' : 'v${snap.data!.version}+${snap.data!.buildNumber}';
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ClayCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Thaiprompt · ไทยพร๊อม', style: TpText.titleMd),
                      Text('เวอร์ชัน $v · Powered by Gemma',
                          style: TpText.bodyXs.copyWith(color: TpColors.muted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
