import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/ai/ai_engine.dart';
import '../../core/ai/nong_ying_service.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/tokens.dart';
import '../../shared/widgets/blob_3d.dart';
import '../../shared/widgets/clay_card.dart';
import '../../shared/widgets/puffy_button.dart';

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

  @override
  void initState() {
    super.initState();
    _loadPlan();
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
    try {
      final svc = await ref.read(nongYingServiceProvider.future);
      await svc.installModel(
        plan: plan,
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
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _downloading = false);
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
