import 'package:backend_debugger/application.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

void main() async {
  // Register logger instance
  GetIt.I.registerSingleton(Logger(
    level: kDebugMode ? Level.all : Level.info,
  ));

  // Register the global timeout
  GetIt.I.registerSingleton(
    const Duration(minutes: 1),
    instanceName: 'timeout',
  );

  // Wait for all instances to finish
  await GetIt.I.allReady();

  try {
    // Run the application
    runApp(const Application());
    GetIt.I.get<Logger>().d("Application started successfully");
  } on Exception catch (e) {
    // Catch unhandled exception
    GetIt.I.get<Logger>().f("(Uncaught exception) $e");
    runApp(ExceptionApplication(e));
  } on Error catch (e) {
    // Catch errors
    GetIt.I.get<Logger>().f("(Error ocurred) $e");
    runApp(ErrorApplication(e));
  }
}
