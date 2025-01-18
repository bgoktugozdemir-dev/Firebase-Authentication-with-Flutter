import 'package:firebase_authentication_example/firebase_authentication_repository.dart';
import 'package:firebase_authentication_example/pages/link_account_page.dart';
import 'package:firebase_authentication_example/pages/login_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuthenticationRepository _firebaseAuthenticationRepository = FirebaseAuthenticationRepository.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: [
              if (_firebaseAuthenticationRepository.currentUser?.isAnonymous == true) ...[
                Text(
                  'Welcome to the home page',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const Spacer(),
                Text(
                  'You are an anonymous user.\nPlease, link your account.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LinkAccountPage()),
                    );
                  },
                  child: const Text('Link account'),
                ),
              ] else ...[
                Text(
                  'Welcome ${_firebaseAuthenticationRepository.currentUser?.displayName ?? _firebaseAuthenticationRepository.currentUser?.email?.split('@').first ?? 'to the home page'}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const Spacer(),
              ],
              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  await _firebaseAuthenticationRepository.signOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                      (route) => false,
                    );
                  }
                },
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
