import '../error/failures.dart';

sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

final class Err<T> extends Result<T> {
  final AppFailure failure;
  const Err(this.failure);
}
