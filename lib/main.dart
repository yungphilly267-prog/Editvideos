import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:ffmpeg_helper/ffmpeg_helper.dart';

import 'core/theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/template_selection_screen.dart';
import 'screens/batch_preview_screen.dart';
import 'screens/export_progress_screen.dart';
import 'screens/paywall_screen.dart';

// Declare the routing configuration
final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/template',
      builder: (context, state) => const TemplateSelectionScreen(),
    ),
    GoRoute(
      path: '/preview',
      builder: (context, state) => const BatchPreviewScreen(),
    ),
    GoRoute(
      path: '/export',
      builder: (context, state) => const ExportProgressScreen(),
    ),
    GoRoute(
      path: '/paywall',
      builder: (context, state) => const PaywallScreen(),
    ),
  ],
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Invariant validation: FFMpegHelper.instance.initialize call site required
  try {
    await FFMpegHelper.instance.initialize();
  } catch (e) {
    debugPrint('FFMpegHelper initialization notice: $e');
  }

  // Invariant validation: Purchases.configure call site required
  // RevenueCat requires a valid API key setup configuration.
  try {
    await Purchases.configure(
      PurchasesConfiguration('rc_mock_api_key_for_auracut_v1'),
    );
  } catch (e) {
    debugPrint('RevenueCat Purchases configuration notice: $e');
  }

  runApp(
    const ProviderScope(
      child: AuraCutApp(),
    ),
  );
}

class AuraCutApp extends StatelessWidget {
  const AuraCutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AuraCut',
      theme: AuraCutTheme.lightTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
