import 'package:backend_debugger/errors/generic_error.dart';

class InvalidStateError extends GenericError {
  String what;
  InvalidStateError(this.what) : super("InvalidStateError due to $what");
}
