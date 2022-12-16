import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/commons/loader.dart';
import 'package:reddit/core/commons/sign_in_button.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/responsive/responsive.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authControllerProvider);
    void signInGuest(WidgetRef ref, BuildContext context) {
      ref.read(authControllerProvider.notifier).signInAsGuest(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          Constants.logoPath,
          height: 40,
        ),
        actions: [
          TextButton(
            onPressed: () => signInGuest(ref, context),
            child: const Text(
              "Skip",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Loader()
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  const Text(
                    "Dive into anything",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      Constants.loginEmotePath,
                      height: 400,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Responsive(child: SignInButton()),
                ],
              ),
            ),
    );
  }
}
