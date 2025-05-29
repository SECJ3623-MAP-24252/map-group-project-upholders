// lib/widgets/custom_app_bar.dart
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      leading: showBackButton
          ? IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: onBackPressed ?? () => Navigator.pop(context),
            )
          : null,
      actions: actions,
      elevation: 0,
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}