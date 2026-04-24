import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure([this.message = 'An unexpected error occurred']);
  final String message;

  @override
  List<Object> get props => [message];
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache failure']);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure([super.message = 'Database failure']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Item not found']);
}
