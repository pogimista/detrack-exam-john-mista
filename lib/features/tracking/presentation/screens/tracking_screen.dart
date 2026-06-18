import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/tracking_bloc.dart';
import '../bloc/tracking_event.dart';
import '../bloc/tracking_state.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TrackingBloc>(),
      child: const _TrackingView(),
    );
  }
}

class _TrackingView extends StatelessWidget {
  const _TrackingView();

  bool _isTracking(TrackingState state) => state is TrackingInProgress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Location Tracking')),
      body: BlocBuilder<TrackingBloc, TrackingState>(
        builder: (context, state) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatus(context, state),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: () {
                      final bloc = context.read<TrackingBloc>();
                      if (_isTracking(state)) {
                        bloc.add(const StopTrackingRequested());
                      } else {
                        bloc.add(const StartTrackingRequested());
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: _isTracking(state)
                          ? Colors.red
                          : AppColors.primary,
                      minimumSize: const Size(200, 48),
                    ),
                    child: Text(
                      _isTracking(state) ? 'Stop Tracking' : 'Start Tracking',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatus(BuildContext context, TrackingState state) {
    switch (state) {
      case TrackingIdle():
        return Text('Tracking stopped', style: context.bodyMedium);
      case TrackingStarting():
        return Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Fetching target...', style: context.bodyMedium),
          ],
        );
      case TrackingInProgress(target: final target, lastLocation: final loc):
        return Column(
          children: [
            Text('Target #${target.id}', style: context.titleMedium),
            Text(
              'target_lat: ${target.targetLat}, target_lng: ${target.targetLng}',
              style: context.bodySmall,
            ),
            const SizedBox(height: 16),
            Text('Tracking…', style: context.titleMedium),
            const SizedBox(height: 8),
            Text(
              loc == null
                  ? 'Waiting for location…'
                  : 'lat: ${loc.latitude}, lng: ${loc.longitude}\n'
                      'updated: ${loc.timestamp.toIso8601String()}',
              style: context.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        );
      case TrackingFailure(message: final message):
        return Text(
          'Error: $message',
          style: context.bodyMedium.copyWith(color: Colors.red),
          textAlign: TextAlign.center,
        );
    }
  }
}
