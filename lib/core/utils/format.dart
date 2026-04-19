import 'package:intl/intl.dart';

final NumberFormat _bahtThousands = NumberFormat('#,##0', 'th_TH');
final NumberFormat _bahtCents = NumberFormat('#,##0.00', 'th_TH');

/// Render a price in Thai Baht with the leading `฿`.
///
/// Default rounds to whole baht ("฿120"). Pass `decimals: true` to keep two
/// fraction digits ("฿120.50") for line-item subtotals where precision matters.
String formatBaht(num value, {bool decimals = false}) {
  final fmt = decimals ? _bahtCents : _bahtThousands;
  return '฿${fmt.format(value)}';
}

/// Compact distance: "200 ม." for sub-1km, "1.4 กม." otherwise.
String formatDistance(double km) {
  if (km < 1) return '${(km * 1000).round()} ม.';
  return '${km.toStringAsFixed(1)} กม.';
}
