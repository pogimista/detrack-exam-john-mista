import 'core/config/app_config.dart';
import 'main.dart' as app;

void main() async {
  AppConfig.instance = const AppConfig(
    flavor: Flavor.dev,
    appName: 'My App Dev',
  );
  await app.bootstrap();
}
