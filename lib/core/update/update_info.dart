import 'package:equatable/equatable.dart';

/// Metadata describing a release available for download.
///
/// Fetched from `GET /api/v1/app/latest-version` (backend patch added in this
/// phase). The shape is deliberately minimal so we can extend without bumping
/// the client.
class UpdateInfo extends Equatable {
  const UpdateInfo({
    required this.latestVersion,
    required this.latestBuild,
    required this.minSupportedVersion,
    required this.releaseNotesMd,
    required this.apkUrl,
    required this.apkSizeBytes,
    required this.publishedAt,
    this.playStoreUrl,
  });

  /// Semver string like "1.0.3"
  final String latestVersion;

  /// Android versionCode / iOS build number
  final int latestBuild;

  /// Users below this version are forced to update.
  final String minSupportedVersion;

  /// Markdown-formatted changelog shown in the update dialog.
  final String releaseNotesMd;

  /// Direct APK download URL (hosted on GitHub Release asset).
  final String apkUrl;

  /// Approximate APK size for progress display.
  final int apkSizeBytes;

  final DateTime publishedAt;

  /// Optional — when the app came from Play Store we prefer in-app updates.
  final String? playStoreUrl;

  factory UpdateInfo.fromJson(Map<String, dynamic> j) => UpdateInfo(
        latestVersion: j['latest_version']?.toString() ?? '0.0.0',
        latestBuild: j['latest_build'] is num ? (j['latest_build'] as num).toInt() : 1,
        minSupportedVersion: j['min_supported_version']?.toString() ?? '0.0.0',
        releaseNotesMd: j['release_notes_md']?.toString() ?? '',
        apkUrl: j['apk_url']?.toString() ?? '',
        apkSizeBytes: j['apk_size_bytes'] is num
            ? (j['apk_size_bytes'] as num).toInt()
            : 0,
        publishedAt: DateTime.tryParse(j['published_at']?.toString() ?? '') ??
            DateTime.now(),
        playStoreUrl: j['play_store_url']?.toString(),
      );

  @override
  List<Object?> get props =>
      [latestVersion, latestBuild, minSupportedVersion, apkUrl];
}

/// Compare two semver strings. Returns:
///   -1 if a < b,  0 if equal,  1 if a > b
/// Non-numeric/pre-release suffixes are ignored.
int compareSemver(String a, String b) {
  List<int> parse(String v) => v.split('-').first.split('.').map((p) {
        return int.tryParse(p) ?? 0;
      }).toList();
  final pa = parse(a);
  final pb = parse(b);
  final len = pa.length > pb.length ? pa.length : pb.length;
  for (var i = 0; i < len; i++) {
    final x = i < pa.length ? pa[i] : 0;
    final y = i < pb.length ? pb[i] : 0;
    if (x != y) return x < y ? -1 : 1;
  }
  return 0;
}
