import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../models/auth_result.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<AuthResult> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
  }) async {
    try {
      // Create user with email and password
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;
      if (user == null) {
        return AuthResult.failure(message: 'Failed to create user account');
      }

      // Create user model
      final userModel = UserModel(
        uid: user.uid,
        email: email,
        name: name,
        phone: phone,
        role: role,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save user data to Firestore
      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());

      return AuthResult.success(
        user: userModel,
        message: 'Account created successfully',
      );
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred';
      switch (e.code) {
        case 'weak-password':
          message = 'The password provided is too weak';
          break;
        case 'email-already-in-use':
          message = 'An account already exists for this email';
          break;
        case 'invalid-email':
          message = 'The email address is not valid';
          break;
        default:
          message = e.message ?? 'An error occurred';
      }
      return AuthResult.failure(message: message);
    } catch (e) {
      return AuthResult.failure(message: 'An unexpected error occurred');
    }
  }

  // Sign in with email and password
  Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;
      if (user == null) {
        return AuthResult.failure(message: 'Failed to sign in');
      }

      // Get user data from Firestore
      final DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      
      if (!doc.exists) {
        return AuthResult.failure(message: 'User data not found');
      }

      final userModel = UserModel.fromMap(doc.data() as Map<String, dynamic>);
      
      return AuthResult.success(
        user: userModel,
        message: 'Signed in successfully',
      );
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred';
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found for this email';
          break;
        case 'wrong-password':
          message = 'Wrong password provided';
          break;
        case 'invalid-email':
          message = 'The email address is not valid';
          break;
        case 'user-disabled':
          message = 'This user account has been disabled';
          break;
        default:
          message = e.message ?? 'An error occurred';
      }
      return AuthResult.failure(message: message);
    } catch (e) {
      return AuthResult.failure(message: 'An unexpected error occurred');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user data
  Future<UserModel?> getCurrentUserData() async {
    final User? user = _auth.currentUser;
    if (user == null) return null;

    try {
      final DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print('Error getting user data: $e');
    }
    return null;
  }

  // Update user profile
  Future<AuthResult> updateUserProfile({
    String? name,
    String? phone,
    String? profileImageUrl,
  }) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        return AuthResult.failure(message: 'No user signed in');
      }

      final Map<String, dynamic> updateData = {
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };

      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (profileImageUrl != null) updateData['profileImageUrl'] = profileImageUrl;

      await _firestore.collection('users').doc(user.uid).update(updateData);

      return AuthResult.success(message: 'Profile updated successfully');
    } catch (e) {
      return AuthResult.failure(message: 'Failed to update profile');
    }
  }

  // Reset password
  Future<AuthResult> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return AuthResult.success(message: 'Password reset email sent');
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred';
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found for this email';
          break;
        case 'invalid-email':
          message = 'The email address is not valid';
          break;
        default:
          message = e.message ?? 'An error occurred';
      }
      return AuthResult.failure(message: message);
    } catch (e) {
      return AuthResult.failure(message: 'An unexpected error occurred');
    }
  }

  // Sign in with Google
  Future<AuthResult> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return AuthResult.failure(message: 'Google sign in was cancelled');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        return AuthResult.failure(message: 'Failed to sign in with Google');
      }

      // Check if user exists in Firestore
      final DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      
      UserModel userModel;
      
      if (doc.exists) {
        // User exists, get their data
        userModel = UserModel.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        // New user, create their profile
        userModel = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          name: user.displayName ?? '',
          phone: user.phoneNumber ?? '',
          role: 'passenger', // Default role for Google sign-in
          profileImageUrl: user.photoURL,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        // Save user data to Firestore
        await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
      }

      return AuthResult.success(
        user: userModel,
        message: 'Signed in with Google successfully',
      );
    } catch (e) {
      return AuthResult.failure(message: 'Google sign in failed: ${e.toString()}');
    }
  }
}
