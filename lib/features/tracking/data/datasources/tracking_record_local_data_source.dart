import 'package:hive/hive.dart';

abstract interface class TrackingRecordLocalDataSource {
  Future<void> addRecord(Map<String, dynamic> data);

  List<Map<dynamic, dynamic>> getAllRecords();
}

/// Persists tracking records in a local Hive box, keyed automatically by
/// insertion order via [Box.add].
class TrackingRecordLocalDataSourceImpl
    implements TrackingRecordLocalDataSource {
  final Box<Map> box;

  const TrackingRecordLocalDataSourceImpl(this.box);

  @override
  Future<void> addRecord(Map<String, dynamic> data) async {
    await box.add(data);
  }

  @override
  List<Map<dynamic, dynamic>> getAllRecords() => box.values.toList();
}
