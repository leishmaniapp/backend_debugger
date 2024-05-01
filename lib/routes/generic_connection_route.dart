import 'package:backend_debugger/dialogs/exception_alert_dialog.dart';
import 'package:backend_debugger/providers/provider_with_service.dart';
import 'package:backend_debugger/routes/server_connection_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

/// Create a service route with a connection page for provider of type [P]
class GenericConnectionRoute<P extends ProviderWithService>
    extends StatelessWidget {
  /// [ServerConnectionRoute] connection title
  final String connectionTitle;

  /// Widget builder once the connection is stablished
  final Widget Function(BuildContext contex, P provider) builder;

  const GenericConnectionRoute({
    required this.connectionTitle,
    required this.builder,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Consumer<P>(
        builder: (context, provider, _) => AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          switchInCurve: Curves.ease,
          switchOutCurve: Curves.ease,
          child: (!provider.hasService)
              // If no service has been provided, open the connection view
              ? ServerConnectionRoute(
                  title: connectionTitle,
                  onServerProvided: (server) {
                    try {
                      // Request the service from the URI
                      provider
                          .requestServiceFromInfrastructureWithUri(server)
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
                  })
              : this.builder(context, provider),
        ),
      );
}
