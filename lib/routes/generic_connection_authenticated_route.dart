import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:backend_debugger/dialogs/exception_alert_dialog.dart';
import 'package:backend_debugger/providers/auth_provider.dart';
import 'package:backend_debugger/providers/provider_with_service.dart';
import 'package:backend_debugger/routes/server_connection_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

/// Create a service route with a connection page for provider of type [P]
class GenericConnectionAuthenticatedRoute<P extends ProviderWithService>
    extends StatelessWidget {
  /// [ServerConnectionRoute] connection title
  final String connectionTitle;

  /// Widget builder once the connection is stablished
  final Widget Function(BuildContext contex, P provider) builder;

  const GenericConnectionAuthenticatedRoute({
    required this.connectionTitle,
    required this.builder,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // If not authenticated
    if (!authProvider.authenticated) {
      return const Scaffold(
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.key_rounded),
                SizedBox(
                  height: 16.0,
                ),
                Text(
                  "This route requires authentication",
                )
              ],
            ),
          ),
        ),
      );
    }

    return Consumer<P>(
      builder: (context, provider, _) => Stack(
        alignment: Alignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            switchInCurve: Curves.ease,
            switchOutCurve: Curves.ease,
            child: (!provider.hasService)
                // If no service has been provided, open the connection view
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ServerConnectionRoute(
                        title: connectionTitle,
                        onServerProvided: (server) {
                          try {
                            // Request the service from the URI
                            provider
                                .requestServiceFromInfrastructureWithUri(
                                  server,
                                  authProvider.tokenString,
                                )
                                .match(() {}, (e) => throw e);
                          }
                          // Catch the exceptions
                          on Exception catch (e, s) {
                            // Show an exception dialog
                            GetIt.I.get<Logger>().e(
                                  "Failed to connect to server",
                                  error: e,
                                  stackTrace: s,
                                );
                            showDialog(
                              context: context,
                              builder: (context) => ExceptionAlertDialog(e),
                            );
                          }
                        }),
                  )
                : Scaffold(
                    appBar: AppBar(
                      centerTitle: true,
                      title: Text(
                        provider.toString(),
                        style: context.textStyles.bodyMedium,
                      ),
                    ),
                    body: Center(
                      child: this.builder(
                        context,
                        provider,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
