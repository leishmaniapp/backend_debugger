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

class SamplesRoute extends StatelessWidget {
  final SamplesProvider provider;
  const SamplesRoute({
    required this.provider,
    super.key,
  });

  @override
  Widget build(BuildContext context) => GenericMenuRoute(
        onExit: () => provider.disconnect(),
        onNext: context.read<RouteProvider>().goNextRoute,
        destinations: <MenuRouteDestination>[
          // Store sampple
          MenuRouteDestination(
              icon: Icons.upload_file_rounded,
              title: "StoreImageSample",
              subtitle: "Upload both sample image and metadata",
              builder: (onExit) => StoreImageSampleRoute(
                    onCancel: onExit,
                    onStoreImageSample: (asset, sample) => showDialog(
                      context: context,
                      builder: (context) => FutureLoadingDialog(
                        // Call the sample storage service
                        future: provider.storeImageSample(asset, sample),
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

          MenuRouteDestination(
              icon: Icons.cloud_sync,
              title: "UpdateSample",
              subtitle: "Update metadata on an already existing sample",
              builder: (onExit) => UpdateSampleRoute(
                    onCancel: onExit,
                    onUpdateSample: (sample) => showDialog(
                      context: context,
                      builder: (context) => FutureLoadingDialog(
                        // Call the sample storage service
                        future: provider.updateSample(sample),
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

          MenuRouteDestination(
              icon: Icons.file_download_rounded,
              title: "GetSample",
              subtitle: "Get a sample metadata from the server",
              builder: (onExit) => GetOrDeleteSampleRoute(
                    onCancel: onExit,
                    onGetSample: (uuid, sample) =>
                        provider.getSample(uuid, sample).apply((future) {
                      // Show the dialog
                      showDialog(
                        context: context,
                        builder: (context) => FutureLoadingDialog(
                          // Call the sample storage service
                          future: future,
                          builder: (context, value) => value.data!.match(
                            (CustomException left) =>
                                ExceptionAlertDialog(left),
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

          MenuRouteDestination(
              icon: Icons.delete,
              title: "DeleteSample",
              subtitle: "Delete a sample metadata from the server",
              builder: (onExit) => GetOrDeleteSampleRoute(
                    onCancel: onExit,
                    onGetSample: (uuid, sample) =>
                        provider.deleteSample(uuid, sample).apply((future) {
                      // Show the dialog
                      showDialog(
                        context: context,
                        builder: (context) => FutureLoadingDialog(
                          // Call the sample storage service
                          future: future,
                          builder: (context, value) => value.data!.match(
                            (CustomException left) =>
                                ExceptionAlertDialog(left),
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

          MenuRouteDestination(
            icon: Icons.delivery_dining_rounded,
            title: "GetUndeliveredBySpecialist",
            subtitle: "Get undelivered samples for the specialist",
            builder: (onExit) => GetUndeliveredRoute(
                onCancel: onExit,
                onGetResults: (email) async => (await provider
                        .getUndeliveredSamples(email)
                        .apply((future) =>
                            // Show the dialog
                            showDialog<
                                fp.Either<CustomException, List<Sample>>>(
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
        ],
      );
}
