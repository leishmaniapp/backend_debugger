import 'package:backend_debugger/errors/network/network_error.dart';

class HttpError extends NetworkError {
  int httpStatusCode;
  String? body;
  HttpError(this.httpStatusCode, {this.body}) : super();

  @override
  String get reason =>
      "Failed HTTP request with code: $httpStatusCode (${body ?? "No body"})";
}
