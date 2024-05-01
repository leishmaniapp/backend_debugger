import 'package:backend_debugger/dialogs/exception_alert_dialog.dart';
import 'package:backend_debugger/dialogs/future_loading_dialog.dart';
import 'package:backend_debugger/dialogs/simple_ignore_dialog.dart';
import 'package:backend_debugger/exception/exception.dart';
import 'package:backend_debugger/providers/diagnoses_provider.dart';
import 'package:backend_debugger/providers/route_provider.dart';
import 'package:backend_debugger/routes/diagnoses/get_diagnosis_route.dart';
import 'package:backend_debugger/routes/diagnoses/store_diagnosis_route.dart';
import 'package:backend_debugger/routes/generic_menu_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screwdriver/screwdriver.dart';

class DiagnosesRoute extends StatelessWidget {
  final DiagnosesProvider provider;

  const DiagnosesRoute({
    required this.provider,
    super.key,
  });

  @override
  Widget build(BuildContext context) => GenericMenuRoute(
        onExit: () => provider.disconnect(),
        onNext: context.read<RouteProvider>().goNextRoute,
        destinations: [
          MenuRouteDestination(
            icon: Icons.upload_file_rounded,
            title: "StoreDiagnosis",
            subtitle: "Store a new diagnosis with UUID and results",
            builder: (onExit) => StoreDiagnosisRoute(
              onCancel: onExit,
              onStoreDiagnosis: (diagnosis) => provider
                  .storeDiagnosis(
                diagnosis,
              )
                  .apply((future) {
                // Show the dialog
                showDialog(
                  context: context,
                  builder: (context) => FutureLoadingDialog(
                    // Call the sample storage service
                    future: future,
                    builder: (context, value) => value.data!.match(
                      () => SimpleIgnoreDialog(
                        const Text("Successfully uploaded sample"),
                        Text(
                          "Diagnosis (${diagnosis.id}) successfully uploaded",
                        ),
                      ),
                      (e) => ExceptionAlertDialog(e),
                    ),
                  ),
                );
              }),
            ),
          ),
          MenuRouteDestination(
            icon: Icons.download_rounded,
            title: "GetDiagnosis",
            subtitle: "Get the diagnosis results for a given UUID",
            builder: (onExit) => GetDiagnosisRoute(
                onCancel: onExit,
                onGetDiagnosis: (uuid) =>
                    provider.getDiagnosis(uuid).apply((future) {
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
                                "Diagnosis `$uuid` successfully downloaded",
                              ),
                            ),
                          ),
                        ),
                      );
                    }).then(
                      // Return the value or null
                      (value) => value.getRight().toNullable(),
                    )),
          )
        ],
      );
}
