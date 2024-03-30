import 'package:backend_debugger/dialogs/exception_alert_dialog.dart';
import 'package:backend_debugger/dialogs/future_loading_dialog.dart';
import 'package:backend_debugger/dialogs/simple_ignore_dialog.dart';
import 'package:backend_debugger/providers/auth_provider.dart';
import 'package:backend_debugger/providers/route_provider.dart';
import 'package:backend_debugger/routes/auth/credentials_view.dart';
import 'package:backend_debugger/routes/auth/server_connection_view.dart';
import 'package:backend_debugger/routes/auth/token_view.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class AuthRoute extends StatelessWidget {
  const AuthRoute({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the authentication provider
    final provider = context.watch<AuthProvider>();

    // Create the widget
    return Center(
      child: Container(
          constraints: const BoxConstraints(maxWidth: 500.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            switchInCurve: Curves.ease,
            switchOutCurve: Curves.ease,
            child:
                // Check if service is available
                (!provider.hasService)
                    // If no service has been provided, open the connection view
                    ? AuthServerConnectionView((server) {
                        try {
                          // Request the service from the URI
                          provider
                              .requestServiceFromInfrastructureWithUri(server)
                              .match(() {}, (e) => throw e);
                        }
                        // Catch the exceptions
                        on Exception catch (e) {
                          // Show an exception dialog
                          GetIt.I.get<Logger>().e(e.toString());
                          showDialog(
                            context: context,
                            builder: (context) => ExceptionAlertDialog(e),
                          );
                        }
                      })
                    :
                    // If not authenticated, show credentials screen
                    (!provider.authenticated)
                        ? AuthCredentialsView(
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
                        AuthTokenView(
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
                                    (e) => ExceptionAlertDialog(e)),
                              ),
                            ),
                            onContinue:
                                context.read<RouteProvider>().goNextRoute,
                          ),
          )),
    );
  }
}
