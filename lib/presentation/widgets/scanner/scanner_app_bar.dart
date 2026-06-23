import 'package:flutter/material.dart';


class ScannerAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;

  const ScannerAppBar({super.key, this.title = '', this.showBack = true});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: Colors.black87,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).maybePop(),
            )
          : null,
      title: title.isEmpty
          ? null
          : Text(title, style: const TextStyle(color: Colors.black87)),
      actions: const <Widget>[],
    );
  }
}
