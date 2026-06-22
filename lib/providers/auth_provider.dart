import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/user_model.dart';
import '../services/shared_prefs_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  Future<bool> register(UserModel user) async {
    _isLoading = true;
    notifyListeners();
    try {
      final id = await DatabaseHelper().registerUser(user);
      if (id <= 0) {
        throw Exception('User insert returned invalid id: $id');
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Register failed: $e');
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    UserModel? user = await DatabaseHelper().loginUser(email, password);
    if (user != null) {
      _user = user;
      await SharedPrefsService.saveUserSession(
        userId: user.id!,
        name: user.name,
        email: user.email,
        role: user.role,
        profileImage: user.profileImage,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await SharedPrefsService.clearSession();
    _user = null;
    notifyListeners();
  }

  Future<void> updateProfileImage(String? imagePath) async {
    if (_user != null) {
      await DatabaseHelper().updateUserProfileImage(_user!.id!, imagePath);
      _user = UserModel(
        id: _user!.id,
        name: _user!.name,
        email: _user!.email,
        password: _user!.password,
        phone: _user!.phone,
        role: _user!.role,
        profileImage: imagePath,
      );
      await SharedPrefsService.saveUserSession(
        userId: _user!.id!,
        name: _user!.name,
        email: _user!.email,
        role: _user!.role,
        profileImage: _user!.profileImage,
      );
      notifyListeners();
    }
  }

  Future<void> checkLoginSession() async {
    Map<String, dynamic>? session = await SharedPrefsService.getUserSession();
    if (session != null) {
      _user = UserModel(
        id: session['userId'],
        name: session['name'],
        email: session['email'],
        password: '', // Password not saved in prefs
        phone: '',
        role: session['role'],
        profileImage: session['profileImage'],
      );
      notifyListeners();
    }
  }
}
