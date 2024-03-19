import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:ws_debugger/provider/auth_provider.dart';
import 'package:ws_debugger/services/interfaces/auth_service.dart';
import 'package:ws_debugger/views/main_view.dart';

/// Main application widget
class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          // Authentication provider
          ChangeNotifierProvider<AuthProvider>(
            create: (context) => AuthProvider(
              GetIt.I.get<IAuthService>(),
            ),
          )
        ],
        builder: (context, child) => const MaterialApp(
          home: MainView(),
        ),
      );
}

/// Uncaught exception application
class ExceptionApplication extends StatelessWidget {
  final Exception exception;
  const ExceptionApplication(this.exception, {super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          backgroundColor: context.colors.scheme.errorContainer,
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error,
                    color: context.colors.scheme.error,
                    size: 60.0,
                  ),
                  Text(
                    "Unhandled exception during execution",
                    style: context.textStyles.displaySmall.copyWith(
                        color: context.colors.scheme.onErrorContainer),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "An exception of type (${exception.runtimeType})[${exception.runtimeType.hashCode}] reached top level function 'main' without being caught",
                    style: context.textStyles.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 16.0,
                    ),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: context.colors.scheme.error,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Text(
                      exception.toString(),
                      style: context.textStyles.bodyMedium.copyWith(
                        color: context.colors.scheme.onError,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

/// Uncaught error application
class ErrorApplication extends StatelessWidget {
  final Error error;
  const ErrorApplication(this.error, {super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          backgroundColor: context.colors.scheme.errorContainer,
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.signpost_rounded,
                    color: context.colors.scheme.error,
                    size: 60.0,
                  ),
                  Text(
                    "An Error was raised during execution",
                    style: context.textStyles.displaySmall.copyWith(
                        color: context.colors.scheme.onErrorContainer),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "An error of type (${error.runtimeType})[${error.runtimeType.hashCode}] was issued",
                    style: context.textStyles.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 16.0,
                    ),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: context.colors.scheme.error,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Text(
                      error.stackTrace?.toString() ??
                          "No additional information was provided",
                      style: context.textStyles.bodyMedium.copyWith(
                        color: context.colors.scheme.onError,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
