import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import '../../shared/widgets/blob_3d.dart';

/// Shown only while [AuthController] is bootstrapping.
/// The router redirects away as soon as auth state resolves.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TpColors.paper,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Blob3D(size: 100, hue: BlobHue.mango),
            SizedBox(height: 24),
            CircularProgressIndicator(color: TpColors.pink, strokeWidth: 2.5),
          ],
        ),
      ),
    );
  }
}
