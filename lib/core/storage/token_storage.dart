import 'package:get_storage/get_storage.dart';

class TokenStorage {
  TokenStorage._();

  static final GetStorage _box = GetStorage();

  static const String _authTokenKey = 'auth_token';
  static const String _userRoleKey = 'user_role';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';

  static const String _firstNameKey = 'profile_first_name';
  static const String _lastNameKey = 'profile_last_name';
  static const String _governorateKey = 'profile_governorate';
  static const String _dateOfBirthKey = 'profile_date_of_birth';
  static const String _profileImageUrlKey = 'profile_image_url';
  static const String _identityImageUrlKey = 'identity_image_url';

  static Future<void> saveToken(String token) async {
    await _box.write(_authTokenKey, token);
  }

  static String? getToken() {
    return _box.read<String>(_authTokenKey);
  }

  static Future<void> saveUserRole(String role) async {
    await _box.write(_userRoleKey, role);
  }

  static String? getUserRole() {
    return _box.read<String>(_userRoleKey);
  }

  static Future<void> saveUserId(int userId) async {
    await _box.write(_userIdKey, userId);
  }

  static int? getUserId() {
    return _box.read<int>(_userIdKey);
  }

  static Future<void> saveUserEmail(String email) async {
    await _box.write(_userEmailKey, email);
  }

  static String? getUserEmail() {
    return _box.read<String>(_userEmailKey);
  }

  static Future<void> saveProfileData({
    String? firstName,
    String? lastName,
    String? governorate,
    String? dateOfBirth,
    String? profileImageUrl,
    String? identityImageUrl,
  }) async {
    if (firstName != null && firstName.trim().isNotEmpty) {
      await _box.write(_firstNameKey, firstName.trim());
    }

    if (lastName != null && lastName.trim().isNotEmpty) {
      await _box.write(_lastNameKey, lastName.trim());
    }

    if (governorate != null && governorate.trim().isNotEmpty) {
      await _box.write(_governorateKey, governorate.trim());
    }

    if (dateOfBirth != null && dateOfBirth.trim().isNotEmpty) {
      await _box.write(_dateOfBirthKey, dateOfBirth.trim());
    }

    if (profileImageUrl != null && profileImageUrl.trim().isNotEmpty) {
      await _box.write(_profileImageUrlKey, profileImageUrl.trim());
    }

    if (identityImageUrl != null && identityImageUrl.trim().isNotEmpty) {
      await _box.write(_identityImageUrlKey, identityImageUrl.trim());
    }
  }

  static String? getProfileFirstName() {
    return _box.read<String>(_firstNameKey);
  }

  static String? getProfileLastName() {
    return _box.read<String>(_lastNameKey);
  }

  static String? getProfileGovernorate() {
    return _box.read<String>(_governorateKey);
  }

  static String? getProfileDateOfBirth() {
    return _box.read<String>(_dateOfBirthKey);
  }

  static String? getProfileImageUrl() {
    return _box.read<String>(_profileImageUrlKey);
  }

  static String? getIdentityImageUrl() {
    return _box.read<String>(_identityImageUrlKey);
  }

  static bool get isLoggedIn {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> clear() async {
    await _box.remove(_authTokenKey);
    await _box.remove(_userRoleKey);
    await _box.remove(_userIdKey);
    await _box.remove(_userEmailKey);

    await _box.remove(_firstNameKey);
    await _box.remove(_lastNameKey);
    await _box.remove(_governorateKey);
    await _box.remove(_dateOfBirthKey);
    await _box.remove(_profileImageUrlKey);
    await _box.remove(_identityImageUrlKey);
  }
}