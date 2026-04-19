import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/theme/text_styles.dart';
import '../../core/theme/tokens.dart';
import '../../core/update/update_service.dart';
import '../../features/update/update_dialog.dart';

/// Shows the current app version (from pubspec → PackageInfo) and a dot when
/// an update is available. Tapping triggers the update dialog.
class VersionBadge extends ConsumerWidget {
  const VersionBadge({super.key, this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(_packageInfoProvider);
    final status = ref.watch(updateStatusProvider);

    final hasUpdate = status.maybeWhen(
      data: (s) => s is UpdateAvailable,
      orElse: () => false,
    );

    final versionText = info.maybeWhen(
      data: (pkg) => 'v${pkg.version}',
      orElse: () => 'v…',
    );

    return GestureDetector(
      onTap: () async {
        if (onTap != null) return onTap!();
        final s = status.valueOrNull;
        if (s is UpdateAvailable) {
          await UpdateDialog.show(context, s);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: TpColors.ink.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(versionText, style: TpText.monoLabelSm),
            if (hasUpdate) ...[
              const SizedBox(width: 4),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: TpColors.pink,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

final _packageInfoProvider = FutureProvider<PackageInfo>((ref) async {
  return PackageInfo.fromPlatform();
});
