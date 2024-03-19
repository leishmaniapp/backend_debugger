import 'package:flutter/material.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:provider/provider.dart';
import 'package:ws_debugger/provider/auth_provider.dart';
import 'package:ws_debugger/widgets/blockquote.dart';
import 'package:fpdart/fpdart.dart' as fn;

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  /// Authentication
  final textUrlController = TextEditingController();
  final textUserController = TextEditingController();
  final textPassController = TextEditingController();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text("Authentication"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Auth service URL
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Authentication server responsible for emitting the user token",
                  ),
                  TextField(
                    keyboardType: TextInputType.url,
                    controller: textUrlController,
                    decoration: const InputDecoration(
                      hintText: "Authentication service URL",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              // Credentials
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Specialist authentication credentials",
                  ),
                  Row(
                    children: [
                      // Username
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.text,
                          controller: textUserController,
                          decoration: const InputDecoration(
                            hintText: "Username",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      // Password
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.text,
                          obscureText: true,
                          controller: textPassController,
                          decoration: const InputDecoration(
                            hintText: "Password",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ].separatedBy(const SizedBox(width: 6)),
                  ),
                ],
              ),

              // Show authentication schema
              Blockquote(
                  title: "Current authentication schema",
                  text: context.read<AuthProvider>().authSchema),

              // Action buttons
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton(
                      onPressed: () {
                        // Check if fields are empty
                        if (!(textUrlController.value.text.isNotEmpty &&
                            textUserController.value.text.isNotEmpty &&
                            textPassController.value.text.isNotEmpty)) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Missing fields"),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                      "Some of the fields are empty, check and try again"),
                                  FilledButton(
                                    onPressed: () => context.navigator.pop(),
                                    child: const Text("Ok"),
                                  )
                                ].separatedBy(const SizedBox(height: 8.0)),
                              ),
                            ),
                          );

                          return;
                        }

                        // Authenticate with remote server
                        final authFuture = context.read<AuthProvider>().login(
                            Uri.parse(textUrlController.value.text),
                            textUserController.value.text,
                            textPassController.value.text);

                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title:
                                const Text("Authenticating with remote server"),
                            content: FutureBuilder(
                              future: authFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  // Content was returned
                                  if (snapshot.hasData) {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        switch (snapshot.data!) {
                                          fn.Some(value: final err) => Text(
                                              err.toString(),
                                            ),
                                          fn.None() =>
                                            const Text("Authentication success")
                                        },
                                        FilledButton(
                                          onPressed: () =>
                                              context.navigator.pop(),
                                          child: const Text("Ok"),
                                        )
                                      ].separatedBy(
                                          const SizedBox(height: 8.0)),
                                    );
                                  } else {
                                    return Text(snapshot.error.toString());
                                  }
                                } else {
                                  // Still connecting
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Connecting to remote server (${Uri.parse(textUrlController.value.text)})\n"
                                        "with credentials for user '${textUserController.value.text}'",
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: LinearProgressIndicator(),
                                      ),
                                    ],
                                  );
                                }
                              },
                            ),
                          ),
                        );
                      },
                      child: const Text("Acquire token (Login)"),
                    ),
                    FilledButton.tonal(
                      onPressed: (context.read<AuthProvider>().authenticated)
                          ? () {
                              // Dismiss tokens
                              context.read<AuthProvider>().logout();
                            }
                          : null,
                      child: const Text("Dismiss token (Logout)"),
                    ),
                  ].separatedBy(const SizedBox(width: 4.0)),
                ),
              ),

              // Token
              Blockquote(
                title: "Authentication Token",
                text:
                    context.watch<AuthProvider>().token ?? "Not authenticated",
              ),

              // Token contents
              Blockquote(
                title: "Token contents",
                text: context.watch<AuthProvider>().authenticated
                    ? JWT
                        .decode(context.watch<AuthProvider>().token!)
                        .toString()
                    : "Here the token contents will be displayed",
              ),
            ].separatedBy(const SizedBox(height: 8)),
          ),
        ),
      );
}
