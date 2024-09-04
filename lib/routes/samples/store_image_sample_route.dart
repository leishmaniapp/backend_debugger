import 'dart:convert';
import 'dart:io';

import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:backend_debugger/dialogs/simple_ignore_dialog.dart';
import 'package:backend_debugger/proto/model.pb.dart';
import 'package:backend_debugger/proto/types.pb.dart';
import 'package:backend_debugger/providers/auth_provider.dart';
import 'package:backend_debugger/tools/grpc.dart';
import 'package:backend_debugger/widgets/date_picker_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';
import 'package:unixtime/unixtime.dart';
import 'package:uuid/uuid.dart';
import 'package:fpdart/fpdart.dart' as fp;

class StoreImageSampleRoute extends StatefulWidget {
  /// Cancel the operation
  final Function() onCancel;

  /// Called for uploading the sample
  final void Function(ImageBytes, Sample) onStoreImageSample;

  const StoreImageSampleRoute({
    required this.onCancel,
    required this.onStoreImageSample,
    super.key,
  });

  @override
  State<StoreImageSampleRoute> createState() => _StoreImageSampleRouteState();
}

class _StoreImageSampleRouteState extends State<StoreImageSampleRoute> {
  /// Text controller for the diagnosis UUID
  final diagnosisTextController = TextEditingController();

  /// Text controller for the sample
  final sampleTextController = TextEditingController()..text = "0";

  /// Text controller for the disease ID
  final diseaseTextController = TextEditingController()..text = "mock.dots";

  /// Text controller for the results in JSON format
  final resultsTextController = TextEditingController();

  /// Currently selected analysis stage
  AnalysisStage? analysisStage = AnalysisStage.ANALYZED;

  /// Get the currently selected date time
  DateTime currentDateTime = DateTime.now();

  /// Image bytes grabbed from a [FilePicker]
  List<int>? imageBytes;

  /// Selected image MIME type
  String? imageMime;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.image,
                  size: 64.0,
                ),
                const Text("Enter sample metadata"),

                // Stage and UUID
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
                        controller: diagnosisTextController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Diagnosis UUID",
                        ),
                      ),
                    ),
                    FloatingActionButton(
                      backgroundColor: context.colors.scheme.primaryContainer,
                      onPressed: () =>
                          (diagnosisTextController.text = const Uuid().v4()),
                      child: const Icon(Icons.playlist_add_rounded),
                    )
                  ].separatedBy(const SizedBox(width: 16.0)),
                ),

                // Sample and Disease
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

                // Results
                TextField(
                  maxLines: null,
                  controller: resultsTextController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text("Results - JSON"),
                  ),
                ),

                // Image picker
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () async {
                        try {
                          // Get the selected file
                          final fileResult = await FilePicker.platform
                              .pickFiles(type: FileType.image);

                          // If no file was selected
                          if (fileResult == null) {
                            return;
                          }

                          // Read the file
                          final file = File(fileResult.files.single.path!);
                          GetIt.I
                              .get<Logger>()
                              .i("Selected file: ${file.path}");
                          // Read the bytes
                          file.readAsBytes().then(
                                (value) => setState(() {
                                  imageMime = lookupMimeType(file.path);
                                  imageBytes = value;
                                }),
                              );
                        } catch (e, s) {
                          GetIt.I.get<Logger>().e("Failed to pick image",
                              error: e, stackTrace: s);
                        }
                      },
                      icon: const Icon(Icons.image),
                      label: const Text("Pick a file"),
                    ),

                    // Image description text
                    (imageBytes == null
                        ? const Text("No file currently selected")
                        : Text(
                            "(${imageBytes?.length}) bytes loaded, file of type ($imageMime)",
                          )),
                  ].separatedBy(const SizedBox(
                    width: 12.0,
                  )),
                ),

                // Date time picker
                DatePickerWidget(
                  onPick: (dt) => setState(() {
                    currentDateTime = dt;
                  }),
                ),

                // Action buttons
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton.icon(
                        onPressed: widget.onCancel,
                        icon: const Icon(Icons.home_repair_service_rounded),
                        label: const Text("Back to services")),
                    FilledButton.icon(
                        onPressed: onUpload,
                        icon: const Icon(Icons.cloud_upload_rounded),
                        label: const Text("Upload")),
                  ],
                ),
              ].separatedBy(
                const SizedBox(height: 16.0),
              ),
            ),
          ),
        ),
      );

  /// Called for uploading the sample
  void onUpload() {
    try {
      // Parse stage and UUID
      if (analysisStage == null) {
        throw Exception("AnalysisStage has not been selected");
      } else if (imageBytes == null || imageMime == null) {
        throw Exception("Asset has not been selected");
      } else if (!Uuid.isValidUUID(
          fromString: diagnosisTextController.value.text)) {
        throw Exception("Invalid UUID");
      }

      // Get the specialist
      final specialist = switch (context.read<AuthProvider>().specialist) {
        fp.Left(value: final l) => throw l,
        fp.Right(value: final r) => r,
      };

      // Get the results json
      final results = resultsTextController.value.text;

      // Store the image sample
      widget.onStoreImageSample.call(
        ImageBytes(
          data: imageBytes,
          mime: imageMime,
        ),
        Sample(
            specialist: specialist.toRecord(),
            metadata: ImageMetadata(
              diagnosis: diagnosisTextController.value.text,
              sample: int.parse(sampleTextController.value.text),
              disease: diseaseTextController.value.text,
              date: Int64(currentDateTime.unixtime),
            ),
            stage: analysisStage!,
            results: results.isEmpty
                ? <String, ListOfCoordinates>{}
                : (jsonDecode(results) as Map<String, dynamic>).mapValue(
                    (value) => ListOfCoordinates(
                      coordinates: (value["coordintes"] as List<dynamic>)
                          .map<Coordinates>(
                        (e) => Coordinates.create()..mergeFromProto3Json(e),
                      ),
                    ),
                  )),
      );
    } catch (e, s) {
      GetIt.I
          .get<Logger>()
          .e("Failed to upload sample", error: e, stackTrace: s);

      showDialog(
        context: context,
        builder: (context) =>
            SimpleIgnoreDialog(const Text("Error parsing options"), Text("$e")),
      );
    }
  }
}
