import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthStateNotifier extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  AuthStateNotifier() {
    _auth.authStateChanges().listen((user) {
      _user = user;
      notifyListeners(); // 🔁 Notify GoRouter to re-evaluate redirect
    });
  }

  bool get isLoggedIn => _user != null;

  User? get user => _user;
}
