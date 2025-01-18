import 'package:firebase_authentication_example/firebase_authentication_repository.dart';
import 'package:firebase_authentication_example/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final FirebaseAuthenticationRepository _firebaseAuthenticationRepository;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _firebaseAuthenticationRepository = FirebaseAuthenticationRepository.instance;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }

                  // Email regex pattern
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Please enter a valid email';
                  }

                  return null;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
                obscureText: true,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await _firebaseAuthenticationRepository.signInWithEmailAndPassword(
                      _emailController.text,
                      _passwordController.text,
                    );
                  }
                },
                child: const Text('Login'),
              ),
              const SizedBox(height: 8),
              const Text(
                'or',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterPage()),
                  );
                },
                child: const Text('Sign up'),
              ),
              const Spacer(),
              const Divider(height: 32),
              SignInButton(
                Buttons.google,
                onPressed: () async {
                  await _firebaseAuthenticationRepository.signInWithGoogle();
                },
              ),
              const SizedBox(height: 8),
              SignInButton(
                Buttons.apple,
                onPressed: () async {
                  await _firebaseAuthenticationRepository.signInWithApple();
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () async {
                  await _firebaseAuthenticationRepository.signInAnonymously();
                },
                child: const Text('Continue without signing in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
