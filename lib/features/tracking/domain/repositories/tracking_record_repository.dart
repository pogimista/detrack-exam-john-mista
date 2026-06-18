import '../../../../core/utils/result.dart';
import '../entities/tracking_record.dart';

abstract interface class TrackingRecordRepository {
  Future<Result<void>> saveRecord(TrackingRecord record);

  Future<Result<List<TrackingRecord>>> getRecords();
}
