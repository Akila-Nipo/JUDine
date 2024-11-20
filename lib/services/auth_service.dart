import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Login with email and password
  Future<User?> loginWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return result.user;
    } catch (e) {
      throw Exception("Login failed: ${e.toString()}");
    }
  }

  // Logout the current user
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Get current logged-in user
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
