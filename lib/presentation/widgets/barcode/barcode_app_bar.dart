import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_count_flutter_app/core/routes_manger/routes.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/auth/auth_bloc.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/auth/auth_event.dart';
import 'package:inventory_count_flutter_app/l10n/app_localizations.dart';

class BarcodeAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;

  const BarcodeAppBar({super.key, this.title = '', this.showBack = true});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<BarcodeAppBar> createState() => _BarcodeAppBarState();
}

class _BarcodeAppBarState extends State<BarcodeAppBar> {
  bool _isNavigating = false;

  Future<void> _openSettings() async {
    if (_isNavigating) return;
    _isNavigating = true;
    try {
      await Navigator.of(context).pushNamed(Routes.settings);
    } finally {
      _isNavigating = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.select(
      (AuthBloc bloc) => bloc.state.selectedRole.toLowerCase() == 'admin',
    );
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: Colors.black87,
      leading: widget.showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                context.read<AuthBloc>().add(const AuthLogoutRequested());
                Navigator.of(context).pushReplacementNamed(Routes.login);
              },
            )
          : null,
      title: widget.title.isEmpty
          ? null
          : Text(widget.title, style: const TextStyle(color: Colors.black87)),
      actions: <Widget>[
        if (isAdmin)
          IconButton(
            tooltip: AppLocalizations.of(context)!.settings,
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
          ),
      ],
    );
  }
}
