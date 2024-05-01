import 'dart:convert';

import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:backend_debugger/dialogs/simple_ignore_dialog.dart';
import 'package:backend_debugger/proto/model.pb.dart';
import 'package:backend_debugger/proto/types.pb.dart';
import 'package:backend_debugger/providers/auth_provider.dart';
import 'package:backend_debugger/tools/assets.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:unixtime/unixtime.dart';
import 'package:uuid/uuid.dart';

class StoreImageSampleRoute extends StatelessWidget {
  /// Cancel the operation
  final Function() onCancel;

  /// Called for uploading the sample
  final void Function(String, Sample) onStoreImageSample;

  const StoreImageSampleRoute({
    required this.onCancel,
    required this.onStoreImageSample,
    super.key,
  });

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
              const Text("Enter sample metadata"),
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
                      onPressed: onCancel,
                      icon: const Icon(Icons.home_repair_service_rounded),
                      label: const Text("Back to services")),
                  FilledButton.icon(
                      onPressed: () {
                        try {
                          // Parse stage and UUID
                          if (analysisStage == null) {
                            throw Exception(
                                "AnalysisStage has not been selected");
                          } else if (selectedAsset == null) {
                            throw Exception("Asset has not been selected");
                          } else if (!Uuid.isValidUUID(
                              fromString: textUuidController.value.text)) {
                            throw Exception("Invalid UUID");
                          }

                          // Get the specialist
                          final specialist =
                              switch (context.read<AuthProvider>().specialist) {
                            Left(value: final l) => throw l,
                            Right(value: final r) => r,
                          };

                          // Get the results json
                          final results = resultsTextController.value.text;

                          // Store the image sample
                          onStoreImageSample.call(
                            selectedAsset!,
                            Sample(
                                specialist: Specialist_Record(
                                  email: specialist.email,
                                  name: specialist.name,
                                ),
                                metadata: ImageMetadata(
                                  diagnosis: textUuidController.value.text,
                                  sample: int.parse(
                                      sampleTextController.value.text),
                                  disease: diseaseTextController.value.text,
                                  date: Int64(DateTime.now().unixtime),
                                ),
                                stage: analysisStage!,
                                results: results.isEmpty
                                    ? <String, ListOfCoordinates>{}
                                    : (jsonDecode(results)
                                            as Map<String, dynamic>)
                                        .mapValue(
                                        (value) => ListOfCoordinates(
                                          coordinates: (value["coordintes"]
                                                  as List<dynamic>)
                                              .map<Coordinates>(
                                            (e) => Coordinates.create()
                                              ..mergeFromProto3Json(e),
                                          ),
                                        ),
                                      )),
                          );
                        } catch (e, s) {
                          GetIt.I.get<Logger>().e("Failed to upload sample",
                              error: e, stackTrace: s);

                          showDialog(
                            context: context,
                            builder: (context) => SimpleIgnoreDialog(
                                const Text("Error parsing options"),
                                Text("$e")),
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
