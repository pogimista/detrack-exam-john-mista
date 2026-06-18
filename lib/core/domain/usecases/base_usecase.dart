import '../../utils/result.dart';

abstract interface class BaseUseCase<T, P> {
  Future<Result<T>> call(P params);
}

final class NoParams {
  const NoParams();
}
