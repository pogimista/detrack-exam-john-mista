# Flutter Location Tracking Exam

A Flutter app that tracks a device's location against a target coordinate, built with
Clean Architecture (data / domain / presentation) and BLoC.

## Features

- **Start / Stop Tracking** — toggle button that fetches a target from the backend
  endpoint and polls the device's location every 5 seconds while in the foreground.
- **Distance Calculation** — Haversine distance from the device to the target on every
  reading, shown in metres/kilometres.
- **Data Storage** — every reading (timestamp, latitude, longitude, distance) is
  persisted locally with Hive.
- **UI Display** — all captured readings in a scrollable, animated list.
- **Filtering** — limit the visible list to the most recent 5 / 10 / 15 / 20 readings.
- **Clear cached data** — wipes all stored readings from the device.

## Getting Started

```bash
flutter pub get
flutter run
```

### Build Flavors

The Android app defines three flavors (`dev`, `staging`, `prod`), each paired with its
own entry point. Running plain `flutter run` targets `prod`/`lib/main.dart`, but on
Android you must pass `--flavor` explicitly or the Gradle build will fail to locate the
output APK. Use the matching pair:

```bash
flutter run --flavor dev -t lib/main_dev.dart
flutter run --flavor staging -t lib/main_staging.dart
flutter run --flavor prod          # lib/main.dart is the default entry point
```

`--flavor` is an Android/iOS/macOS-only flag; omit it when running on Windows, Chrome,
or Edge.

The app requests foreground location permission on first use (Android:
`ACCESS_FINE_LOCATION` / `ACCESS_COARSE_LOCATION`; iOS:
`NSLocationWhenInUseUsageDescription`, already declared in `Info.plist`).

## Mock Backend Endpoint

Rather than standing up a separate server, the mock backend is implemented **in-app**
via a Dio interceptor — this is the most convenient option and requires **no setup**
on your part.

- `lib/core/network/mock_target_interceptor.dart` intercepts any request to
  `GET /targets/current` and resolves it locally with:

  ```json
  {
    "id": "001",
    "target_lat": 1.265,
    "target_lng": 103.695
  }
  ```

- The interceptor is registered on the shared `Dio` instance in
  `lib/core/di/service_locator.dart`, so the rest of the app (the remote data source,
  repository, use case) talks to it exactly as it would a real HTTP endpoint — `Dio`
  still goes through its normal request pipeline, the response is just resolved
  without an actual network round-trip.
- The endpoint path lives in
  `lib/features/tracking/data/datasources/tracking_remote_data_source.dart` as
  `targetEndpointPath`.

### Swapping in a real backend

No code changes are needed beyond removing the mock:

1. Point `AppConfig.apiBaseUrl` (in `lib/core/config/app_config.dart`) at your server,
   e.g. run with `flutter run --dart-define=API_BASE_URL=https://your-api.example.com`.
2. Remove `MockTargetInterceptor()` from the `Dio` registration in
   `lib/core/di/service_locator.dart`.
3. Ensure your server returns the same JSON shape at `GET /targets/current` shown
   above.

## Project Structure

```
lib/
  core/                     # shared app shell: DI, router, theme, error types
  features/
    splash/
    tracking/
      data/                 # models, data sources, repository implementations
      domain/                # entities, repository interfaces, use cases
      presentation/          # BLoC, screens, widgets
```
