import 'package:backend_debugger/proto/model.pb.dart';
import 'package:fpdart/fpdart.dart';
import 'package:backend_debugger/exception/exception.dart';
import 'package:backend_debugger/proto/types.pb.dart';

extension StatusResponseToException on StatusResponse {
  Option<RemoteServerException> toException() => switch (code) {
        // Ok code
        StatusCode.OK => const Option.none(),
        // Server Errors
        StatusCode.INTERNAL_SERVER_ERROR =>
          Some(InternalServerException(description)),
        StatusCode.NOT_FOUND => Some(ResourceNotFoundException()),
        StatusCode.BAD_REQUEST => Some(BadRequestException(description)),
        StatusCode.UNPROCESSABLE_CONTENT =>
          Some(UnprocessableContentException(description)),
        // Auth errors
        StatusCode.INVALID_TOKEN => Some(InvalidTokenException(description)),
        StatusCode.FORBIDDEN => Some(InvalidCredentialsException()),
        StatusCode.UNAUTHENTICATED => Some(UnauthenticatedException()),
        StatusCode.IM_A_TEAPOD || StatusCode.UNSPECIFIED => Some(
            UndefinedServerException(
                "Unspecified by server ($code) -> ${description.isEmpty ? "no description provided" : description}"),
          ),
        _ => Some(UndefinedServerException(
            "($code) -> ${description.isEmpty ? "no description provided" : description}")),
      };
}

extension SpecialistSubtypesConvertion on Specialist {
  Specialist_Record toRecord() => Specialist_Record(
        email: email,
        name: name,
      );
}
