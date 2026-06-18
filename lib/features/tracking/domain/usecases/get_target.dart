import '../../../../core/domain/usecases/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/target.dart';
import '../repositories/tracking_repository.dart';

class GetTarget implements BaseUseCase<Target, NoParams> {
  final TrackingRepository repository;

  const GetTarget(this.repository);

  @override
  Future<Result<Target>> call(NoParams params) => repository.fetchTarget();
}
