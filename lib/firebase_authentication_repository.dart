import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_authentication_example/exceptions/authentication_exception.dart';
import 'package:google_sign_in/google_sign_in.dart' as google_sign_in;

class FirebaseAuthenticationRepository {
  const FirebaseAuthenticationRepository({
    required firebase_auth.FirebaseAuth firebaseAuth,
    required google_sign_in.GoogleSignIn googleSignIn,
  })  : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn;

  static FirebaseAuthenticationRepository? _instance;

  static FirebaseAuthenticationRepository get instance => _instance ??= FirebaseAuthenticationRepository(
        firebaseAuth: firebase_auth.FirebaseAuth.instance,
        googleSignIn: google_sign_in.GoogleSignIn(),
      );

  final firebase_auth.FirebaseAuth _firebaseAuth;
  final google_sign_in.GoogleSignIn _googleSignIn;

  firebase_auth.User? get currentUser => _firebaseAuth.currentUser;

  Stream<firebase_auth.User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Stream<firebase_auth.User?> get idTokenChanges => _firebaseAuth.idTokenChanges();

  // I suggest to create your own User model instead of using Firebase's model.
  Future<firebase_auth.User> signInAnonymously() async {
    try {
      final userCredential = await _firebaseAuth.signInAnonymously();
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        // You can create custom exceptions to handle errors better.
        throw const AuthenticationException(message: 'Failed to sign in anonymously');
      }

      return firebaseUser;
    } catch (e) {
      // You can also handle the `FirebaseAuthException` and `AuthenticationException` specifically.
      print(e);
      rethrow;
    }
  }

  Future<firebase_auth.User> signUpWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw const AuthenticationException(message: 'Failed to sign up with email and password');
      }

      return signInWithEmailAndPassword(email, password);
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<firebase_auth.User> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw const AuthenticationException(message: 'Failed to sign in with email and password');
      }

      return firebaseUser;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<firebase_auth.User> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      final googleAuth = await googleUser?.authentication;

      if (googleAuth == null) {
        throw const AuthenticationException(message: 'Failed to sign in with Google');
      }

      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw const AuthenticationException(message: 'Failed to sign in with Google');
      }

      return firebaseUser;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<firebase_auth.User> signInWithApple() async {
    final appleProvider = firebase_auth.AppleAuthProvider()
      ..addScope('email')
      ..addScope('name');

    try {
      final userCredential = await _firebaseAuth.signInWithProvider(appleProvider);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw const AuthenticationException(message: 'Failed to sign in with Apple');
      }

      return firebaseUser;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<firebase_auth.User> linkWithEmailAndPassword(String email, String password) async {
    try {
      final currentUser = _firebaseAuth.currentUser;

      if (currentUser == null) {
        throw const AuthenticationException(message: 'User not found');
      }

      final credential = firebase_auth.EmailAuthProvider.credential(email: email, password: password);

      final userCredential = await currentUser.linkWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw const AuthenticationException(message: 'Failed to link with email and password');
      }

      return firebaseUser;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<firebase_auth.User> linkWithGoogle() async {
    try {
      final currentUser = _firebaseAuth.currentUser;

      if (currentUser == null) {
        throw const AuthenticationException(message: 'User not found');
      }

      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw const AuthenticationException(message: 'Google Sign-In was cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        throw const AuthenticationException(message: 'Failed to get Google auth tokens');
      }

      final authCredential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      final userCredential = await currentUser.linkWithCredential(authCredential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw const AuthenticationException(message: 'Failed to link with Google');
      }

      return firebaseUser;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<firebase_auth.User> linkWithApple() async {
    try {
      final currentUser = _firebaseAuth.currentUser;

      if (currentUser == null) {
        throw const AuthenticationException(message: 'User not found');
      }

      final appleProvider = firebase_auth.AppleAuthProvider()
        ..addScope('email')
        ..addScope('name');

      final userCredential = await currentUser.linkWithProvider(appleProvider);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw const AuthenticationException(message: 'Failed to link with Apple');
      }

      return firebaseUser;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
