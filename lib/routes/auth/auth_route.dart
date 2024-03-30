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
    final authProvider = context.watch<AuthProvider>();

    // If no service has been provided, open the connection view
    if (!authProvider.hasService) {
      return AuthServerConnectionView((server) {
        try {
          // Request the service from the URI
          authProvider
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
      });
    }

    return const AuthCredentialsView();
  }
}
