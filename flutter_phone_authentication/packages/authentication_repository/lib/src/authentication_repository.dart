import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'models/models.dart';

/// Thrown if during the sign up process if a failure occurs.
class SignUpFailure implements Exception {}

/// Thrown during the login process if a failure occurs.
class LogInWithEmailAndPasswordFailure implements Exception {}

/// Thrown during the login process if a failure occurs.
class LogInWithPhoneFailure implements Exception {}

/// Thrown during the sign in with google process if a failure occurs.
class LogInWithGoogleFailure implements Exception {}

/// Thrown during the logout process if a failure occurs.
class LogOutFailure implements Exception {}

/// {@template authentication_repository}
/// Repository which manages user authentication.
/// {@endtemplate}

class AuthenticationRepository {
  /// {@macro authentication_repository}
  AuthenticationRepository({
    firebase_auth.FirebaseAuth firebaseAuth,
    GoogleSignIn googleSignIn,
    String code,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.standard(),
        _code = code;

  set code(String value) {
    this._code = value;
  }

  String get code => _code;

  firebase_auth.AuthCredential get phoneAuthCredential => _phoneAuthCredential;

  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  String _code;
  String _verificationCode;
  firebase_auth.AuthCredential _phoneAuthCredential;

  /// Stream of [User] which will emit the current user when
  /// the authentication state changes.
  ///
  /// Emits [User.empty] if the user is not authenticated.
  Stream<User> get user {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      return firebaseUser == null ? User.empty : firebaseUser.toUser;
    });
  }

  /// Creates a new user with the provided [email] and [password].
  ///
  /// Throws a [SignUpFailure] if an exception occurs.

  Future<void> signUp(
      {@required String email, @required String password}) async {
    assert(email != null && password != null);
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on Exception {
      throw SignUpFailure();
    }
  }

  /// Creates a new user with the provided [phoneNumber]
  ///
  /// Throws a [LogInFailure] if an exception occurs.

  Future<void> loginWithPhone({@required phoneNumber}) async {
    assert(phoneNumber != null);
    try {
      await _firebaseAuth.verifyPhoneNumber(
          phoneNumber: "+91" + phoneNumber,
          timeout: const Duration(seconds: 120),
          verificationCompleted:
              (firebase_auth.PhoneAuthCredential credential) async {
            this._phoneAuthCredential = credential;
            // await _firebaseAuth.signInWithCredential(credential);
          },
          verificationFailed: (firebase_auth.FirebaseAuthException e) {
            if (e.code == 'invalid-phone-number') {
              print('The provided phone number is not valid.');
            }
          },
          codeSent: (String verificationId, int resendToken, [int code]) async {
            this._verificationCode = verificationId;
            print(this._verificationCode??"null value ------------>");
            // Create a PhoneAuthCredential with the code
            // firebase_auth.PhoneAuthCredential phoneAuthCredential = firebase_auth.PhoneAuthProvider.credential(verificationId: verificationId, smsCode: _code);

            // Sign the user in (or link) with the credential
            // await _firebaseAuth.signInWithCredential(phoneAuthCredential);
          },
          codeAutoRetrievalTimeout: (String verificationId) {});
    } catch (e) {}
  }

  Future<void> login() async {
    try {
      await _firebaseAuth.signInWithCredential(_phoneAuthCredential);
    } on Exception {
      throw LogInWithPhoneFailure();
    }
  }

  Future<void> submitOtp(String otp) async {

    print("your code is $otp");
    print(_verificationCode);
    _phoneAuthCredential = firebase_auth.PhoneAuthProvider.credential(
        verificationId: _verificationCode, smsCode: otp.trim());
    login();
  }

  /// Starts the Sign In with Google Flow.
  ///
  /// Throws a [LogInWithGoogleFailure] if an exception occurs.

  Future<void> logInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      final googleAuth = await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _firebaseAuth.signInWithCredential(credential);
    } on Exception {
      throw LogInWithGoogleFailure();
    }
  }

  /// Signs in with the provided [email] and [password].
  ///
  /// Throws a [LogInWithEmailAndPasswordFailure] if an exception occurs.
  Future<void> logInWithEmailAndPassword({
    @required String email,
    @required String password,
  }) async {
    assert(email != null && password != null);
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on Exception {
      throw LogInWithEmailAndPasswordFailure();
    }
  }

  /// Signs out the current user which will emit
  /// [User.empty] from the [user] Stream.
  ///
  /// Throws a [LogOutFailure] if an exception occurs.

  Future<void> logOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } on Exception {
      throw LogOutFailure();
    }
  }
}

extension on firebase_auth.User {
  User get toUser {
    return User(id: uid, email: email, name: displayName, photo: photoURL);
  }
}
