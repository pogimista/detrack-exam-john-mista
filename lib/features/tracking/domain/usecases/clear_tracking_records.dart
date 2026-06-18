import '../../../../core/domain/usecases/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../repositories/tracking_record_repository.dart';

class ClearTrackingRecords implements BaseUseCase<void, NoParams> {
  final TrackingRecordRepository repository;

  const ClearTrackingRecords(this.repository);

  @override
  Future<Result<void>> call(NoParams params) => repository.clearRecords();
}
