import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/user_model.dart';
import 'dart:async'; // Add this

class UserProvider with ChangeNotifier {
  List<UserModel> _users = [];
  bool _isLoading = false;
  StreamSubscription? _updateSubscription; // Add this

  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;

  UserProvider() {
    _listenToUpdates();
  }

  void _listenToUpdates() {
    _updateSubscription = DatabaseHelper().databaseUpdates.listen((table) {
      if (table == 'users') {
        fetchUsers();
      }
    });
  }

  @override
  void dispose() {
    _updateSubscription?.cancel();
    super.dispose();
  }

  Future<void> fetchUsers() async {
    _isLoading = true;
    notifyListeners();
    _users = await DatabaseHelper().getUsers();
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> deleteUser(int id) async {
    int count = await DatabaseHelper().deleteUser(id);
    if (count > 0) {
      await fetchUsers();
      return true;
    }
    return false;
  }

  Future<bool> updateProfileImage(int userId, String? imagePath) async {
    int count = await DatabaseHelper().updateUserProfileImage(
      userId,
      imagePath,
    );
    if (count > 0) {
      await fetchUsers();
      return true;
    }
    return false;
  }
}
