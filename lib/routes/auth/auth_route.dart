import 'package:backend_debugger/dialogs/exception_alert_dialog.dart';
import 'package:backend_debugger/dialogs/future_loading_dialog.dart';
import 'package:backend_debugger/dialogs/simple_ignore_dialog.dart';
import 'package:backend_debugger/exception/exception.dart';
import 'package:backend_debugger/providers/auth_provider.dart';
import 'package:backend_debugger/providers/route_provider.dart';
import 'package:backend_debugger/routes/auth/credentials_route.dart';
import 'package:backend_debugger/routes/auth/token_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthRoute extends StatelessWidget {
  final AuthProvider provider;
  const AuthRoute({
    required this.provider,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return (!provider.authenticated)
        ? AuthCredentialsRoute(
            // Remove the auth service
            onCancelConnection: () => (provider.service = null),
            onAuthenticate: (email, password) => showDialog(
              context: context,
              builder: (context) => FutureLoadingDialog(
                future: provider.authenticate(email, password),
                title: "Authenticating",
                builder: (context, value) => value.data!.match(
                    () => const SimpleIgnoreDialog(
                          Text(
                            "Successfully authenticated",
                          ),
                          Text(
                            "Authentication token was successfully retrieved",
                          ),
                        ),
                    (e) => ExceptionAlertDialog(e)),
              ),
            ),
          )
        : // Show the token contents
        AuthTokenRoute(
            token: provider.tokenString,
            payload: provider.tokenPayload,
            onCancelAuth: provider.forgetToken,
            onVerifyToken: () => showDialog(
              context: context,
              builder: (context) => FutureLoadingDialog(
                future: provider.verifyToken(),
                title: "Verifying token",
                builder: (context, value) => value.data!.match(
                    () => const SimpleIgnoreDialog(
                          Text(
                            "Valid Token",
                          ),
                          Text(
                            "Authentication token was successfully validated",
                          ),
                        ),
                    (e) => (e is UnauthenticatedException)
                        ? const SimpleIgnoreDialog(
                            Text(
                              "Token validation failed (Token not valid)",
                            ),
                            Text(
                              "Token validation failed, token was either altered or invalidated",
                            ),
                          )
                        : ExceptionAlertDialog(e)),
              ),
            ),
            onInvalidateToken: () => showDialog(
              context: context,
              builder: (context) => FutureLoadingDialog(
                future: provider.invalidate(),
                title: "Invalidating current session",
                builder: (context, value) => value.data!.match(
                    () => const SimpleIgnoreDialog(
                          Text(
                            "Token invalidation completed",
                          ),
                          Text(
                            "For security reasons, even if the token is not invalidated, an OK response will be sent. Please manually check if the token is still valid",
                          ),
                        ),
                    (e) => ExceptionAlertDialog(e)),
              ),
            ),
            onContinue: context.read<RouteProvider>().goNextRoute,
          );
  }
}
