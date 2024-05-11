import 'dart:convert';

import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:backend_debugger/dialogs/simple_ignore_dialog.dart';
import 'package:backend_debugger/proto/model.pb.dart';
import 'package:backend_debugger/providers/auth_provider.dart';
import 'package:backend_debugger/tools/grpc.dart';
import 'package:backend_debugger/widgets/date_picker_widget.dart';
import 'package:crypto/crypto.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:unixtime/unixtime.dart';
import 'package:uuid/uuid.dart';
import 'package:fpdart/fpdart.dart' as fp;

class StoreDiagnosisRoute extends StatefulWidget {
  /// Cancel the operation
  final Function() onCancel;

  /// Called for uploading the diagnosis
  final void Function(Diagnosis) onStoreDiagnosis;

  const StoreDiagnosisRoute({
    required this.onCancel,
    required this.onStoreDiagnosis,
    super.key,
  });

  @override
  State<StoreDiagnosisRoute> createState() => _StoreDiagnosisRouteState();
}

class _StoreDiagnosisRouteState extends State<StoreDiagnosisRoute> {
  /// Text controller for the diagnosis UUID
  final diagnosisTextController = TextEditingController();

  /// Text controller for the sample
  final sampleTextController = TextEditingController()..text = "0";

  /// Text controller for the disease ID
  final diseaseTextController = TextEditingController()..text = "mock.dots";

  /// Text controller for the hash controller
  final patientHashTextController = TextEditingController();

  /// Text controller for the specialist remarks
  final remarksTextController = TextEditingController();

  /// Selected current datetime
  DateTime currentDateTime = DateTime.now();

  bool specialistResult = false;
  final specialistResultsTextController = TextEditingController();

  bool modelResult = false;
  final modelResultsTextController = TextEditingController();

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.edit_document,
                  size: 64.0,
                ),
                const Text("Enter diagnosis metadata"),

                // Diagnosis UUID
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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

                // Samples and Disease
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: TextField(
                          controller: sampleTextController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Number of samples",
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

                // Patient data
                TextField(
                  maxLines: null,
                  controller: patientHashTextController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text("Patient data (Pre hashing)"),
                  ),
                ),

                // Remarks
                TextField(
                  maxLines: null,
                  controller: remarksTextController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text("Remarks"),
                  ),
                ),

                // Specialist results
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        "Specialist results and (Positive/Negative) switch",
                        textAlign: TextAlign.start,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: TextField(
                              controller: specialistResultsTextController,
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "Specialist results - JSON",
                                  hintText: "{ \"mock.dots:dot\": 25 }")),
                        ),
                        Switch(
                            value: specialistResult,
                            onChanged: (value) => setState(() {
                                  specialistResult = value;
                                })),
                      ].separatedBy(const SizedBox(
                        width: 12.0,
                      )),
                    ),
                  ],
                ),

                // Model results
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        "Model results and (Positive/Negative) switch",
                        textAlign: TextAlign.start,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: TextField(
                              controller: modelResultsTextController,
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "Model results - JSON",
                                  hintText: "{ \"mock.dots:dot\": 25 }")),
                        ),
                        Switch(
                            value: modelResult,
                            onChanged: (value) => setState(() {
                                  modelResult = value;
                                })),
                      ].separatedBy(const SizedBox(
                        width: 12.0,
                      )),
                    ),
                  ],
                ),

                // Current DateTime
                DatePickerWidget(
                  onPick: (dt) => setState(() {
                    currentDateTime = dt;
                  }),
                ),

                // List of buttons
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
                            if (diseaseTextController.text.isEmpty) {
                              throw Exception("Disease cannot be emtpy");
                            } else if (!Uuid.isValidUUID(
                              fromString: diagnosisTextController.value.text,
                            )) {
                              throw Exception("Invalid UUID");
                            }

                            // Get the specialist
                            final specialist = switch (
                                context.read<AuthProvider>().specialist) {
                              fp.Left(value: final l) => throw l,
                              fp.Right(value: final r) => r,
                            };

                            // Get the patient hash
                            final patient = sha256
                                .convert(
                                  utf8.encode(
                                    patientHashTextController.value.text,
                                  ),
                                )
                                .toString();

                            // Get the results
                            final parsedModelResults = (jsonDecode(
                                        specialistResultsTextController.text)
                                    as Map<String, dynamic>)
                                .mapValue(
                              (value) => value as int,
                            );

                            final parsedSpecialistResults = (jsonDecode(
                                        specialistResultsTextController.text)
                                    as Map<String, dynamic>)
                                .mapValue(
                              (value) => value as int,
                            );

                            widget.onStoreDiagnosis(
                              Diagnosis(
                                id: diagnosisTextController.value.text,
                                disease: diseaseTextController.value.text,
                                date: Int64(currentDateTime.unixtime),
                                patientHash: patient,
                                remarks: remarksTextController.text.isEmpty
                                    ? null
                                    : remarksTextController.text,
                                samples: sampleTextController.text.toInt(),
                                specialist: specialist.toRecord(),
                                results: Diagnosis_Results(
                                  modelResult: modelResult,
                                  specialistResult: specialistResult,
                                  modelElements: parsedModelResults,
                                  specialistElements: parsedSpecialistResults,
                                ),
                              ),
                            );
                          } catch (e, s) {
                            GetIt.I.get<Logger>().e(
                                "Failed to upload diagnosis",
                                error: e,
                                stackTrace: s);

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
              ].separatedBy(
                const SizedBox(height: 16.0),
              ),
            ),
          ),
        ),
      );
}
