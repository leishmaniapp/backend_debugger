import 'package:screwdriver/screwdriver.dart';

part 'stack.dart';
part 'cause.dart';

part 'unknown_exception.dart';

part 'serialization/serialization_exception.dart';
part 'serialization/json_serialization_exception.dart';

part 'network/network_exception.dart';
part 'network/invalid_scheme_exception.dart';
part 'network/remote_service_exception.dart';

part 'network/server/remote_server_exception.dart';
part 'network/server/bad_request_exception.dart';
part 'network/server/internal_server_exception.dart';
part 'network/server/undefined_server_exception.dart';
part 'network/server/resource_not_found_exception.dart';

part 'network/server/auth/auth_exception.dart';
part 'network/server/auth/invalid_credentials_exception.dart';
part 'network/server/auth/invalid_token_exception.dart';
part 'network/server/auth/unauthenticated_exception.dart';

/// Custom type of exception only for the application to use
sealed class CustomException
    with PrintsExceptionStack
    implements Exception, HasCause {
  /// Get the cause of the [Exception]
  ExceptionStack children;
  CustomException(ExceptionStack children)
      : children = [
          CustomException,
          ...children,
        ];

  @override
  ExceptionStack get exceptionStack => children;
}
