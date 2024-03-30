import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:flutter/material.dart';

/// Ask for authentication credentials
class AuthCredentialsView extends StatelessWidget {
  final Function() onCancelConnection;
  final Function(String email, String password) onAuthenticate;

  const AuthCredentialsView({
    required this.onCancelConnection,
    required this.onAuthenticate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Text controllers
    final emailTextController = TextEditingController();
    final passwordTextController = TextEditingController();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Enter authentication credentials",
          style: context.textStyles.bodyLarge,
        ),
        TextField(
          keyboardType: TextInputType.emailAddress,
          controller: emailTextController,
          decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Email",
              hintText: "someone@emailserver.com"),
        ),
        TextField(
          obscureText: true,
          keyboardType: TextInputType.none,
          controller: passwordTextController,
          decoration: const InputDecoration(
              border: OutlineInputBorder(), labelText: "Password"),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton.icon(
                onPressed: onCancelConnection,
                icon: const Icon(Icons.block_rounded),
                label: const Text("Cancel connection")),
            FilledButton.icon(
                onPressed: () => onAuthenticate(
                      emailTextController.value.text,
                      passwordTextController.value.text,
                    ),
                icon: const Icon(Icons.verified_user_rounded),
                label: const Text("Authenticate")),
          ],
        )
      ].separatedBy(const SizedBox(height: 16)),
    );
  }
}
