import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:translate_app/presentation/viewmodels/auth_viewmodel.dart';
import 'package:translate_app/presentation/widgets/app_background.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Periodically check if email is verified
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      context.read<AuthViewModel>().reloadUser();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    const Color ip = Colors.white;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.mark_email_unread_rounded,
                  size: 80,
                  color: Colors.blueAccent,
                ),
                const SizedBox(height: 32),
                const Text(
                  'Verify Your Email',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: ip,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'A verification link has been sent to ${authViewModel.user?.email}.\nPlease check your inbox and verify to continue.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ip.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () => authViewModel.sendEmailVerification(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Colors.white24),
                    ),
                  ),
                  child: const Text('Resend Email'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => authViewModel.signOut(),
                  child: const Text(
                    'Cancel & Sign Out',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
