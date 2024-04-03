import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:backend_debugger/dialogs/simple_ignore_dialog.dart';
import 'package:backend_debugger/proto/model.pb.dart';
import 'package:backend_debugger/tools/assets.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class UploadRoute extends StatelessWidget {
  final Function() onCancelConnection;

  final Function(String asset, String uuid, int sample, String disease,
      AnalysisStage stage, String results) onUploadSample;

  const UploadRoute(this.onCancelConnection, this.onUploadSample, {super.key});

  @override
  Widget build(BuildContext context) {
    // Get UUID controller
    final textUuidController = TextEditingController();
    final sampleTextController = TextEditingController()..text = "0";
    final diseaseTextController = TextEditingController()..text = "mock.dots";
    final resultsTextController = TextEditingController();

    AnalysisStage? analysisStage = AnalysisStage.ANALYZED;
    String? selectedAsset;

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
                Icons.image,
                size: 64.0,
              ),
              const Text("Enter sample storage metadata"),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownMenu<AnalysisStage>(
                    onSelected: (value) => (analysisStage = value),
                    label: const Text("Analysis Stage"),
                    initialSelection: AnalysisStage.ANALYZED,
                    dropdownMenuEntries: AnalysisStage.values
                        .map((e) => DropdownMenuEntry(
                              value: e,
                              label: e.name.toLowerCase().capitalizeFirst(),
                            ))
                        .toList(),
                  ),
                  Expanded(
                    child: TextField(
                      controller: textUuidController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Diagnosis UUID",
                      ),
                    ),
                  ),
                  FloatingActionButton(
                    backgroundColor: context.colors.scheme.primaryContainer,
                    onPressed: () =>
                        (textUuidController.text = const Uuid().v4()),
                    child: const Icon(Icons.playlist_add_rounded),
                  )
                ].separatedBy(const SizedBox(width: 16.0)),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: TextField(
                        controller: sampleTextController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Sample Number",
                        )),
                  ),
                  Expanded(
                    child: TextField(
                      controller: diseaseTextController,
                      keyboardType: TextInputType.url,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Disease",
                        hintText: "mock.dots",
                      ),
                    ),
                  ),
                ].separatedBy(const SizedBox(width: 16.0)),
              ),
              TextField(
                maxLines: null,
                controller: resultsTextController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text("Results - JSON"),
                ),
              ),
              Card(
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    // Build the asset preview as Stateful
                    child: StatefulBuilder(
                      builder: (context, setState) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("Select the asset to upload"),
                          FutureBuilder(
                            future: AssetsTool().assetsExtension(".jpg"),
                            builder: (context, snapshot) =>
                                snapshot.connectionState == ConnectionState.done
                                    ? Wrap(
                                        children: snapshot.data!
                                            .map((e) => OutlinedButton(
                                                  onPressed: () => setState(
                                                      () => selectedAsset = e),
                                                  child: Text(e),
                                                ))
                                            .toList())
                                    : const LinearProgressIndicator(),
                          ),
                          const Divider(),
                          const Text("Asset preview"),
                          if (selectedAsset != null) Image.asset(selectedAsset!)
                        ].separatedBy(const SizedBox(height: 8.0)),
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                      onPressed: onCancelConnection,
                      icon: const Icon(Icons.home_repair_service_rounded),
                      label: const Text("Back to services")),
                  FilledButton.icon(
                      onPressed: () {
                        try {
                          if (analysisStage == null) {
                            throw Exception(
                                "AnalysisStage has not been selected");
                          } else if (selectedAsset == null) {
                            throw Exception("Asset has not been selected");
                          } else if (!Uuid.isValidUUID(
                              fromString: textUuidController.value.text)) {
                            throw Exception("Invalid UUID");
                          }
                          onUploadSample.call(
                              selectedAsset!,
                              textUuidController.value.text,
                              int.parse(sampleTextController.value.text),
                              diseaseTextController.value.text,
                              analysisStage!,
                              resultsTextController.value.text);
                        } catch (e) {
                          showDialog(
                            context: context,
                            builder: (context) => SimpleIgnoreDialog(
                                const Text("Error parsing options"),
                                Text(e.toString())),
                          );
                        }
                      },
                      icon: const Icon(Icons.cloud_upload_rounded),
                      label: const Text("Upload")),
                ],
              ),
            ].separatedBy(const SizedBox(height: 16.0)),
          ),
        ),
      ),
    );
  }
}
