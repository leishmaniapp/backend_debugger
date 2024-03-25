import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:backend_debugger/application.dart';
import 'package:backend_debugger/services/implementation/http_auth_service.dart';
import 'package:backend_debugger/services/interfaces/auth_service.dart';

void main() {
  // Create the logger and register it
  GetIt.I.registerSingleton<Logger>(Logger(
    printer: PrettyPrinter(),
    level: Level.all,
  ));

  // Register services
  GetIt.I.registerSingleton<IAuthService>(HttpAuthService());

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
