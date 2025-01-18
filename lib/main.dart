import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_authentication_example/firebase_authentication_repository.dart';
import 'package:firebase_authentication_example/pages/home_page.dart';
import 'package:firebase_authentication_example/pages/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final StreamSubscription<User?> _userSubscription;
  final _firebaseAuthenticationRepository = FirebaseAuthenticationRepository.instance;
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _userSubscription = _firebaseAuthenticationRepository.authStateChanges.listen((user) {
      final navigator = _navigatorKey.currentState;
      if (navigator != null) {
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => user != null ? const HomePage() : const LoginPage(),
          ),
          (route) => false,
        );
      }
    });
  }

  @override
  void dispose() {
    _userSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Firebase Authentication Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        initialData: _firebaseAuthenticationRepository.currentUser,
        stream: _firebaseAuthenticationRepository.idTokenChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            return const HomePage();
          }

          return const LoginPage();
        },
      ),
    );
  }
}
