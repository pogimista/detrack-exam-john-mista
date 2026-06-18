import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/tracking_record.dart';
import '../../domain/repositories/tracking_record_repository.dart';
import '../datasources/tracking_record_local_data_source.dart';
import '../models/tracking_record_model.dart';

class TrackingRecordRepositoryImpl implements TrackingRecordRepository {
  final TrackingRecordLocalDataSource localDataSource;

  const TrackingRecordRepositoryImpl(this.localDataSource);

  @override
  Future<Result<void>> saveRecord(TrackingRecord record) async {
    try {
      await localDataSource.addRecord(
        TrackingRecordModel.fromEntity(record).toMap(),
      );
      return const Success(null);
    } catch (e) {
      return Err(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<TrackingRecord>>> getRecords() async {
    try {
      final records = localDataSource
          .getAllRecords()
          .map(TrackingRecordModel.fromMap)
          .toList();
      return Success(records);
    } catch (e) {
      return Err(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> clearRecords() async {
    try {
      await localDataSource.clearAll();
      return const Success(null);
    } catch (e) {
      return Err(CacheFailure(e.toString()));
    }
  }
}
