import 'package:flutter/material.dart';
import 'core/config/app_config.dart';
import 'core/di/service_locator.dart' as di;
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  AppConfig.instance = const AppConfig(
    flavor: Flavor.prod,
    appName: 'My App',
  );
  await bootstrap();
}

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConfig.instance.appName,
      debugShowCheckedModeBanner: AppConfig.instance.isDev,
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
    );
  }
}
