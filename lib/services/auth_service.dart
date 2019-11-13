import 'package:cafeine_me_up/models/auth_response.dart';
import 'package:cafeine_me_up/models/database_response.dart';
import 'package:cafeine_me_up/models/error_message.dart';
import 'package:cafeine_me_up/models/user.dart';
import 'package:cafeine_me_up/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final DatabaseService _database = DatabaseService();
  final String _genericErrorMessage = 'Something went wrong';

  Future<User> _fromFirebaseUser(FirebaseUser user) async {
    if (user == null) {
      return null;
    }

    DatabaseResponse resp = await _database.getUserData(user.uid);
    return new User(
        uid: user.uid,
        email: user.email,
        verified: user.isEmailVerified,
        userData: resp.data);
  }

  String _getErrorMessage(dynamic e) {
    if (e.runtimeType == PlatformException) {
      switch ((e as PlatformException).code) {
        case 'ERROR_WEAK_PASSWORD':
          return 'The password is too weak';
          break;
        case 'ERROR_INVALID_EMAIL':
          return 'The e-mail address is invalid';
          break;
        case 'ERROR_EMAIL_ALREADY_IN_USE':
          return 'The e-mail address is already in use';
          break;
        case 'ERROR_USER_NOT_FOUND':
        case 'ERROR_WRONG_PASSWORD':
          print('Auth error ${(e as PlatformException).code}');
          return 'Invalid e-mail or password';
        case 'ERROR_TOO_MANY_REQUESTS':
        case 'ERROR_USER_DISABLED':
        default:
          return _genericErrorMessage;
          break;
      }
    } else {
      return _genericErrorMessage;
    }
  }

  Stream<User> get currentUser {
    return _firebaseAuth.onAuthStateChanged.asyncMap(_fromFirebaseUser);
  }

  Future<AuthResponse> signUp(
      String displayName, String email, String password) async {
    try {
      AuthResult result = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);

      _database.updateUserData(result.user.uid, displayName: displayName);

      User user = await _fromFirebaseUser(result.user);
      return new AuthResponse(user: user, errorMessage: null);
    } catch (e) {
      return new AuthResponse(
          user: null,
          errorMessage: new ErrorMessage(message: _getErrorMessage(e)));
    }
  }

  Future<AuthResponse> signIn(String email, String password) async {
    try {
      AuthResult result = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);

      User user = await _fromFirebaseUser(result.user);
      return new AuthResponse(user: user, errorMessage: null);
    } catch (e) {
      return new AuthResponse(
          user: null,
          errorMessage: new ErrorMessage(message: _getErrorMessage(e)));
    }
  }

  Future signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      print('signOut failed: $e');
    }
  }
}
