import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerSingleton<AppConfig>(AppConfig.instance);
  sl.registerSingleton<Dio>(Dio());
  sl.registerSingleton<SharedPreferences>(
    await SharedPreferences.getInstance(),
  );
}
