import 'package:flutter/material.dart';

/// Ask for authentication credentials
class AuthCredentialsView extends StatelessWidget {
  const AuthCredentialsView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text("Credentials"),
        ),
      );
}
