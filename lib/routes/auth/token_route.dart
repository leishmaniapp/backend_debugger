import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:backend_debugger/proto/auth.pb.dart';
import 'package:backend_debugger/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

class AuthTokenRoute extends StatelessWidget {
  final TokenString token;
  final Either<Exception, TokenPayload> payload;
  final Function() onCancelAuth;
  final Function() onContinue;
  final Function() onVerifyToken;
  final Function() onInvalidateToken;

  const AuthTokenRoute({
    required this.token,
    required this.payload,
    required this.onCancelAuth,
    required this.onContinue,
    required this.onVerifyToken,
    required this.onInvalidateToken,
    super.key,
  });

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.verified_user,
                size: 64.0,
              ),
              Text(
                "Successfully authenticated",
                style: context.textStyles.headlineMedium,
              ),
              const Text("Raw authentication token"),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.0),
                  border: Border.all(
                    color: context.colors.scheme.primary,
                  ),
                ),
                child: SelectableText(token),
              ),
              const Text("Token Information"),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: payload.isLeft()
                      ? context.colors.scheme.errorContainer
                      : context.colors.scheme.background,
                  borderRadius: BorderRadius.circular(6.0),
                  border: Border.all(
                    color: payload.isLeft()
                        ? context.colors.scheme.error
                        : context.colors.scheme.primary,
                  ),
                ),
                child: SelectableText(
                  payload.match(
                      (l) => l.toString(), (r) => r.toProto3Json().toString()),
                ),
              ),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12.0,
                runSpacing: 12.0,
                children: [
                  OutlinedButton.icon(
                      onPressed: onCancelAuth,
                      icon: const Icon(
                          Icons.sentiment_very_dissatisfied_outlined),
                      label: const Text("Forget Token")),
                  FilledButton.tonalIcon(
                    onPressed: onInvalidateToken,
                    icon: const Icon(Icons.disabled_by_default_rounded),
                    label: const Text("Invalidate Session"),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: onVerifyToken,
                    icon: const Icon(Icons.verified_rounded),
                    label: const Text("Verify token"),
                  ),
                  FilledButton.icon(
                      onPressed: onContinue,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text("Continue")),
                ],
              ),
            ].separatedBy(const SizedBox(height: 16)),
          ),
        ),
      );
}
