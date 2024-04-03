import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:backend_debugger/dialogs/exception_alert_dialog.dart';
import 'package:backend_debugger/dialogs/future_loading_dialog.dart';
import 'package:backend_debugger/dialogs/simple_ignore_dialog.dart';
import 'package:backend_debugger/providers/sample_provider.dart';
import 'package:backend_debugger/routes/samples/server_connection_route.dart';
import 'package:backend_debugger/routes/samples/upload_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

/// SampleService has many possible routes (each for each provided method)
/// wrap each one of these routes in a selectable Card for nativation
class _SampleRouteDestination extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget route;
  final void Function(Widget) onClick;

  const _SampleRouteDestination({
    required this.icon,
    required this.title,
    required this.route,
    required this.subtitle,
    required this.onClick,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Card(
        child: InkWell(
          onTap: () => onClick.call(route),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 16.0,
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    icon,
                    size: 40.0,
                  ),
                  Text(
                    title,
                    style: context.textStyles.headlineSmall,
                  ),
                  Text(subtitle),
                ],
              ),
            ),
          ),
        ),
      );
}

class SamplesRoute extends StatefulWidget {
  const SamplesRoute({super.key});

  @override
  State<SamplesRoute> createState() => _SamplesRouteState();
}

class _SamplesRouteState extends State<SamplesRoute> {
  // Show the current destination
  Widget? currentDestination;

  @override
  Widget build(BuildContext context) {
    // Get the authentication provider
    final provider = context.watch<SampleProvider>();

    // Keep all of the possible routes (each for each service)
    final routes = <_SampleRouteDestination>[
      // Upload sampple
      _SampleRouteDestination(
          key: UniqueKey(),
          icon: Icons.cloud_upload_rounded,
          title: "StoreImageSample",
          subtitle: "Upload both sample image and metadata",
          onClick: (route) => setState(() => (currentDestination = route)),
          // Here goes the actual route
          route: UploadRoute(
            () => setState(() => (currentDestination = null)),
            (asset, uuid, sample, disease, stage, results) => showDialog(
              context: context,
              builder: (context) => FutureLoadingDialog(
                // Call the sample storage service
                future: provider.storeImageSample(
                    asset, uuid, sample, disease, stage, results),
                builder: (context, value) => value.data!.match(
                  () => SimpleIgnoreDialog(
                    const Text("Successfully uploaded sample"),
                    Text(
                      "Sample ($sample) for diagnosis ($uuid) successfully uploaded",
                    ),
                  ),
                  (e) => ExceptionAlertDialog(e),
                ),
              ),
            ),
          )),
    ];

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
                    ? SampleServerConnectionRoute((server) {
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
                    : (currentDestination == null)
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Wrap(
                                children: routes,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: OutlinedButton.icon(
                                    onPressed: () => (provider.service = null),
                                    icon: const Icon(Icons.power_off_rounded),
                                    label: const Text("Cancel connection")),
                              ),
                            ],
                          )
                        : currentDestination,
          )),
    );
  }
}
