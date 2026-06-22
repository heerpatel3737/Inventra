import 'package:flutter/material.dart';
import '../core/constants/app_routes.dart';
import 'custom_drawer.dart';

class ModuleScaffold extends StatelessWidget {
  final String title;
  final String route;
  final List<Widget> children;
  final List<Widget>? actions;
  final FloatingActionButton? floatingActionButton;
  final Widget? header;

  const ModuleScaffold({
    super.key,
    required this.title,
    required this.route,
    required this.children,
    this.actions,
    this.floatingActionButton,
    this.header,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      drawer: route == AppRoutes.login || route == AppRoutes.splash ? null : CustomDrawer(currentRoute: route),
      floatingActionButton: floatingActionButton,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: constraints.maxWidth > 1280 ? 1280 : constraints.maxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (header != null) ...[
                      header!,
                      const SizedBox(height: 16),
                    ],
                    ...children,
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


