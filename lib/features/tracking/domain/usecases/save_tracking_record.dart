import '../../../../core/domain/usecases/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/tracking_record.dart';
import '../repositories/tracking_record_repository.dart';

class SaveTrackingRecord implements BaseUseCase<void, TrackingRecord> {
  final TrackingRecordRepository repository;

  const SaveTrackingRecord(this.repository);

  @override
  Future<Result<void>> call(TrackingRecord params) =>
      repository.saveRecord(params);
}
