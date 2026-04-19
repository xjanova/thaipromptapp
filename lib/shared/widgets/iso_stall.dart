import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Isometric market-stall illustration — port of `IsoStall` SVG from blobs.jsx.
/// Rendered via [SvgPicture.string] so we avoid per-line CustomPaint drudgery.
class IsoStall extends StatelessWidget {
  const IsoStall({super.key, this.width = 260, this.height = 200});

  final double width;
  final double height;

  static const _svg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 260 200">
  <defs>
    <linearGradient id="roof1" x1="0" x2="0" y1="0" y2="1">
      <stop offset="0" stop-color="#FF3E6C"/><stop offset="1" stop-color="#B30040"/>
    </linearGradient>
    <linearGradient id="wood" x1="0" x2="0" y1="0" y2="1">
      <stop offset="0" stop-color="#E6A23B"/><stop offset="1" stop-color="#8B5A1B"/>
    </linearGradient>
    <radialGradient id="shad"><stop offset="0" stop-color="rgba(0,0,0,.4)"/><stop offset="1" stop-color="rgba(0,0,0,0)"/></radialGradient>
  </defs>
  <ellipse cx="130" cy="178" rx="110" ry="14" fill="url(#shad)"/>
  <rect x="52" y="78" width="5" height="92" fill="#3a2510"/>
  <rect x="203" y="78" width="5" height="92" fill="#3a2510"/>
  <path d="M40 84 L220 84 L210 58 L50 58 Z" fill="url(#roof1)"/>
  <g>
    <path d="M50 58 L74 58 L70 84 L46 84 Z" fill="#FFF"/>
    <path d="M74 58 L98 58 L94 84 L70 84 Z" fill="#FF3E6C"/>
    <path d="M98 58 L122 58 L118 84 L94 84 Z" fill="#FFF"/>
    <path d="M122 58 L146 58 L142 84 L118 84 Z" fill="#FF3E6C"/>
    <path d="M146 58 L170 58 L166 84 L142 84 Z" fill="#FFF"/>
    <path d="M170 58 L194 58 L190 84 L166 84 Z" fill="#FF3E6C"/>
    <path d="M194 58 L218 58 L214 84 L190 84 Z" fill="#FFF"/>
  </g>
  <path d="M130 58 L130 36 L150 42 Z" fill="#FFC94D" stroke="#0E0B1F" stroke-width="1.5"/>
  <line x1="130" y1="36" x2="130" y2="28" stroke="#0E0B1F" stroke-width="1.5"/>
  <polygon points="50,108 210,108 220,128 40,128" fill="url(#wood)" stroke="#0E0B1F" stroke-width="1.5"/>
  <polygon points="40,128 220,128 220,160 40,160" fill="#B97024" stroke="#0E0B1F" stroke-width="1.5"/>
  <circle cx="80" cy="100" r="10" fill="#FF3E6C" stroke="#0E0B1F" stroke-width="1.2"/>
  <circle cx="104" cy="96" r="10" fill="#79C24A" stroke="#0E0B1F" stroke-width="1.2"/>
  <circle cx="128" cy="100" r="10" fill="#FFC94D" stroke="#0E0B1F" stroke-width="1.2"/>
  <circle cx="152" cy="96" r="10" fill="#FF7A3A" stroke="#0E0B1F" stroke-width="1.2"/>
  <circle cx="176" cy="100" r="10" fill="#6B4BFF" stroke="#0E0B1F" stroke-width="1.2"/>
  <rect x="96" y="138" width="68" height="18" rx="4" fill="#FFF8EE" stroke="#0E0B1F" stroke-width="1.5"/>
  <text x="130" y="151" text-anchor="middle" font-size="11" font-family="Space Grotesk" font-weight="700" fill="#0E0B1F">ตลาดไทย</text>
</svg>
''';

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      _svg,
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  }
}
