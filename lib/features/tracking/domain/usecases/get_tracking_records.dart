import '../../../../core/domain/usecases/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/tracking_record.dart';
import '../repositories/tracking_record_repository.dart';

class GetTrackingRecords
    implements BaseUseCase<List<TrackingRecord>, NoParams> {
  final TrackingRecordRepository repository;

  const GetTrackingRecords(this.repository);

  @override
  Future<Result<List<TrackingRecord>>> call(NoParams params) =>
      repository.getRecords();
}
