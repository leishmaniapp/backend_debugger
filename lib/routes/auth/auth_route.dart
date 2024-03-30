import 'package:backend_debugger/dialogs/exception_alert_dialog.dart';
import 'package:backend_debugger/providers/auth_provider.dart';
import 'package:backend_debugger/routes/auth/credentials_view.dart';
import 'package:backend_debugger/routes/auth/server_connection_view.dart';
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
                      : AuthCredentialsView(
                          // Remove the auth service
                          onCancelConnection: () => (provider.service = null),
                          onAuthenticate: (email, password) {},
                        ))),
    );
  }
}
