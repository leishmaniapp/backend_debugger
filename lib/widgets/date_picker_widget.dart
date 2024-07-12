import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:flutter/material.dart';
import 'package:unixtime/unixtime.dart';

/// Show a complex [DateTime] picker for unixtime
class DatePickerWidget extends StatefulWidget {
  /// Called when a new [DateTime] is picked
  final void Function(DateTime dt) onPick;

  const DatePickerWidget({
    required this.onPick,
    super.key,
  });

  @override
  State<DatePickerWidget> createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  /// Currently selected datetime
  DateTime currentDateTime = DateTime.now();

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Text(
                "Current selected date",
                style: context.textStyles.bodyLarge,
              ),
              Text(
                "${currentDateTime.year}/${currentDateTime.month}/${currentDateTime.day}"
                " (${currentDateTime.hour}:${currentDateTime.minute}:${currentDateTime.second})"
                " @ ${currentDateTime.unixtime} UnixTime",
              ),
              const SizedBox(height: 12.0),
              Row(
                children: [
                  Expanded(
                      flex: 2,
                      child: OutlinedButton(
                        onPressed: () => showDatePicker(
                          context: context,
                          initialDate: currentDateTime,
                          firstDate: currentDateTime.subtract(
                            const Duration(days: 365),
                          ),
                          lastDate: currentDateTime.add(
                            const Duration(days: 365),
                          ),
                        ).then((datetime) {
                          if (datetime != null) {
                            // Replace current datetime with provided one
                            setState(
                              () {
                                currentDateTime = DateTime.now();
                                widget.onPick(currentDateTime);
                              },
                            );
                          }
                        }),
                        child: const Text("Pick Date"),
                      )),
                  Expanded(
                    flex: 2,
                    child: OutlinedButton(
                      onPressed: () => showTimePicker(
                              context: context,
                              initialTime:
                                  TimeOfDay.fromDateTime(currentDateTime))
                          .then((time) {
                        if (time != null) {
                          // Copy current datetime with current time
                          setState(
                            () {
                              currentDateTime = currentDateTime.copyWith(
                                  minute: time.minute, hour: time.hour);

                              widget.onPick(currentDateTime);
                            },
                          );
                        }
                      }),
                      child: const Text("Pick Time"),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: FilledButton(
                      onPressed: () => setState(() {
                        currentDateTime = DateTime.now();
                        widget.onPick(currentDateTime);
                      }),
                      child: const Icon(Icons.timer),
                    ),
                  ),
                ].separatedBy(const SizedBox(width: 8.0)),
              )
            ],
          ),
        ),
      );
}
