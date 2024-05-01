import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:backend_debugger/dialogs/simple_ignore_dialog.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class GetDiagnosisRoute extends StatefulWidget {
  /// Called when the operation is cancelled
  final Function() onCancel;

  /// Called for sample requests
  final Future<Object?>? Function(String uuid) onGetDiagnosis;

  const GetDiagnosisRoute({
    required this.onCancel,
    required this.onGetDiagnosis,
    super.key,
  });

  @override
  State<GetDiagnosisRoute> createState() => _GetOrDeleteSampleRouteState();
}

class _GetOrDeleteSampleRouteState extends State<GetDiagnosisRoute> {
  // Stored result
  Future<Object?>? result;

  @override
  Widget build(BuildContext context) {
    // Get UUID controller
    final textUuidController = TextEditingController();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 24.0,
          horizontal: 2.0,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.description,
                size: 64.0,
              ),
              const Text("Enter the diagnosis UUID"),
              TextField(
                controller: textUuidController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Diagnosis UUID",
                ),
              ),
              Card(
                  child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: (result == null)
                    ? const Text("Sample metadata will be shown here")
                    : FutureBuilder(
                        future: result!,
                        builder: (context, snapshot) =>
                            (snapshot.connectionState == ConnectionState.done)
                                ? (snapshot.data == null)
                                    ? const Text("Metadata failure")
                                    : Text(snapshot.data.toString())
                                : const LinearProgressIndicator(),
                      ),
              )),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                      onPressed: widget.onCancel,
                      icon: const Icon(Icons.home_repair_service_rounded),
                      label: const Text("Back to services")),
                  FilledButton.icon(
                      onPressed: () {
                        try {
                          if (!Uuid.isValidUUID(
                              fromString: textUuidController.value.text)) {
                            throw Exception("Invalid UUID");
                          }

                          // Call getSample and store the result
                          setState(() {
                            result = widget.onGetDiagnosis.call(
                              textUuidController.value.text,
                            );
                          });
                        } catch (e) {
                          showDialog(
                            context: context,
                            builder: (context) => SimpleIgnoreDialog(
                                const Text("Error parsing options"),
                                Text(e.toString())),
                          );
                        }
                      },
                      icon: const Icon(Icons.construction_outlined),
                      label: const Text("Request")),
                ],
              ),
            ].separatedBy(const SizedBox(height: 16.0)),
          ),
        ),
      ),
    );
  }
}
