import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static const String keyIsLoggedIn = 'isLoggedIn';
  static const String keyUserId = 'userId';
  static const String keyUserName = 'userName';
  static const String keyUserEmail = 'userEmail';
  static const String keyUserRole = 'userRole';
  static const String keyUserProfileImage = 'userProfileImage';

  static Future<void> saveUserSession({
    required int userId,
    required String name,
    required String email,
    required String role,
    String? profileImage,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyIsLoggedIn, true);
    await prefs.setInt(keyUserId, userId);
    await prefs.setString(keyUserName, name);
    await prefs.setString(keyUserEmail, email);
    await prefs.setString(keyUserRole, role);
    if (profileImage != null) {
      await prefs.setString(keyUserProfileImage, profileImage);
    } else {
      await prefs.remove(keyUserProfileImage);
    }
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<Map<String, dynamic>?> getUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(keyIsLoggedIn) ?? false) {
      return {
        'userId': prefs.getInt(keyUserId),
        'name': prefs.getString(keyUserName),
        'email': prefs.getString(keyUserEmail),
        'role': prefs.getString(keyUserRole),
        'profileImage': prefs.getString(keyUserProfileImage),
      };
    }
    return null;
  }
}
