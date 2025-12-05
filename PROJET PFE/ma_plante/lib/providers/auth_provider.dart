import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String _adminName = '';
  String _role = '';
  bool _isLoading = true;

  bool get isLoggedIn => _isLoggedIn;
  String get adminName => _adminName;
  String get role => _role;
  bool get isLoading => _isLoading;

  AuthProvider() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        _checkAdminStatus(user);
      } else {
        _isLoggedIn = false;
        _adminName = '';
        _role = '';
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  Future<void> _checkAdminStatus(User user) async {
    try {
      _isLoading = true;
      notifyListeners();

      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.email) 
              .get();

      if (!userDoc.exists) {
        _isLoggedIn = false;
        _adminName = '';
        _role = '';
      } else if (userDoc['isAdmin'] == true) {
        _isLoggedIn = true;
        _adminName = userDoc['name'] ?? 'Admin';
        _role = 'Super Admin';
      } else {
        _isLoggedIn = true;
        _adminName = userDoc['name'] ?? 'Utilisateur';
        _role = 'Utilisateur';
      }
    } catch (e) {
      print('Error checking admin status: $e');
      _isLoggedIn = false;
      _adminName = '';
      _role = '';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  
  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
     
    } catch (e) {
      print('Error during logout: $e');
      throw e; 
    }
  }
}
