import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rentem/app/Modules/Login/provider/login_provider.dart';

import '../../Utils/font_styles.dart';

class LoginView extends ConsumerWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginNotifier = ref.read(loginProvider);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Hey!\nLogin Now",
                    textAlign: TextAlign.left,
                    style: FontStyles.heading.copyWith(
                      color: Colors.black,
                      fontSize: 45,
                    ),
                  ),
                ),
                SizedBox(height: 60),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 6,
                    shadowColor: Colors.black54,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.1,
                    ),
                  ),
                  onPressed: () async {
                    await loginNotifier.signIn();
                    if (loginNotifier.user != null) {
                      context.go('/dashboard'); // ✅ only go if login succeeded
                    }
                  },
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/google_logo.png',
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 8),
                      Text("Login with Google", style: FontStyles.body),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // ElevatedButton(
                //   onPressed: () {
                //     context.go('/dashboard');
                //   },
                //   child: const Text('Login'),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
