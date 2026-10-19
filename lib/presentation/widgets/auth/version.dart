import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AuthVersionText extends StatefulWidget {
  const AuthVersionText({super.key});

  @override
  State<AuthVersionText> createState() => _AuthVersionTextState();
}

class _AuthVersionTextState extends State<AuthVersionText> {
  late final Future<PackageInfo> _packageInfoFuture;

  @override
  void initState() {
    super.initState();
    _packageInfoFuture = PackageInfo.fromPlatform();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return FutureBuilder<PackageInfo>(
      future: _packageInfoFuture,
      builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
        String versionLabel = 'Version --';

        if (snapshot.hasData) {
          final PackageInfo info = snapshot.data!;
          versionLabel = 'Version ${info.version}';
        }

        return Text(
          versionLabel,
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        );
      },
    );
  }
}
