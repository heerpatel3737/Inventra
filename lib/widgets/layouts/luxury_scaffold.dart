import 'package:flutter/material.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_sizes.dart';
import '../navigation/luxury_sidebar.dart';

class LuxuryScaffold extends StatelessWidget {
  final String route;
  final String title;
  final List<Widget> children;
  final Widget? header;
  final List<Widget>? actions;
  final FloatingActionButton? floatingActionButton;

  const LuxuryScaffold({
    super.key,
    required this.route,
    required this.title,
    required this.children,
    this.header,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      drawer: route == AppRoutes.login || route == AppRoutes.splash ? null : LuxurySidebar(currentRoute: route),
      floatingActionButton: floatingActionButton,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: constraints.maxWidth > AppSizes.maxContentWidth ? AppSizes.maxContentWidth : constraints.maxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (header != null) ...[
                      header!,
                      const SizedBox(height: 18),
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

