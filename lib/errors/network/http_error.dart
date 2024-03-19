import 'package:ws_debugger/errors/network/network_error.dart';

class HttpError extends NetworkError {
  int httpStatusCode;
  HttpError(this.httpStatusCode) : super();

  @override
  String get reason => "Failed HTTP request with code: $httpStatusCode";
}
