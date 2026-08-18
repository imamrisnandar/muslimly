import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Terjadi kesalahan pada server']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Gagal mengambil data lokal']);
}

// Generic failure that just carries whatever message the source of the
// error already produced (an exception's toString(), a hand-written
// message, etc.) without trying to categorize it further.
class MessageFailure extends Failure {
  const MessageFailure(super.message);
}
