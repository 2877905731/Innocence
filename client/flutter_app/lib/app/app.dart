import 'package:flutter/material.dart';
import 'package:innocence_flutter/core/theme/app_theme.dart';
import 'package:innocence_flutter/core/widgets/aurora_background.dart';
import 'package:innocence_flutter/core/widgets/glass_panel.dart';
import 'package:innocence_flutter/features/auth/presentation/pages/auth_page.dart';
import 'package:innocence_flutter/features/home/presentation/pages/home_page.dart';

import 'session_controller.dart';

class InnocenceApp extends StatefulWidget {
  const InnocenceApp({
    super.key,
    required this.sessionController,
  });

  final SessionController sessionController;

  @override
  State<InnocenceApp> createState() => _InnocenceAppState();
}

class _InnocenceAppState extends State<InnocenceApp> {
  @override
  void initState() {
    super.initState();
    widget.sessionController.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Innocence',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      home: AnimatedBuilder(
        animation: widget.sessionController,
        builder: (context, _) {
          switch (widget.sessionController.status) {
            case SessionStatus.initializing:
              return const _LaunchScreen();
            case SessionStatus.unauthenticated:
              return AuthPage(sessionController: widget.sessionController);
            case SessionStatus.authenticated:
              return HomePage(
                profile: widget.sessionController.profile!,
                todayPlan: widget.sessionController.todayPlan,
                isBusy: widget.sessionController.isBusy,
                bannerMessage: widget.sessionController.bannerMessage,
                onClearBanner: widget.sessionController.clearBanner,
                onRefresh: widget.sessionController.refreshProfile,
                onLogout: widget.sessionController.logout,
                onSaveTodayPlan: widget.sessionController.saveTodayPlan,
                onToggleTodayPlanItem:
                    widget.sessionController.toggleTodayPlanItem,
              );
          }
        },
      ),
    );
  }
}

class _LaunchScreen extends StatelessWidget {
  const _LaunchScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuroraBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: const GlassPanel(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Innocence'),
                    SizedBox(height: 16),
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Restoring the current device session...',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
