import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:backend_debugger/dialogs/simple_ignore_dialog.dart';
import 'package:backend_debugger/proto/model.pb.dart';
import 'package:flutter/material.dart';

class GetUndeliveredRoute extends StatefulWidget {
  final Function() onCancelConnection;

  final Future<List<Sample>?>? Function(String email) onGetSample;

  const GetUndeliveredRoute(
    this.onCancelConnection,
    this.onGetSample, {
    super.key,
  });

  @override
  State<GetUndeliveredRoute> createState() => _GetUndeliveredRouteState();
}

class _GetUndeliveredRouteState extends State<GetUndeliveredRoute> {
  // Stored result
  Future<Object?>? result;

  @override
  Widget build(BuildContext context) {
    // Get UUID controller
    final textEmailController = TextEditingController();

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
                Icons.delivery_dining_rounded,
                size: 64.0,
              ),
              const Text("Enter specialist email"),
              TextField(
                controller: textEmailController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Specialist email",
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
                      onPressed: widget.onCancelConnection,
                      icon: const Icon(Icons.home_repair_service_rounded),
                      label: const Text("Back to services")),
                  FilledButton.icon(
                      onPressed: () {
                        try {
                          // Call getSample and store the result
                          setState(() {
                            result = widget.onGetSample.call(
                              textEmailController.value.text,
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
