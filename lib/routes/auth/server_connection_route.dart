import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:backend_debugger/dialogs/exception_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

class AuthServerConnectionRoute extends StatelessWidget {
  /// When the server URI is provided
  final Function(Uri server) onServerProvided;
  const AuthServerConnectionRoute(this.onServerProvided, {super.key});

  @override
  Widget build(BuildContext context) {
    // Controller for the 'Server URI' field
    final TextEditingController textController = TextEditingController();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.power_rounded,
          size: 64.0,
        ),
        Text(
          "Connect to the authentication server",
          style: context.textStyles.bodyLarge,
        ),
        TextField(
          controller: textController,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            label: Text("Server connection URI"),
            hintText: "rpc://127.0.0.1:8080",
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: FilledButton.icon(
            label: const Text("Connect"),
            icon: const Icon(Icons.electrical_services_rounded),
            onPressed: () {
              try {
                // Parse the Server URI and send it
                onServerProvided(Uri.parse(textController.value.text));
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
            },
          ),
        ),
      ].separatedBy(const SizedBox(height: 10.0)),
    );
  }
}
