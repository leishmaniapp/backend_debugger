import 'package:backend_debugger/exception/exception.dart';
import 'package:test/test.dart';

void main() {
  test('Exception printing test', () {
    final exception = BadRequestException();
    final cause = exception.printExceptionCause();
    expect(cause, """Exception ocurred, showing exception stack:
> CustomException
  └ NetworkException
   └ RemoteServerException
    └ BadRequestException
Cause: Request to the server was in a bad state""");
  });
}
