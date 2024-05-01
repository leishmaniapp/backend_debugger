import 'package:backend_debugger/dialogs/exception_alert_dialog.dart';
import 'package:backend_debugger/dialogs/future_loading_dialog.dart';
import 'package:backend_debugger/dialogs/simple_ignore_dialog.dart';
import 'package:backend_debugger/exception/exception.dart';
import 'package:backend_debugger/proto/model.pb.dart';
import 'package:backend_debugger/providers/route_provider.dart';
import 'package:backend_debugger/providers/samples_provider.dart';
import 'package:backend_debugger/routes/generic_menu_route.dart';
import 'package:backend_debugger/routes/samples/get_or_delete_sample_route.dart';
import 'package:backend_debugger/routes/samples/get_undelivered_route.dart';
import 'package:backend_debugger/routes/samples/store_image_sample_route.dart';
import 'package:backend_debugger/routes/samples/update_sample_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screwdriver/screwdriver.dart';
import 'package:fpdart/fpdart.dart' as fp;

class SamplesRoute extends StatefulWidget {
  final SamplesProvider provider;
  const SamplesRoute({
    required this.provider,
    super.key,
  });

  @override
  State<SamplesRoute> createState() => _SamplesRouteState();
}

class _SamplesRouteState extends State<SamplesRoute> {
  // Show the current destination
  Widget? currentDestination;

  @override
  Widget build(BuildContext context) {
    // Keep all of the possible routes (each for each service)
    final routes = <MenuRouteDestination>[
      // Store sampple
      MenuRouteDestination(
          key: UniqueKey(),
          icon: Icons.upload_file_rounded,
          title: "StoreImageSample",
          subtitle: "Upload both sample image and metadata",
          onClick: (route) => setState(() => (currentDestination = route)),
          // Here goes the actual route
          route: StoreImageSampleRoute(
            () => setState(() => (currentDestination = null)),
            (asset, sample) => showDialog(
              context: context,
              builder: (context) => FutureLoadingDialog(
                // Call the sample storage service
                future: widget.provider.storeImageSample(asset, sample),
                builder: (context, value) => value.data!.match(
                  () => SimpleIgnoreDialog(
                    const Text("Successfully uploaded sample"),
                    Text(
                      "Sample ($sample) successfully uploaded",
                    ),
                  ),
                  (e) => ExceptionAlertDialog(e),
                ),
              ),
            ),
          )),
      // Update sampple
      MenuRouteDestination(
          key: UniqueKey(),
          icon: Icons.cloud_sync,
          title: "UpdateSample",
          subtitle: "Update metadata on an already existing sample",
          onClick: (route) => setState(() => (currentDestination = route)),
          // Here goes the actual route
          route: UpdateSampleRoute(
            () => setState(() => (currentDestination = null)),
            (sample) => showDialog(
              context: context,
              builder: (context) => FutureLoadingDialog(
                // Call the sample storage service
                future: widget.provider.updateSample(sample),
                builder: (context, value) => value.data!.match(
                  () => SimpleIgnoreDialog(
                    const Text("Successfully updated sample"),
                    Text(
                      "Sample (${sample.metadata.diagnosis}) successfully updated",
                    ),
                  ),
                  (e) => ExceptionAlertDialog(e),
                ),
              ),
            ),
          )),
      // Get a sample
      MenuRouteDestination(
          key: UniqueKey(),
          icon: Icons.file_download_rounded,
          title: "GetSample",
          subtitle: "Get a sample metadata from the server",
          onClick: (route) => setState(() => (currentDestination = route)),
          // Here goes the actual route
          route: GetOrDeleteSampleRoute(
            () => setState(() => (currentDestination = null)),
            // Get the sample and return the result
            (uuid, sample) =>
                widget.provider.getSample(uuid, sample).apply((future) {
              // Show the dialog
              showDialog(
                context: context,
                builder: (context) => FutureLoadingDialog(
                  // Call the sample storage service
                  future: future,
                  builder: (context, value) => value.data!.match(
                    (CustomException left) => ExceptionAlertDialog(left),
                    (right) => SimpleIgnoreDialog(
                      const Text("Successfully downloaded sample"),
                      Text(
                        "Sample ($sample) for diagnosis ($uuid) successfully downloaded",
                      ),
                    ),
                  ),
                ),
              );
            }).then(
              // Return the value or null
              (value) => value.getRight().toNullable(),
            ),
          )),
      // Delete the sample
      MenuRouteDestination(
          key: UniqueKey(),
          icon: Icons.delete,
          title: "DeleteSample",
          subtitle: "Delete a sample metadata from the server",
          onClick: (route) => setState(() => (currentDestination = route)),
          // Here goes the actual route
          route: GetOrDeleteSampleRoute(
            () => setState(() => (currentDestination = null)),
            // Get the sample and return the result
            (uuid, sample) =>
                widget.provider.deleteSample(uuid, sample).apply((future) {
              // Show the dialog
              showDialog(
                context: context,
                builder: (context) => FutureLoadingDialog(
                  // Call the sample storage service
                  future: future,
                  builder: (context, value) => value.data!.match(
                    (CustomException left) => ExceptionAlertDialog(left),
                    (right) => SimpleIgnoreDialog(
                      const Text("Successfully deleted sample"),
                      Text(
                        "Sample ($sample) for diagnosis ($uuid) successfully DELETED",
                      ),
                    ),
                  ),
                ),
              );
            }).then(
              // Return the value or null
              (value) => value.getRight().toNullable(),
            ),
          )),
      // Get undelivered by specialist
      MenuRouteDestination(
        key: UniqueKey(),
        icon: Icons.delivery_dining_rounded,
        title: "GetUndeliveredBySpecialist",
        subtitle: "Get undelivered samples for the specialist",
        onClick: (route) => setState(() => currentDestination = route),
        route: GetUndeliveredRoute(
            () => setState(() => (currentDestination = null)),
            (email) async => (await widget.provider
                    .getUndeliveredSamples(email)
                    .apply((future) =>
                        // Show the dialog
                        showDialog<fp.Either<CustomException, List<Sample>>>(
                          context: context,
                          builder: (context) => FutureLoadingDialog(
                            // Call the sample storage service
                            future: future,
                            builder: (context, value) => value.data!.match(
                              (CustomException left) =>
                                  ExceptionAlertDialog(left),
                              (right) => const SimpleIgnoreDialog(
                                Text("Successfully deleted sample"),
                                Text("Got all the undelivered samples"),
                              ),
                            ),
                          ),
                        )))
                .getRight()
                .toNullable()),
      )
    ];

    // Create the widget
    return (currentDestination == null)
        ? SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  children: routes,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton.icon(
                          onPressed: () => (widget.provider.service = null),
                          icon: const Icon(Icons.power_off_rounded),
                          label: const Text("Cancel connection")),
                      FilledButton.icon(
                          onPressed: context.read<RouteProvider>().goNextRoute,
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: const Text("Continue")),
                    ],
                  ),
                ),
              ],
            ),
          )
        : AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            switchInCurve: Curves.ease,
            switchOutCurve: Curves.ease,
            child: currentDestination!);
  }
}
