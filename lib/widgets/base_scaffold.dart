// Copyright (c) 2025 Dinda Hanifa. All rights reserved.

import 'package:flutter/material.dart';

class BaseScaffold extends StatelessWidget {
  final Widget child;
  final Widget? title;
  final Color backgroundColor;
  final Color appBarColor;
  final Color titleColor;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool showCopyright;

  const BaseScaffold({
    super.key,
    required this.child,
    this.title,
    this.backgroundColor = Colors.white,
    this.appBarColor = Colors.orange,
    this.titleColor = Colors.white,
    this.actions,
    this.floatingActionButton,
    this.showCopyright = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: title != null
            ? DefaultTextStyle(
                style: TextStyle(color: titleColor, fontSize: 18, fontWeight: FontWeight.bold),
                child: title!,
              )
            : null,
        iconTheme: IconThemeData(color: titleColor),
        actions: actions,
      ),
      floatingActionButton: floatingActionButton,
      body: Column(
        children: [
          Expanded(child: child),
          if (showCopyright)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                '© 2025 Dinda Hanifa. All rights reserved.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
