import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:backend_debugger/dialogs/simple_ignore_dialog.dart';
import 'package:backend_debugger/proto/model.pb.dart';
import 'package:backend_debugger/proto/types.pb.dart';
import 'package:backend_debugger/providers/auth_provider.dart';
import 'package:backend_debugger/tools/grpc.dart';
import 'package:backend_debugger/tools/parsing.dart';
import 'package:backend_debugger/widgets/date_picker_widget.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' as fp;
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:unixtime/unixtime.dart';
import 'package:uuid/uuid.dart';

class UpdateSampleRoute extends StatefulWidget {
  /// Cancel the operation
  final Function() onCancel;

  /// Called for uploading the changes
  final void Function(Sample) onUpdateSample;

  const UpdateSampleRoute({
    required this.onCancel,
    required this.onUpdateSample,
    super.key,
  });

  @override
  State<UpdateSampleRoute> createState() => _UpdateSampleRouteState();
}

class _UpdateSampleRouteState extends State<UpdateSampleRoute> {
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
                DatePickerWidget(
                  onPick: (dt) => setState(
                    () {
                      currentDateTime = dt;
                    },
                  ),
                ),
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
                            if (analysisStage == null) {
                              throw Exception(
                                  "AnalysisStage has not been selected");
                            } else if (!Uuid.isValidUUID(
                                fromString:
                                    diagnosisTextController.value.text)) {
                              throw Exception("Invalid UUID");
                            }

                            // Get the specialist
                            final specialist = switch (
                                context.read<AuthProvider>().specialist) {
                              fp.Left(value: final l) => throw l,
                              fp.Right(value: final r) => r,
                            };

                            // Get the results json
                            final results = resultsTextController.value.text;

                            // Store the image sample
                            widget.onUpdateSample.call(
                              Sample(
                                  specialist: specialist.toRecord(),
                                  metadata: ImageMetadata(
                                    diagnosis:
                                        diagnosisTextController.value.text,
                                    sample: int.parse(
                                        sampleTextController.value.text),
                                    disease: diseaseTextController.value.text,
                                    date: Int64(DateTime.now().unixtime),
                                  ),
                                  stage: analysisStage!,
                                  results: results.isEmpty
                                      ? <String, ListOfCoordinates>{}
                                      : parseSampleResults(results)),
                            );
                          } catch (e, s) {
                            GetIt.I.get<Logger>().e("Failed to upload sample",
                                error: e, stackTrace: s);

                            showDialog(
                              context: context,
                              builder: (context) => SimpleIgnoreDialog(
                                  const Text("Error parsing options"),
                                  Text(e.toString())),
                            );
                          }
                        },
                        icon: const Icon(Icons.update),
                        label: const Text("Update")),
                  ],
                ),
              ].separatedBy(const SizedBox(height: 16.0)),
            ),
          ),
        ),
      );
}
