import 'core/config/app_config.dart';
import 'main.dart' as app;

void main() async {
  AppConfig.instance = const AppConfig(
    flavor: Flavor.staging,
    appName: 'My App Staging',
  );
  await app.bootstrap();
}
