import 'package:backend_debugger/errors/network/network_error.dart';

class FailedConnectionError extends NetworkError {
  final String where;
  FailedConnectionError(this.where) : super();

  @override
  String get reason => "Failed to connect to remote server ($where)";
}
