import 'dart:async';

/// What a fixture repository method should do when called — configures one
/// method's behavior independently of any other method on the same fixture.
sealed class FixtureResult<T> {
  const FixtureResult();

  Future<T> resolve();
}

class FixtureSuccess<T> extends FixtureResult<T> {
  const FixtureSuccess(this.value);

  final T value;

  @override
  Future<T> resolve() => Future.value(value);
}

class FixtureFailure<T> extends FixtureResult<T> {
  const FixtureFailure([this.error = 'fixture failure']);

  final Object error;

  @override
  Future<T> resolve() => Future.error(Exception(error));
}

/// Never completes -- for asserting a page's loading state.
class FixturePending<T> extends FixtureResult<T> {
  const FixturePending();

  @override
  Future<T> resolve() => Completer<T>().future;
}
