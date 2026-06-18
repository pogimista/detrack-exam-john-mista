import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/string_extensions.dart';
import '../../domain/entities/distance.dart';
import '../../domain/entities/location_point.dart';
import '../../domain/entities/target.dart';
import '../../domain/entities/tracking_record.dart';
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

class _TrackingView extends StatefulWidget {
  const _TrackingView();

  @override
  State<_TrackingView> createState() => _TrackingViewState();
}

class _TrackingViewState extends State<_TrackingView> {
  static const List<int> _filterOptions = [5, 10, 15, 20];

  int _limit = _filterOptions.last;

  bool _isTracking(TrackingState state) => state is TrackingInProgress;

  Future<void> _confirmClearCache(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear cached data?'),
        content: const Text(
          'This will permanently delete all stored readings from this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<TrackingBloc>().add(const ClearRecordsRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Location Tracking'),
        actions: [
          IconButton(
            tooltip: 'Clear cached data',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmClearCache(context),
          ),
        ],
      ),
      body: BlocBuilder<TrackingBloc, TrackingState>(
        builder: (context, state) {
          final records = state.records;
          final visibleRecords = records.take(_limit).toList();
          return SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: _StatusCard(state: state),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _ToggleButton(
                    isTracking: _isTracking(state),
                    onPressed: () {
                      final bloc = context.read<TrackingBloc>();
                      if (_isTracking(state)) {
                        bloc.add(const StopTrackingRequested());
                      } else {
                        bloc.add(const StartTrackingRequested());
                      }
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Captured Readings', style: context.titleMedium),
                      Text(
                        'Showing ${visibleRecords.length} of ${records.length}',
                        style: context.labelSmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _ReadingsFilter(
                    options: _filterOptions,
                    selected: _limit,
                    onSelected: (value) => setState(() => _limit = value),
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: visibleRecords.isEmpty
                      ? _EmptyReadingsView()
                      : _ReadingsList(records: visibleRecords),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ReadingsFilter extends StatelessWidget {
  const _ReadingsFilter({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<int> options;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SegmentedButton<int>(
        segments: [
          for (final option in options)
            ButtonSegment(value: option, label: Text('$option')),
        ],
        selected: {selected},
        showSelectedIcon: false,
        onSelectionChanged: (selection) => onSelected(selection.first),
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: AppColors.primary,
          selectedForegroundColor: Colors.white,
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.state});

  final TrackingState state;

  @override
  Widget build(BuildContext context) {
    final active = state is TrackingInProgress;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: switch (state) {
        TrackingIdle() => _IdleStatus(),
        TrackingStarting() => const _StartingStatus(),
        TrackingInProgress(
          target: final target,
          lastLocation: final loc,
          distance: final distance,
        ) =>
          _ActiveStatus(target: target, location: loc, distance: distance),
        TrackingFailure(
          message: final message,
          permanentlyDenied: final permanentlyDenied,
        ) =>
          _FailureStatus(
            message: message,
            permanentlyDenied: permanentlyDenied,
          ),
      },
    );
  }
}

class _IdleStatus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 22,
          backgroundColor: Color(0xFFEFF1F8),
          child: Icon(Icons.location_off_outlined, color: AppColors.secondary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tracking stopped', style: context.titleMedium),
              const SizedBox(height: 2),
              Text(
                'Start tracking to fetch the target and begin recording readings',
                style: context.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StartingStatus extends StatelessWidget {
  const _StartingStatus();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
        const SizedBox(width: 16),
        Text('Fetching target…', style: context.titleMedium),
      ],
    );
  }
}

class _ActiveStatus extends StatelessWidget {
  const _ActiveStatus({
    required this.target,
    required this.location,
    required this.distance,
  });

  final Target target;
  final LocationPoint? location;
  final Distance? distance;

  @override
  Widget build(BuildContext context) {
    final distance = this.distance;
    final location = this.location;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white24,
              child: Icon(Icons.gps_fixed, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tracking Target #${target.id}',
                    style: context.titleMedium.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'target: ${target.targetLat}, ${target.targetLng}',
                    style: context.bodySmall.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(Icons.straighten, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      distance == null
                          ? 'Calculating distance…'
                          : distance.formatted,
                      style: context.titleLarge.copyWith(color: Colors.white),
                    ),
                    Text(
                      location == null
                          ? 'Waiting for first reading…'
                          : 'lat: ${location.latitude.toStringAsFixed(5)}, '
                                'lng: ${location.longitude.toStringAsFixed(5)}\n'
                                'updated: ${location.timestamp.formattedDateTime}',
                      style: context.labelSmall.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FailureStatus extends StatelessWidget {
  const _FailureStatus({required this.message, this.permanentlyDenied = false});

  final String message;
  final bool permanentlyDenied;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 22,
          backgroundColor: Color(0xFFFDECEC),
          child: Icon(Icons.error_outline, color: Colors.red),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tracking failed',
                style: context.titleMedium.copyWith(color: Colors.red),
              ),
              const SizedBox(height: 2),
              Text(message, style: context.bodySmall),
              if (permanentlyDenied) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Geolocator.openAppSettings(),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  child: const Text('Open Settings'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({required this.isTracking, required this.onPressed});

  final bool isTracking;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: isTracking
              ? const Color(0xFFE0433D)
              : AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: Icon(isTracking ? Icons.stop_rounded : Icons.play_arrow_rounded),
        label: Text(
          isTracking ? 'Stop Tracking' : 'Start Tracking',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _EmptyReadingsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.timeline_outlined,
              size: 48,
              color: AppColors.secondary,
            ),
            const SizedBox(height: 12),
            Text(
              'No readings captured yet',
              style: context.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

String _recordKey(TrackingRecord record) =>
    '${record.timestamp.microsecondsSinceEpoch}';

class _ReadingsList extends StatelessWidget {
  const _ReadingsList({required this.records});

  final List<TrackingRecord> records;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: records.length,
      // Lets Flutter match items by key instead of position, so a record
      // that shifts down the list keeps its element (no re-animation) while
      // a genuinely new record gets a fresh element (and plays the entrance
      // animation below).
      findChildIndexCallback: (key) {
        final valueKey = key as ValueKey<String>;
        final index = records.indexWhere(
          (r) => _recordKey(r) == valueKey.value,
        );
        return index == -1 ? null : index;
      },
      itemBuilder: (context, index) {
        final record = records[index];
        return _NewReadingEntrance(
          key: ValueKey(_recordKey(record)),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: const Icon(
                    Icons.location_on,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'lat: ${record.latitude.toStringAsFixed(5)}, '
                        'lng: ${record.longitude.toStringAsFixed(5)}',
                        style: context.bodyMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        record.timestamp.formattedDateTime,
                        style: context.labelSmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    record.distance.formatted,
                    style: context.labelMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Fades, slides, and briefly highlights a newly inserted reading so it
/// stands out from the rest of the list. Plays once per element instance —
/// existing readings that merely shift position reuse their element (via
/// [ListView.builder]'s `findChildIndexCallback`) and never replay it.
class _NewReadingEntrance extends StatefulWidget {
  const _NewReadingEntrance({super.key, required this.child});

  final Widget child;

  @override
  State<_NewReadingEntrance> createState() => _NewReadingEntranceState();
}

class _NewReadingEntranceState extends State<_NewReadingEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.12),
          end: Offset.zero,
        ).animate(curved),
        child: DecoratedBoxTransition(
          decoration: DecorationTween(
            begin: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            end: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0),
              borderRadius: BorderRadius.circular(16),
            ),
          ).animate(curved),
          child: widget.child,
        ),
      ),
    );
  }
}
