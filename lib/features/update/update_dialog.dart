import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/text_styles.dart';
import '../../core/theme/tokens.dart';
import '../../core/update/update_service.dart';
import '../../shared/widgets/clay_card.dart';
import '../../shared/widgets/puffy_button.dart';

/// Shows the "มีเวอร์ชันใหม่" sheet with changelog + progress bar.
///
/// Usage:
/// ```
/// final status = await ref.read(updateServiceProvider.future).then((s) => s.checkForUpdate());
/// if (status is UpdateAvailable) {
///   await UpdateDialog.show(context, status);
/// }
/// ```
class UpdateDialog extends ConsumerStatefulWidget {
  const UpdateDialog._({required this.available});

  final UpdateAvailable available;

  static Future<void> show(BuildContext context, UpdateAvailable available) {
    return showDialog(
      context: context,
      barrierDismissible: !available.mandatory,
      builder: (_) => UpdateDialog._(available: available),
    );
  }

  @override
  ConsumerState<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends ConsumerState<UpdateDialog> {
  StreamSubscription<UpdateProgress>? _sub;
  UpdateProgress? _progress;
  String? _error;
  bool _downloading = false;
  bool _done = false;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _startDownload() async {
    if (_downloading) return;
    setState(() {
      _downloading = true;
      _error = null;
      _progress = null;
    });

    try {
      final svc = await ref.read(updateServiceProvider.future);
      _sub = svc.downloadAndInstall(widget.available.info).listen(
        (p) => setState(() => _progress = p),
        onError: (Object e) {
          setState(() {
            _error = '$e';
            _downloading = false;
          });
        },
        onDone: () => setState(() {
          _done = true;
          _downloading = false;
        }),
      );
    } catch (e) {
      setState(() {
        _error = '$e';
        _downloading = false;
      });
    }
  }

  Future<void> _openPlayStore() async {
    final url = widget.available.info.playStoreUrl;
    if (url == null) return;
    final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      setState(() => _error = 'เปิด Play Store ไม่ได้');
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = widget.available.info;
    final mandatory = widget.available.mandatory;

    return PopScope(
      canPop: !mandatory,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420, maxHeight: 600),
          child: ClayCard(
            color: TpColors.paper,
            padding: const EdgeInsets.all(20),
            shadow: ClayShadow.large,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.system_update_rounded, color: TpColors.pink),
                    const SizedBox(width: 8),
                    Text('มีเวอร์ชันใหม่', style: TpText.display4),
                    const Spacer(),
                    if (!mandatory && !_downloading)
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                  ],
                ),
                Text(
                  info.apkSizeBytes > 0
                      ? 'v${info.latestVersion} · ${_formatBytes(info.apkSizeBytes)}'
                      : 'v${info.latestVersion}',
                  style: TpText.monoTag,
                ),
                if (mandatory) ...[
                  const SizedBox(height: 8),
                  _MandatoryChip(),
                ],
                const SizedBox(height: 14),
                Text('อะไรใหม่', style: TpText.titleMd),
                const SizedBox(height: 6),
                Flexible(
                  child: ClayCard(
                    shadow: ClayShadow.small,
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                    color: TpColors.card,
                    child: SingleChildScrollView(
                      child: MarkdownBody(
                        data: info.releaseNotesMd.isEmpty
                            ? '_ไม่มีบันทึกการเปลี่ยนแปลง_'
                            : info.releaseNotesMd,
                        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                          p: TpText.bodySm,
                          listBullet: TpText.bodySm.copyWith(color: TpColors.ink),
                          h1: TpText.display4,
                          h2: TpText.titleLg,
                          h3: TpText.titleMd,
                          code: TpText.monoTag.copyWith(backgroundColor: TpColors.mangoTint),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('ผิดพลาด: $_error',
                        style: TpText.bodySm.copyWith(color: const Color(0xFFD92D2D))),
                  ),
                if (_downloading || _progress != null) _ProgressBlock(progress: _progress),
                if (_done)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: TpColors.mint, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text('ดาวน์โหลดเสร็จ · กดติดตั้งที่หน้าจอถัดไป',
                              style: TpText.bodySm),
                        ),
                      ],
                    ),
                  ),
                _Actions(
                  downloading: _downloading,
                  done: _done,
                  mandatory: mandatory,
                  hasPlayStore: info.playStoreUrl != null,
                  onCancel: mandatory || _downloading ? null : () => Navigator.of(context).pop(),
                  onDownload: _downloading ? null : _startDownload,
                  onPlayStore: _openPlayStore,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _formatBytes(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
    }
    if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '$bytes B';
  }
}

class _MandatoryChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: TpColors.pink.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text('จำเป็นต้องอัปเดต',
          style: TpText.bodyXs.copyWith(color: TpColors.pink, fontWeight: FontWeight.w800)),
    );
  }
}

class _ProgressBlock extends StatelessWidget {
  const _ProgressBlock({this.progress});
  final UpdateProgress? progress;

  @override
  Widget build(BuildContext context) {
    final p = progress;
    final pct = p?.percent ?? 0;
    final hasTotal = (p?.total ?? 0) > 1;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text('กำลังดาวน์โหลด', style: TpText.monoLabel),
              const Spacer(),
              Text(hasTotal ? '$pct%' : '…', style: TpText.monoTag),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: p != null && hasTotal ? p.fraction : null,
              minHeight: 8,
              backgroundColor: TpColors.mangoTint,
              valueColor: const AlwaysStoppedAnimation<Color>(TpColors.pink),
            ),
          ),
          if (hasTotal) ...[
            const SizedBox(height: 4),
            Text(
              '${_mb(p!.received)} / ${_mb(p.total)}',
              style: TpText.monoLabelSm,
            ),
          ],
        ],
      ),
    );
  }

  static String _mb(int bytes) {
    final mb = bytes / 1024 / 1024;
    return '${mb.toStringAsFixed(1)} MB';
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.downloading,
    required this.done,
    required this.mandatory,
    required this.hasPlayStore,
    required this.onCancel,
    required this.onDownload,
    required this.onPlayStore,
  });

  final bool downloading;
  final bool done;
  final bool mandatory;
  final bool hasPlayStore;
  final VoidCallback? onCancel;
  final VoidCallback? onDownload;
  final VoidCallback onPlayStore;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onCancel != null) ...[
          Expanded(
            child: PuffyButton(
              label: 'ภายหลัง',
              variant: PuffyVariant.ghost,
              fullWidth: true,
              onPressed: onCancel,
            ),
          ),
          const SizedBox(width: 8),
        ],
        if (hasPlayStore) ...[
          Expanded(
            child: PuffyButton(
              label: 'Play Store',
              variant: PuffyVariant.mint,
              fullWidth: true,
              onPressed: onPlayStore,
            ),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          flex: 2,
          child: PuffyButton(
            label: done ? 'ติดตั้งอีกครั้ง' : (downloading ? 'กำลังโหลด...' : 'ดาวน์โหลด + ติดตั้ง'),
            variant: PuffyVariant.pink,
            fullWidth: true,
            onPressed: onDownload,
          ),
        ),
      ],
    );
  }
}
