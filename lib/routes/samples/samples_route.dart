import 'package:backend_debugger/dialogs/exception_alert_dialog.dart';
import 'package:backend_debugger/dialogs/future_loading_dialog.dart';
import 'package:backend_debugger/dialogs/simple_ignore_dialog.dart';
import 'package:backend_debugger/providers/sample_provider.dart';
import 'package:backend_debugger/routes/samples/server_connection_route.dart';
import 'package:backend_debugger/routes/samples/upload_route.dart';
import 'package:backend_debugger/tools/assets.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class SamplesRoute extends StatelessWidget {
  const SamplesRoute({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the authentication provider
    final provider = context.watch<SampleProvider>();

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
                    : UploadRoute(
                        () => (provider.service = null),
                        (asset, uuid, sample, disease, stage, results) =>
                            showDialog(
                          context: context,
                          builder: (context) => FutureLoadingDialog(
                            future: () async {
                              return provider.uploadImageSample(
                                  uuid,
                                  sample,
                                  disease,
                                  stage,
                                  results,
                                  DateTime.now(),
                                  (await AssetsTool().loadBytes(asset))
                                      .asByteData(),
                                  500,
                                  "image/jpeg");
                            }(),
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
                      ),
          )),
    );
  }
}
