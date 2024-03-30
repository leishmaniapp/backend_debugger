import 'package:fpdart/fpdart.dart';
import 'package:backend_debugger/exception.dart';
import 'package:backend_debugger/proto/types.pb.dart';

extension StatusResponseToException on StatusResponse {
  Option<CustomException> toException() => switch (code) {
        StatusCode.OK => const Option.none(),
        StatusCode.INTERNAL_SERVER_ERROR =>
          Some(InternalServerError(description)),
        StatusCode.INVALID_TOKEN => Some(InvalidTokenException(description)),
        StatusCode.BAD_REQUEST => Some(BadRequestException(description)),
        _ => Some(UndefinedServerException(description)),
      };
}
