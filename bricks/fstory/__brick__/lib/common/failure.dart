import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable{
  final String msg;

  const Failure(this.msg);

  @override
  List<Object> get props => [msg];
}

class ServerFailure extends Failure{
  const ServerFailure(super.msg);
}

class ConnectionFailure extends Failure{
  const ConnectionFailure(super.msg);
}

